`timescale 1ns/1ps

// ============================================================
// Testbench: riscv_core_pipelined_tb
// Purpose : Top-level verification for 5-stage pipelined RV32I core.
//           - Instantiates the core, IMEM model, and DMEM model.
//           - Program 0:
//               * ADDI x1, x0, 5
//               * ADDI x2, x0, 10
//               * ADD  x3, x1, x2   => x3 = 15
//           - Program 1 (ALU-immediate / shift tests):
//               * ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI
//           - Observes pipeline behavior via PC and register file.
//           - Checks final register contents for correctness.
// Notes   :
//   - IMEM/DMEM are behavioral memories for simulation only.
//   - Core is IP-style: no internal memories, only clean interfaces.
//   - This TB can be extended with further programs (branches, loads/stores).
// ============================================================

module riscv_core_pipelined_tb;

  reg         clk;
  reg         reset;

  // IMEM / DMEM signals (connect to core)
  wire [31:0] imem_addr;
  wire [31:0] imem_rdata;

  wire [31:0] dmem_addr;
  wire [31:0] dmem_wdata;
  wire [31:0] dmem_rdata;
  wire        dmem_we;
  wire        dmem_re;

  wire [31:0] pc_debug;

  // --------------------------
  // Instantiate DUT
  // --------------------------
  riscv_core_pipelined dut (
    .clk         (clk),
    .reset       (reset),
    .imem_addr_o (imem_addr),
    .imem_rdata_i(imem_rdata),
    .dmem_addr_o (dmem_addr),
    .dmem_wdata_o(dmem_wdata),
    .dmem_rdata_i(dmem_rdata),
    .dmem_we_o   (dmem_we),
    .dmem_re_o   (dmem_re),
    .pc_debug_o  (pc_debug)
  );

  // --------------------------
  // IMEM and DMEM models
  // --------------------------
  imem_model #(.DEPTH(256)) imem_u (
    .addr_i (imem_addr),
    .rdata_o(imem_rdata)
  );

  dmem_model #(.DEPTH(256)) dmem_u (
    .clk    (clk),
    .addr_i (dmem_addr),
    .wdata_i(dmem_wdata),
    .rdata_o(dmem_rdata),
    .we_i   (dmem_we),
    .re_i   (dmem_re)
  );

  // --------------------------
  // Clock generation: 10 ns period
  // --------------------------
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // --------------------------
  // Program constants
  // Program 0:
  //   x1 = 5, x2 = 10, x3 = x1 + x2
  // Program 1:
  //   x4 = x1 & 3
  //   x5 = x1 | 8
  //   x6 = x2 ^ 15
  //   x7 = (x1 < 10)  ? 1 : 0   (signed)
  //   x8 = (x2 < 5)   ? 1 : 0   (unsigned)
  //   x9  = x1 << 1
  //   x10 = x2 >> 1 (logical)
  //   x11 = x2 >> 1 (arith)
  // --------------------------
  localparam [31:0] INSTR_ADDI_X1_5    = 32'h00500093; // addi x1, x0, 5
  localparam [31:0] INSTR_ADDI_X2_10   = 32'h00A00113; // addi x2, x0, 10
  localparam [31:0] INSTR_ADD_X3_1_2   = 32'h002081B3; // add x3, x1, x2
  localparam [31:0] INSTR_NOP          = 32'h00000013; // addi x0,x0,0

  // Program 1 instruction encodings (RV32I)
  // NOTE: Encodings follow standard RV32I I-type and shift-immediate formats.
     // andi x4, x1, 3
    localparam [31:0] INSTR_ANDI_X4_X1_3   = 32'h0030F213;
    // ori x5, x1, 8
    localparam [31:0] INSTR_ORI_X5_X1_8    = 32'h0080E293;
    // xori x6, x2, 15
    localparam [31:0] INSTR_XORI_X6_X2_15  = 32'h00F14313;
    // slti x7, x1, 10
    localparam [31:0] INSTR_SLTI_X7_X1_10  = 32'h00A0A393;
    // sltiu x8, x2, 5
    localparam [31:0] INSTR_SLTIU_X8_X2_5  = 32'h00513413;
    // slli x9, x1, 1
    localparam [31:0] INSTR_SLLI_X9_X1_1   = 32'h00109493;
    // srli x10, x2, 1
    localparam [31:0] INSTR_SRLI_X10_X2_1  = 32'h00115513;
    // srai x11, x2, 1
    localparam [31:0] INSTR_SRAI_X11_X2_1  = 32'h40115593;

    integer i;

  initial begin
    // Initialize IMEM to NOPs
    for (i = 0; i < 256; i = i + 1) begin
      imem_u.mem[i] = INSTR_NOP;
    end

    // Program 0
    imem_u.mem[0] = INSTR_ADDI_X1_5;
    imem_u.mem[1] = INSTR_ADDI_X2_10;
    imem_u.mem[2] = INSTR_ADD_X3_1_2;

    // Program 1
    imem_u.mem[3]  = INSTR_ANDI_X4_X1_3;
    imem_u.mem[4]  = INSTR_ORI_X5_X1_8;
    imem_u.mem[5]  = INSTR_XORI_X6_X2_15;
    imem_u.mem[6]  = INSTR_SLTI_X7_X1_10;
    imem_u.mem[7]  = INSTR_SLTIU_X8_X2_5;
    imem_u.mem[8]  = INSTR_SLLI_X9_X1_1;
    imem_u.mem[9]  = INSTR_SRLI_X10_X2_1;
    imem_u.mem[10] = INSTR_SRAI_X11_X2_1;

    // trailing NOPs
    imem_u.mem[11] = INSTR_NOP;
    imem_u.mem[12] = INSTR_NOP;
    imem_u.mem[13] = INSTR_NOP;

    // Initialize DMEM to 0
    for (i = 0; i < 256; i = i + 1) begin
      dmem_u.mem[i] = 32'h00000000;
    end
 
    $display("==============================================");
    $display("     Pipelined RISC-V Core Testbench Start    ");
    $display("  Program 0 + Program 1 (ALU-immediate tests) ");
    $display("==============================================");

    // Reset sequence
    reset = 1'b1;
    #20;
    reset = 1'b0;

    // Run for enough cycles to complete both programs
    repeat (25) begin
      @(posedge clk);
      $display("Cycle: PC=%h, x1=%h, x2=%h, x3=%h, x4=%h, x5=%h, x6=%h, x7=%h",
               pc_debug,
               dut.regfile_inst.registers[1],
               dut.regfile_inst.registers[2],
               dut.regfile_inst.registers[3],
               dut.regfile_inst.registers[4],
               dut.regfile_inst.registers[5],
               dut.regfile_inst.registers[6],
               dut.regfile_inst.registers[7]);

      // Debug around ANDI when ANDI is in EX/ID-EX
      if (pc_debug == 32'h00000020) begin
        $display("ANDI debug: id_ex_rd1=%h id_ex_imm=%h ex_ALUCtrl=%b funct3=%b funct7=%b",
                 dut.id_ex_rd1,
                 dut.id_ex_imm,
                 dut.ex_ALUCtrl,
                 dut.id_ex_funct3,
                 dut.id_ex_funct7);
      end
    end

    // --- Final Register Snapshot ---
    $display("\n--- Final Register Snapshot ---");
    $display("x1  = 0x%08h",  dut.regfile_inst.registers[1]);
    $display("x2  = 0x%08h",  dut.regfile_inst.registers[2]);
    $display("x3  = 0x%08h",  dut.regfile_inst.registers[3]);
    $display("x4  = 0x%08h",  dut.regfile_inst.registers[4]);
    $display("x5  = 0x%08h",  dut.regfile_inst.registers[5]);
    $display("x6  = 0x%08h",  dut.regfile_inst.registers[6]);
    $display("x7  = 0x%08h",  dut.regfile_inst.registers[7]);
    $display("x8  = 0x%08h",  dut.regfile_inst.registers[8]);
    $display("x9  = 0x%08h",  dut.regfile_inst.registers[9]);
    $display("x10 = 0x%08h",  dut.regfile_inst.registers[10]);
    $display("x11 = 0x%08h",  dut.regfile_inst.registers[11]);

    // Program 0 checks
    if (dut.regfile_inst.registers[1] == 32'd5)
      $display("? PASS: x1 == 5");
    else
      $display("! FAIL: x1 != 5");

    if (dut.regfile_inst.registers[2] == 32'd10)
      $display("? PASS: x2 == 10");
    else
      $display("! FAIL: x2 != 10");

    if (dut.regfile_inst.registers[3] == 32'd15)
      $display("? PASS: x3 == 15 (x1 + x2)");
    else
      $display("! FAIL: x3 != 15");

    // Program 1 checks
    if (dut.regfile_inst.registers[4] == 32'd1)
      $display("? PASS: x4 == 1 (ANDI x4,x1,3)");
    else
      $display("! FAIL: x4 != 1");

    if (dut.regfile_inst.registers[5] == 32'd13)
      $display("? PASS: x5 == 13 (ORI x5,x1,8)");
    else
      $display("! FAIL: x5 != 13");

    if (dut.regfile_inst.registers[6] == 32'd5)
      $display("? PASS: x6 == 5 (XORI x6,x2,15)");
    else
      $display("! FAIL: x6 != 5");

    if (dut.regfile_inst.registers[7] == 32'd1)
      $display("? PASS: x7 == 1 (SLTI x7,x1,10)");
    else
      $display("! FAIL: x7 != 1");

    if (dut.regfile_inst.registers[8] == 32'd0)
      $display("? PASS: x8 == 0 (SLTIU x8,x2,5)");
    else
      $display("! FAIL: x8 != 0");

    if (dut.regfile_inst.registers[9] == 32'd10)
      $display("? PASS: x9 == 10 (SLLI x9,x1,1)");
    else
      $display("! FAIL: x9 != 10");

    if (dut.regfile_inst.registers[10] == 32'd5)
      $display("? PASS: x10 == 5 (SRLI x10,x2,1)");
    else
      $display("! FAIL: x10 != 5");

    if (dut.regfile_inst.registers[11] == 32'd5)
      $display("? PASS: x11 == 5 (SRAI x11,x2,1)");
    else
      $display("! FAIL: x11 != 5");

    $display("==============================================");
    $display(" Pipelined Core Test Summary complete");
    $display("==============================================");

    $stop;
  end

endmodule
