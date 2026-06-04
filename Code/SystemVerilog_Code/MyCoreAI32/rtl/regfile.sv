module regfile (
  input  logic        clk,
  input  logic        rst_n,

  input  logic [4:0]  rs1_addr,
  input  logic [4:0]  rs2_addr,
  output logic [31:0] rs1_data,
  output logic [31:0] rs2_data,

  input  logic        we,
  input  logic [4:0]  rd_addr,
  input  logic [31:0] rd_data
);

  logic [31:0] regs [0:31];

  // Synchronous write (x0 stays 0)
  always_ff @(posedge clk or negedge rst_n) begin
    integer i;
    if (!rst_n) begin
      for (i = 0; i < 32; i++) regs[i] <= 32'h0;
    end else begin
      if (we && (rd_addr != 5'd0)) regs[rd_addr] <= rd_data;
      regs[0] <= 32'h0;
    end
  end

  // Combinational read with WRITE-THROUGH BYPASS
  // If same-cycle write and read same register, return new rd_data.
  always_comb begin
    // rs1
    if (rs1_addr == 5'd0) rs1_data = 32'h0;
    else if (we && (rd_addr != 5'd0) && (rd_addr == rs1_addr)) rs1_data = rd_data;
    else rs1_data = regs[rs1_addr];

    // rs2
    if (rs2_addr == 5'd0) rs2_data = 32'h0;
    else if (we && (rd_addr != 5'd0) && (rd_addr == rs2_addr)) rs2_data = rd_data;
    else rs2_data = regs[rs2_addr];
  end

endmodule