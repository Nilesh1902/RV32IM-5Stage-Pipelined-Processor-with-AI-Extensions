`timescale 1ns/1ps
// ============================================================
// Module: dmem_model
// Type  : Simple data memory model (for testbench only)
// Purpose:
//   - Stores 32-bit data words.
//   - Supports synchronous write (on clk) and combinational read.
//   - Word-aligned access using addr_i[9:2] for 256 words.
// Notes:
//   - To be instantiated in the testbench, not synthesized as part of core.
//   - You can initialize 'mem' in the testbench if needed.
//   - No byte/halfword enables; full 32-bit accesses only.
// ============================================================

module dmem_model #(
  parameter DEPTH = 256  // number of 32-bit words
)(
  input  wire        clk,      // clock for synchronous write
  input  wire [31:0] addr_i,   // byte address from core
  input  wire [31:0] wdata_i,  // write data from core
  output reg  [31:0] rdata_o,  // read data to core
  input  wire        we_i,     // write enable (store)
  input  wire        re_i      // read enable (load)
);

  // Simple data memory array
  reg [31:0] mem [0:DEPTH-1];

  // Synchronous write: on rising edge of clk when write enable is high
  always @(posedge clk) begin
    if (we_i) begin
      mem[addr_i[9:2]] <= wdata_i;  // word-aligned write
    end
  end

  // Combinational read: when read enable is high
  always @(*) begin
    if (re_i)
      rdata_o = mem[addr_i[9:2]];   // word-aligned read
    else
      rdata_o = 32'b0;
  end

endmodule
