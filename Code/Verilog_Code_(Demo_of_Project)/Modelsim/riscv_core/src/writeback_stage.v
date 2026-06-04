// ============================================================
// Module: Writeback Stage
// Function: Selects data for register writeback (ALU result or memory data).
// Inputs : mem_to_reg (control: 1=mem, 0=ALU), mem_data (from memory), alu_result (from ALU)
// Outputs: wb_data (to regfile)
// Notes  : Mux for load instructions (mem_to_reg=1) vs. others (mem_to_reg=0).
//          Synthesis: Pure combinational logic.
// ============================================================

`timescale 1ns/1ps
module writeback_stage(
    output wire [31:0] wb_data,        // Writeback data to regfile
    input wire mem_to_reg,             // Control: 1=select memory, 0=select ALU
    input wire [31:0] mem_data,        // Data from memory stage
    input wire [31:0] alu_result       // Data from ALU
);
    
    // Mux: Select between memory data and ALU result
    assign wb_data = mem_to_reg ? mem_data : alu_result;
    
endmodule