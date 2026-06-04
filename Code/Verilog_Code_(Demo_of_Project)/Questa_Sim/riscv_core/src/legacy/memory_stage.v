// ===========================================================
// Module: Memory Stage
// Function: Handles data memory read/write for load/store instructions.
// Inputs : write_data (from regfile), alu_result (address), MemWrite/MemRead (control), clk
// Outputs: read_data (to writeback stage)
// Notes  : 256 x 32-bit memory. Sync write, async read.
//          Address masked to 8 bits (0-255). Out-of-bounds returns 0.
//          Synthesis: Infers block RAM.
// ===========================================================

`timescale 1ns/1ps
module memory_stage(
    output wire [31:0] read_data,     // Read data to writeback
    input wire [31:0] write_data,     // Write data from regfile
    input wire [31:0] alu_result,     // Address from ALU
    input wire MemWrite,              // Write enable
    input wire MemRead,               // Read enable
    input wire clk                    // Clock
);
    
    // 256 x 32-bit data memory
    reg [31:0] data_mem [0:255];
    
    // Initialize memory to 0 (for simulation; synthesis may ignore)
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            data_mem[i] = 32'b0;
        end
    end
    
    // Synchronous write
    always @(posedge clk) begin
        if (MemWrite) begin
            data_mem[alu_result[7:0]] <= write_data;
        end
    end
    
    // Asynchronous read
    assign read_data = (MemRead) ? data_mem[alu_result[7:0]] : 32'b0;
    
endmodule