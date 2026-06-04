import mycoreai32_pkg::*;

module MyCoreAI32 (
  input  logic        clk,
  input  logic        rst_n,

  // IMEM interface (simple, combinational read from TB)
  output logic [31:0] imem_addr,
  input  logic [31:0] imem_rdata,

  // DMEM interface (simple)
  output logic        dmem_we,
  output logic        dmem_re,
  output logic [3:0]  dmem_wstrb,
  output logic [31:0] dmem_addr,
  output logic [31:0] dmem_wdata,
  input  logic [31:0] dmem_rdata
);

  // ----------------------------
  // IF stage
  // ----------------------------
  logic [31:0] pc_q, pc_d;
  logic [31:0] instr_f;

  // IF/ID pipeline
  logic [31:0] if_id_pc;
  logic [31:0] if_id_instr;

  // next PC control
  logic        pc_redirect;
  logic [31:0] pc_target;

  // stall sources
  logic stall_lu;     // load-use stall (from hazard unit)
  logic stall_m;      // mul/div in-flight stall (from m_unit handshake)
  logic stall;        // combined stall

  assign stall = stall_lu | stall_m;

  assign imem_addr = pc_q;
  assign instr_f   = imem_rdata;

  // PC update
  always_comb begin
    if (pc_redirect) pc_d = pc_target;
    else            pc_d = pc_q + 32'd4;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) pc_q <= 32'h0;     // PC reset = 0x0000_0000
    else if (!stall) pc_q <= pc_d;
  end

  // IF/ID regs
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      if_id_pc    <= 32'h0;
      if_id_instr <= 32'h00000013; // NOP
    end else if (pc_redirect) begin
      if_id_pc    <= 32'h0;
      if_id_instr <= 32'h00000013;
    end else if (!stall) begin
      if_id_pc    <= pc_q;
      if_id_instr <= instr_f;
    end
  end

  // ----------------------------
  // ID stage: decode, regfile, imm
  // ----------------------------
  logic [6:0] opcode;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [4:0] rs1, rs2, rd;

  assign opcode = if_id_instr[6:0];
  assign rd     = if_id_instr[11:7];
  assign funct3 = if_id_instr[14:12];
  assign rs1    = if_id_instr[19:15];
  assign rs2    = if_id_instr[24:20];
  assign funct7 = if_id_instr[31:25];

  logic [31:0] rf_rs1, rf_rs2;
  logic        wb_we;
  logic [4:0]  wb_rd;
  logic [31:0] wb_wdata;

  // regfile (instance name regfile_inst)
  regfile regfile_inst (
    .clk(clk), .rst_n(rst_n),
    .rs1_addr(rs1), .rs2_addr(rs2),
    .rs1_data(rf_rs1), .rs2_data(rf_rs2),
    .we(wb_we), .rd_addr(wb_rd), .rd_data(wb_wdata)
  );

  // immediates
  logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
  immgen u_imm(
    .instr(if_id_instr),
    .imm_i(imm_i), .imm_s(imm_s), .imm_b(imm_b), .imm_u(imm_u), .imm_j(imm_j)
  );

  // Control signals (ID -> EX)
  logic        id_regwrite, id_memread, id_memwrite, id_memtoreg;
  logic        id_alusrc;
  alu_op_t     id_aluop;
  logic        id_is_branch, id_branch_bne;
  logic        id_is_jal, id_is_jalr;
  logic        id_is_lui, id_is_auipc;

  // AI decode
  logic id_do_vdot4, id_do_vmax4;

  // RV32M decode flag
  logic id_is_muldiv;

  always_comb begin
    // defaults: NOP
    id_regwrite   = 1'b0;
    id_memread    = 1'b0;
    id_memwrite   = 1'b0;
    id_memtoreg   = 1'b0;
    id_alusrc     = 1'b0;
    id_aluop      = ALU_ADD;

    id_is_branch  = 1'b0;
    id_branch_bne = 1'b0;
    id_is_jal     = 1'b0;
    id_is_jalr    = 1'b0;
    id_is_lui     = 1'b0;
    id_is_auipc   = 1'b0;

    id_do_vdot4   = 1'b0;
    id_do_vmax4   = 1'b0;

    id_is_muldiv  = 1'b0;

    unique case (opcode)

      OPCODE_OP: begin
        id_regwrite = 1'b1;
        id_alusrc   = 1'b0;

        // ---- RV32M detection: funct7=0000001 ----
        if (funct7 == FUNCT7_MULDIV) begin
          id_is_muldiv = 1'b1;
          id_aluop     = rv32m_aluop_from_funct3(funct3);
        end else begin
          unique case (funct3)
            3'b000: id_aluop = (funct7[5] ? ALU_SUB : ALU_ADD);
            3'b111: id_aluop = ALU_AND;
            3'b110: id_aluop = ALU_OR;
            3'b100: id_aluop = ALU_XOR;
            3'b010: id_aluop = ALU_SLT;
            3'b011: id_aluop = ALU_SLTU;
            3'b001: id_aluop = ALU_SLL;
            3'b101: id_aluop = (funct7[5] ? ALU_SRA : ALU_SRL);
            default: id_aluop = ALU_ADD;
          endcase
        end
      end

      OPCODE_OP_IMM: begin
        id_regwrite = 1'b1;
        id_alusrc   = 1'b1;
        unique case (funct3)
          3'b000: id_aluop = ALU_ADD;   // ADDI
          3'b111: id_aluop = ALU_AND;   // ANDI
          3'b110: id_aluop = ALU_OR;    // ORI
          3'b100: id_aluop = ALU_XOR;   // XORI
          3'b010: id_aluop = ALU_SLT;   // SLTI
          3'b011: id_aluop = ALU_SLTU;  // SLTIU
          3'b001: id_aluop = ALU_SLL;   // SLLI
          3'b101: id_aluop = (funct7[5] ? ALU_SRA : ALU_SRL); // SRLI/SRAI
          default: id_aluop = ALU_ADD;
        endcase
      end

      OPCODE_LOAD: begin
        id_regwrite = 1'b1;
        id_memread  = 1'b1;
        id_memtoreg = 1'b1;
        id_alusrc   = 1'b1;
        id_aluop    = ALU_ADD;
      end

      OPCODE_STORE: begin
        id_memwrite = 1'b1;
        id_alusrc   = 1'b1;
        id_aluop    = ALU_ADD;
      end

      OPCODE_BRANCH: begin
        id_is_branch = 1'b1;
        id_alusrc    = 1'b0;
        id_aluop     = ALU_SUB;
        id_branch_bne = (funct3 == 3'b001); // BNE
      end

      OPCODE_JAL: begin
        id_is_jal    = 1'b1;
        id_regwrite  = 1'b1;
      end

      OPCODE_JALR: begin
        id_is_jalr   = 1'b1;
        id_regwrite  = 1'b1;
        id_alusrc    = 1'b1;
        id_aluop     = ALU_ADD;
      end

      OPCODE_LUI: begin
        id_is_lui    = 1'b1;
        id_regwrite  = 1'b1;
      end

      OPCODE_AUIPC: begin
        id_is_auipc  = 1'b1;
        id_regwrite  = 1'b1;
      end

      OPCODE_CUSTOM0: begin
        // Custom AI ops: R-type, funct3==000
        id_regwrite = 1'b1;
        id_alusrc   = 1'b0;

        if ((funct3 == 3'b000) && (funct7 == FUNCT7_VDOT4)) id_do_vdot4 = 1'b1;
        if ((funct3 == 3'b000) && (funct7 == FUNCT7_VMAX4)) id_do_vmax4 = 1'b1;
      end

      default: begin
        // NOP
      end
    endcase
  end

  // ----------------------------
  // ID/EX pipeline regs
  // ----------------------------
  logic [31:0] id_ex_pc;
  logic [31:0] id_ex_rs1_data, id_ex_rs2_data;
  logic [31:0] id_ex_imm_i, id_ex_imm_s, id_ex_imm_b, id_ex_imm_u, id_ex_imm_j;
  logic [4:0]  id_ex_rs1, id_ex_rs2, id_ex_rd;

  logic        id_ex_regwrite, id_ex_memread, id_ex_memwrite, id_ex_memtoreg;
  logic        id_ex_alusrc;
  alu_op_t     id_ex_aluop;
  logic        id_ex_is_branch, id_ex_branch_bne, id_ex_is_jal, id_ex_is_jalr, id_ex_is_lui, id_ex_is_auipc;
  logic        id_ex_do_vdot4, id_ex_do_vmax4;
  logic        id_ex_is_muldiv;

  // Forwarding selects
  logic [1:0] fwd_a_sel, fwd_b_sel;

  // Need these declared before hazard_forward hookup
  logic        ex_mem_regwrite, ex_mem_memread, ex_mem_memwrite, ex_mem_memtoreg;
  logic [4:0]  ex_mem_rd;

  logic        mem_wb_regwrite, mem_wb_memtoreg;
  logic [4:0]  mem_wb_rd;

  hazard_forward u_hf (
    .id_rs1(rs1), .id_rs2(rs2),
    .id_ex_memread(id_ex_memread),
    .id_ex_rd(id_ex_rd),
    .ex_rs1(id_ex_rs1), .ex_rs2(id_ex_rs2),
    .ex_mem_regwrite(ex_mem_regwrite), .ex_mem_rd(ex_mem_rd),
    .mem_wb_regwrite(mem_wb_regwrite), .mem_wb_rd(mem_wb_rd),
    .stall(stall_lu),
    .fwd_a_sel(fwd_a_sel),
    .fwd_b_sel(fwd_b_sel)
  );

  // ID/EX update:
  // - pc_redirect => flush
  // - stall_lu    => insert bubble (clear controls)
  // - stall_m     => HOLD ALL ID/EX (keep same EX instruction until mul/div done)
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      id_ex_pc <= 32'h0;
      id_ex_rs1_data <= 32'h0; id_ex_rs2_data <= 32'h0;
      id_ex_imm_i <= 32'h0; id_ex_imm_s <= 32'h0; id_ex_imm_b <= 32'h0; id_ex_imm_u <= 32'h0; id_ex_imm_j <= 32'h0;
      id_ex_rs1 <= 5'h0; id_ex_rs2 <= 5'h0; id_ex_rd <= 5'h0;

      id_ex_regwrite <= 1'b0; id_ex_memread <= 1'b0; id_ex_memwrite <= 1'b0; id_ex_memtoreg <= 1'b0;
      id_ex_alusrc <= 1'b0; id_ex_aluop <= ALU_ADD;

      id_ex_is_branch <= 1'b0; id_ex_branch_bne <= 1'b0;
      id_ex_is_jal <= 1'b0; id_ex_is_jalr <= 1'b0;
      id_ex_is_lui <= 1'b0; id_ex_is_auipc <= 1'b0;

      id_ex_do_vdot4 <= 1'b0; id_ex_do_vmax4 <= 1'b0;
      id_ex_is_muldiv <= 1'b0;

    end else if (pc_redirect) begin
      // flush wrong-path
      id_ex_regwrite <= 1'b0; id_ex_memread <= 1'b0; id_ex_memwrite <= 1'b0; id_ex_memtoreg <= 1'b0;
      id_ex_is_branch <= 1'b0; id_ex_is_jal <= 1'b0; id_ex_is_jalr <= 1'b0;
      id_ex_is_lui <= 1'b0; id_ex_is_auipc <= 1'b0;
      id_ex_do_vdot4 <= 1'b0; id_ex_do_vmax4 <= 1'b0;
      id_ex_is_muldiv <= 1'b0;
      id_ex_alusrc <= 1'b0; id_ex_aluop <= ALU_ADD;

      id_ex_pc <= 32'h0;
      id_ex_rs1 <= 5'h0; id_ex_rs2 <= 5'h0; id_ex_rd <= 5'h0;
      id_ex_rs1_data <= 32'h0; id_ex_rs2_data <= 32'h0;
      id_ex_imm_i <= 32'h0; id_ex_imm_s <= 32'h0; id_ex_imm_b <= 32'h0; id_ex_imm_u <= 32'h0; id_ex_imm_j <= 32'h0;

    end else if (stall_lu) begin
      // insert bubble: clear controls only
      id_ex_regwrite <= 1'b0;
      id_ex_memread  <= 1'b0;
      id_ex_memwrite <= 1'b0;
      id_ex_memtoreg <= 1'b0;
      id_ex_is_branch <= 1'b0;
      id_ex_is_jal    <= 1'b0;
      id_ex_is_jalr   <= 1'b0;
      id_ex_is_lui    <= 1'b0;
      id_ex_is_auipc  <= 1'b0;
      id_ex_do_vdot4  <= 1'b0;
      id_ex_do_vmax4  <= 1'b0;
      id_ex_is_muldiv <= 1'b0;
      id_ex_alusrc    <= 1'b0;
      id_ex_aluop     <= ALU_ADD;

    end else if (stall_m) begin
      // HOLD everything (no assignment)

    end else begin
      id_ex_pc       <= if_id_pc;
      id_ex_rs1_data <= rf_rs1;
      id_ex_rs2_data <= rf_rs2;
      id_ex_imm_i    <= imm_i;
      id_ex_imm_s    <= imm_s;
      id_ex_imm_b    <= imm_b;
      id_ex_imm_u    <= imm_u;
      id_ex_imm_j    <= imm_j;
      id_ex_rs1      <= rs1;
      id_ex_rs2      <= rs2;
      id_ex_rd       <= rd;

      id_ex_regwrite <= id_regwrite;
      id_ex_memread  <= id_memread;
      id_ex_memwrite <= id_memwrite;
      id_ex_memtoreg <= id_memtoreg;
      id_ex_alusrc   <= id_alusrc;
      id_ex_aluop    <= id_aluop;

      id_ex_is_branch  <= id_is_branch;
      id_ex_branch_bne <= id_branch_bne;
      id_ex_is_jal     <= id_is_jal;
      id_ex_is_jalr    <= id_is_jalr;
      id_ex_is_lui     <= id_is_lui;
      id_ex_is_auipc   <= id_is_auipc;

      id_ex_do_vdot4   <= id_do_vdot4;
      id_ex_do_vmax4   <= id_do_vmax4;

      id_ex_is_muldiv  <= id_is_muldiv;
    end
  end

  // ----------------------------
  // EX stage: forwarding + ALU + AI + RV32M unit + branch/jump
  // ----------------------------
  logic [31:0] ex_op_a_raw, ex_op_b_raw;
  logic [31:0] ex_op_a, ex_op_b;
  logic [31:0] ex_alu_y;
  logic [31:0] ex_ai_y;

  // Forwardable values
  logic [31:0] ex_mem_alu_y;
  logic [31:0] mem_wb_wdata_internal;

  // Forward muxes (raw operands used also by AI and muldiv)
  always_comb begin
    ex_op_a_raw = id_ex_rs1_data;
    ex_op_b_raw = id_ex_rs2_data;

    unique case (fwd_a_sel)
      2'b10: ex_op_a_raw = ex_mem_alu_y;
      2'b01: ex_op_a_raw = mem_wb_wdata_internal;
      default: ;
    endcase

    unique case (fwd_b_sel)
      2'b10: ex_op_b_raw = ex_mem_alu_y;
      2'b01: ex_op_b_raw = mem_wb_wdata_internal;
      default: ;
    endcase
  end

  assign ex_op_a = ex_op_a_raw;

  // ALUSrc mux (for OP-IMM, LOAD/STORE address, JALR base+imm)
  always_comb begin
    if (id_ex_alusrc) ex_op_b = id_ex_imm_i; // store overridden by ex_addr_imm below
    else             ex_op_b = ex_op_b_raw;
  end

  // For store address calc
  logic [31:0] ex_addr_imm;
  always_comb begin
    ex_addr_imm = id_ex_imm_i;
    if (id_ex_memwrite) ex_addr_imm = id_ex_imm_s;
  end

  // ALU
  alu u_alu(
    .a(ex_op_a),
    .b(id_ex_alusrc ? ex_addr_imm : ex_op_b_raw),
    .op(id_ex_aluop),
    .y(ex_alu_y)
  );

  // AI unit
  ai_unit u_ai(
    .rs1(ex_op_a_raw),
    .rs2(ex_op_b_raw),
    .do_vdot4(id_ex_do_vdot4),
    .do_vmax4(id_ex_do_vmax4),
    .result(ex_ai_y)
  );

  logic ex_is_ai;
  assign ex_is_ai = id_ex_do_vdot4 | id_ex_do_vmax4;

  // ----------------------------
  // RV32M mul/div unit + handshake stall in EX
  // ----------------------------
  logic        m_req_valid;
  logic        m_ready, m_done;
  logic [31:0] m_result;

  // Only issue request when unit is ready
  assign m_req_valid = id_ex_is_muldiv & m_ready;

  muldiv_unit u_m (
    .clk(clk),
    .rst_n(rst_n),
    .req_valid(m_req_valid),
    .req_op(id_ex_aluop),      // uses same alu_op_t encoding
    .req_a(ex_op_a_raw),
    .req_b(ex_op_b_raw),
    .resp_ready(m_ready),
    .resp_done(m_done),
    .resp_result(m_result)
  );

  // Stall EX while mul/div instruction is in EX and result not done yet
  // (on the cycle m_done==1, we allow pipeline to advance)
  always_comb begin
    stall_m = 1'b0;
    if (id_ex_is_muldiv && !m_done) stall_m = 1'b1;
  end

  // ----------------------------
  // Branch decision
  // ----------------------------
  logic ex_zero;
  assign ex_zero = (ex_op_a_raw == ex_op_b_raw);

  logic ex_take_branch;
  always_comb begin
    ex_take_branch = 1'b0;
    if (id_ex_is_branch) begin
      if (!id_ex_branch_bne) ex_take_branch = ex_zero;      // BEQ
      else                   ex_take_branch = !ex_zero;     // BNE
    end
  end

  // PC redirect logic (branch/jal/jalr resolved in EX)
  always_comb begin
    pc_redirect = 1'b0;
    pc_target   = 32'h0;

    // NOTE: mul/div never redirects PC
    if (id_ex_is_jal) begin
      pc_redirect = 1'b1;
      pc_target   = id_ex_pc + id_ex_imm_j;
    end else if (id_ex_is_jalr) begin
      pc_redirect = 1'b1;
      pc_target   = (ex_alu_y) & 32'hFFFFFFFE;
    end else if (ex_take_branch) begin
      pc_redirect = 1'b1;
      pc_target   = id_ex_pc + id_ex_imm_b;
    end
  end

  // EX result selection
  logic [31:0] ex_result;
  always_comb begin
    if (id_ex_is_lui)               ex_result = id_ex_imm_u;
    else if (id_ex_is_auipc)        ex_result = id_ex_pc + id_ex_imm_u;
    else if (id_ex_is_jal || id_ex_is_jalr) ex_result = id_ex_pc + 32'd4;
    else if (id_ex_is_muldiv)       ex_result = m_result;      // RV32M result
    else if (ex_is_ai)              ex_result = ex_ai_y;        // AI result
    else                            ex_result = ex_alu_y;       // normal ALU
  end

  // ----------------------------
  // EX/MEM pipeline regs
  // ----------------------------
  logic [31:0] ex_mem_rs2_fwd;
  logic [31:0] ex_mem_addr;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ex_mem_regwrite <= 1'b0;
      ex_mem_memread  <= 1'b0;
      ex_mem_memwrite <= 1'b0;
      ex_mem_memtoreg <= 1'b0;
      ex_mem_rd       <= 5'h0;
      ex_mem_rs2_fwd  <= 32'h0;
      ex_mem_addr     <= 32'h0;
    end else if (stall_m) begin
      // HOLD EX/MEM while mul/div is running (don't advance)
    end else begin
      ex_mem_regwrite <= id_ex_regwrite;
      ex_mem_memread  <= id_ex_memread;
      ex_mem_memwrite <= id_ex_memwrite;
      ex_mem_memtoreg <= id_ex_memtoreg;
      ex_mem_rd       <= id_ex_rd;
      ex_mem_rs2_fwd  <= ex_op_b_raw;
      ex_mem_addr     <= ex_result;
    end
  end

  assign ex_mem_alu_y = ex_mem_addr;

  // ----------------------------
  // MEM stage
  // ----------------------------
  assign dmem_addr  = ex_mem_addr;
  assign dmem_wdata = ex_mem_rs2_fwd;

  assign dmem_we    = ex_mem_memwrite;
  assign dmem_re    = ex_mem_memread;

  // Only SW (word) for now
  assign dmem_wstrb = ex_mem_memwrite ? 4'b1111 : 4'b0000;

  logic [31:0] mem_rdata;
  assign mem_rdata = dmem_rdata;

  // ----------------------------
  // MEM/WB pipeline regs
  // ----------------------------
  logic [31:0] mem_wb_alu_y;
  logic [31:0] mem_wb_mem_y;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mem_wb_regwrite <= 1'b0;
      mem_wb_memtoreg <= 1'b0;
      mem_wb_rd       <= 5'h0;
      mem_wb_alu_y    <= 32'h0;
      mem_wb_mem_y    <= 32'h0;
    end else begin
      mem_wb_regwrite <= ex_mem_regwrite;
      mem_wb_memtoreg <= ex_mem_memtoreg;
      mem_wb_rd       <= ex_mem_rd;
      mem_wb_alu_y    <= ex_mem_addr;
      mem_wb_mem_y    <= mem_rdata;
    end
  end

  // WB mux
  always_comb begin
    wb_we    = mem_wb_regwrite;
    wb_rd    = mem_wb_rd;
    wb_wdata = mem_wb_memtoreg ? mem_wb_mem_y : mem_wb_alu_y;
  end

  assign mem_wb_wdata_internal = wb_wdata;

endmodule