`timescale 1ns/1ps
// ============================================================
// Module: imem_model
// Type  : Simple instruction memory model (for testbench only)
// Purpose:
//   - Stores 32-bit instructions.
//   - Read-only from the core side (no write port).
//   - Word-aligned access using addr_i[9:2] for 256 words.
// Notes:
//   - To be instantiated in the testbench, not synthesized as part of core.
//   - You will initialize 'mem' in the testbench using hierarchical access,
//     e.g., imem_u.mem[0] = 32'h....;
// ============================================================

module imem_model #(
  parameter DEPTH = 256  // number of 32-bit words
)(
  input  wire [31:0] addr_i,   // byte address from core (PC)
  output reg  [31:0] rdata_o   // 32-bit instruction
);

  // Simple instruction memory array
  reg [31:0] mem [0:DEPTH-1];

  // Combinational read: word-aligned (ignore lowest 2 bits of byte address)
  always @(*) begin
    rdata_o = mem[addr_i[9:2]];  // addr_i[9:2] indexes 0..255
  end

endmodule