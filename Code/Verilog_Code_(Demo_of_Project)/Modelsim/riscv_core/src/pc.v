// ============================================================
// Module: Program Counter (PC)
// Function: Holds the current program counter value, updated synchronously.
//          Resets asynchronously to 0 on reset.
// Inputs : next_pc (next PC value), clk, reset
// Outputs: pc_out (current PC value)
// Notes  : Asynchronous reset is used for quick response in hardware.
//          Ensure reset is properly constrained in synthesis tools (e.g., FPGA)
//          to avoid glitches. For branching/jumping, next_pc should be muxed
//          in the top-level (e.g., riscv_core.v or fetch_stage.v).
// ============================================================

`timescale 1ns/1ps
module pc(
    output reg [31:0] pc_out,    // Current PC value
    input wire [31:0] next_pc,   // Next PC value (driven by fetch logic)
    input wire clk,              // Clock signal
    input wire reset             // Asynchronous reset (active high)
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 32'b0;     // Reset PC to 0
        end else begin
            pc_out <= next_pc;   // Update PC on clock edge
        end
    end

endmodule