timeunit 1ns;
timeprecision 1ps;

module tb_MyCoreAI32;

  logic clk, rst_n;

  // IMEM
  logic [31:0] imem_addr;
  logic [31:0] imem_rdata;

  // DMEM
  logic        dmem_we, dmem_re;
  logic [3:0]  dmem_wstrb;
  logic [31:0] dmem_addr;
  logic [31:0] dmem_wdata;
  logic [31:0] dmem_rdata;

  // DUT
  MyCoreAI32 dut (
    .clk(clk), .rst_n(rst_n),
    .imem_addr(imem_addr), .imem_rdata(imem_rdata),
    .dmem_we(dmem_we), .dmem_re(dmem_re), .dmem_wstrb(dmem_wstrb),
    .dmem_addr(dmem_addr), .dmem_wdata(dmem_wdata), .dmem_rdata(dmem_rdata)
  );

  // Clock: 100 MHz (10 ns period)
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // Simple memories (word addressed)
  logic [31:0] imem [0:1023];
  logic [31:0] dmem [0:1023];

  // IMEM combinational read
  always_comb imem_rdata = imem[imem_addr[11:2]];

  // DMEM write (word only)
  always_ff @(posedge clk) begin
    if (dmem_we) begin
      dmem[dmem_addr[11:2]] <= dmem_wdata;
    end
  end

  // DMEM combinational read
  always_comb dmem_rdata = dmem[dmem_addr[11:2]];

  // Init memories + load program
  initial begin
    integer i;
    for (i = 0; i < 1024; i++) begin
      imem[i] = 32'h00000013; // NOP
      dmem[i] = 32'h0;
    end

    $readmemh("tb/imem.hex", imem);

    // Quick IMEM dump
    $display("---- IMEM DUMP [0..15] ----");
    for (i = 0; i < 16; i++) $display("IMEM[%0d] = 0x%08x", i, imem[i]);
    $display("---------------------------");
  end

  // ---------------------------------------
  // Transcript monitor (like your old one)
  // ---------------------------------------
  int cyc;
  always_ff @(posedge clk) begin
    cyc <= cyc + 1;

    if (rst_n) begin
      // PC + IF instruction
      $display("CYC=%0d PC=0x%08x IF=0x%08x  stall(lu,m,t)=%0d,%0d,%0d  redir=%0d",
        cyc,
        dut.pc_q,
        dut.if_id_instr,
        dut.stall_lu,
        dut.stall_m,
        dut.stall,
        dut.pc_redirect
      );

      // Writeback info
      if (dut.wb_we && (dut.wb_rd != 0)) begin
        $display("   WB: x%0d <= 0x%08x", dut.wb_rd, dut.wb_wdata);
      end

      // DMEM store
      if (dmem_we) begin
        $display("   DMEM STORE: addr=0x%08x data=0x%08x", dmem_addr, dmem_wdata);
      end

      // DMEM load (combinational read shown when core asserts re)
      if (dmem_re) begin
        $display("   DMEM LOAD : addr=0x%08x rdata=0x%08x", dmem_addr, dmem_rdata);
      end

      // Mul/Div handshake status (internal signals in DUT)
      if (dut.id_ex_is_muldiv) begin
        $display("   MUNIT: ready=%0d done=%0d result=0x%08x",
          dut.m_ready, dut.m_done, dut.m_result
        );
      end

      // AI op debug (optional)
      if (dut.id_ex_do_vdot4 || dut.id_ex_do_vmax4) begin
        $display("   AI: vdot4=%0d vmax4=%0d rs1=0x%08x rs2=0x%08x ai_y=0x%08x",
          dut.id_ex_do_vdot4, dut.id_ex_do_vmax4,
          dut.ex_op_a_raw, dut.ex_op_b_raw, dut.ex_ai_y
        );
      end
    end
  end

  // Run + checks
  initial begin
    cyc  = 0;
    rst_n = 1'b0;
    repeat (5) @(posedge clk);
    rst_n = 1'b1;

    // run long enough for mul/div too
    repeat (800) @(posedge clk);

    // Debug words (your earlier map)
    $display("DBG: dmem[0] (PASS/FAIL)  =0x%08x", dmem[0]);
    $display("DBG: dmem[1] (VDOT4)      =0x%08x", dmem[1]);
    $display("DBG: dmem[2] (VMAX4)      =0x%08x", dmem[2]);
    $display("DBG: dmem[3] (expected)   =0x%08x", dmem[3]);

    if (dmem[0] == 32'h0000_00AA) begin
      $display("PASS: dmem[0]=0x%08x", dmem[0]);
    end else begin
      $display("FAIL: dmem[0]=0x%08x (expected 0x000000AA)", dmem[0]);
    end

    $finish;
  end

endmodule