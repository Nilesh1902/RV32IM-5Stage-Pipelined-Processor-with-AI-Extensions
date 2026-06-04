module hazard_forward (
  // ID stage source regs (for load-use stall)
  input  logic [4:0] id_rs1,
  input  logic [4:0] id_rs2,

  // ID/EX info for load-use hazard
  input  logic       id_ex_memread,
  input  logic [4:0] id_ex_rd,

  // EX stage source regs (for forwarding)
  input  logic [4:0] ex_rs1,
  input  logic [4:0] ex_rs2,

  // EX/MEM stage destination
  input  logic       ex_mem_regwrite,
  input  logic [4:0] ex_mem_rd,

  // MEM/WB stage destination
  input  logic       mem_wb_regwrite,
  input  logic [4:0] mem_wb_rd,

  // Outputs
  output logic       stall,
  output logic [1:0] fwd_a_sel,
  output logic [1:0] fwd_b_sel
);

  // ------------------------------------------------------------
  // Load-use hazard stall:
  // If instruction in EX is a load and its rd is needed by the
  // instruction currently in ID, stall 1 cycle.
  // ------------------------------------------------------------
  always_comb begin
    stall = 1'b0;
    if (id_ex_memread && (id_ex_rd != 5'd0) &&
        ((id_ex_rd == id_rs1) || (id_ex_rd == id_rs2))) begin
      stall = 1'b1;
    end
  end

  // ------------------------------------------------------------
  // Forwarding for EX stage operands
  // Priority: EX/MEM (newer) over MEM/WB (older)
  //
  // fwd_*_sel:
  // 00 = use ID/EX reg value
  // 10 = forward from EX/MEM
  // 01 = forward from MEM/WB
  // ------------------------------------------------------------
  always_comb begin
    // defaults
    fwd_a_sel = 2'b00;
    fwd_b_sel = 2'b00;

    // ---- Forward A (rs1) ----
    if (ex_mem_regwrite && (ex_mem_rd != 5'd0) && (ex_mem_rd == ex_rs1)) begin
      fwd_a_sel = 2'b10;
    end else if (mem_wb_regwrite && (mem_wb_rd != 5'd0) && (mem_wb_rd == ex_rs1)) begin
      fwd_a_sel = 2'b01;
    end

    // ---- Forward B (rs2) ----
    if (ex_mem_regwrite && (ex_mem_rd != 5'd0) && (ex_mem_rd == ex_rs2)) begin
      fwd_b_sel = 2'b10;
    end else if (mem_wb_regwrite && (mem_wb_rd != 5'd0) && (mem_wb_rd == ex_rs2)) begin
      fwd_b_sel = 2'b01;
    end
  end

endmodule