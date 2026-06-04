// ============================================================
// Module: Fetch Stage
// Function: Fetches instructions from instruction memory based on PC.
//          Increments PC by 4 for sequential execution.
// Inputs : clk, reset
// Outputs: instr (fetched 32-bit instruction)
// Notes  : For branching/jumping, next_pc should be muxed in the top-level
//          (e.g., riscv_core.v) based on control signals and immediates.
//          Synthesis: Pure combinational logic for instr fetch.
// ============================================================

`timescale 1ns/1ps
module fetch_stage(
    output wire [31:0] instr,    // Fetched instruction
    input wire clk,              // Clock signal
    input wire reset             // Reset signal
);
    wire [31:0] pc_out;
    wire [31:0] next_pc;
    
    // Instantiate PC module
    pc p2(
        .pc_out(pc_out),
        .next_pc(next_pc),
        .clk(clk),
        .reset(reset)
    );
    
    // Instantiate Instruction Memory: Fetch instruction at current PC
    instr_mem i2(
        .instr(instr),
        .addr(pc_out)
    );
    
    // Default: Increment PC by 4 for sequential execution
    // In riscv_core.v, override this with branch/jump logic (e.g., next_pc = (Branch && zero) ? pc_out + imm : pc_out + 4)
    assign next_pc = pc_out + 4;
    
endmodule