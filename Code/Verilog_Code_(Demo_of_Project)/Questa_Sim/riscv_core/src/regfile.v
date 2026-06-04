// ============================================================
// Module: Register File
// Function: 32 x 32-bit register file for RISC-V core.
//          Reads are combinational, writes are synchronous.
// Inputs : wd (write data), rd (dest reg), rs1/rs2 (source regs), we (write enable), clk
// Outputs: rd1/rd2 (read data from rs1/rs2)
// Notes  : x0 is hardwired to 0 (cannot be written).
//          Synthesis: Infers block RAM for registers.
// ============================================================

`timescale 1ns/1ps
module regfile(
    output wire [31:0] rd1,       // Read data 1 (from rs1)
    output wire [31:0] rd2,       // Read data 2 (from rs2)
    input wire [31:0] wd,         // Write data
    input wire [4:0] rd,          // Destination register index
    input wire [4:0] rs1, rs2,    // Source register indices
    input wire we,                // Write enable
    input wire clk
);
    reg [31:0] registers [0:31];  // 32 registers, each 32 bits
    
    // Initialize all registers to 0 (for simulation; synthesis may ignore)
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end
    
    // Read: Combinational (async)
    // x0 is hardwired to 0
    assign rd1 = (rs1 == 0) ? 32'b0 : registers[rs1];
    assign rd2 = (rs2 == 0) ? 32'b0 : registers[rs2];
    
    // Write: Synchronous on posedge clk
    // x0 cannot be written (always 0)
    always @(posedge clk) begin
        if (we && (rd != 0)) begin
            registers[rd] <= wd;
        end
    end
    
endmodule