// ============================================================
// Module: Execute Stage
// Function: Performs ALU operations with operand mux and zero flag.
// Inputs : read_data1/rs2 (from regfile), imm_out (from imm_gen),
//          ALUOp/ALUSrc (from control), funct3/funct7 (from decode)
// Outputs: ALU_result (to memory/writeback), zero (to control for branches)
// Notes  : Mux selects between reg2 and immediate. ALU control decodes operation.
//          Synthesis: Pure combinational logic.
// ============================================================

`timescale 1ns/1ps
module execute_stage(
    output [31:0] ALU_result,           // ALU output result
    output zero,                        // Zero flag for branch
    input [31:0] read_data1,            // Register rs1 value
    input [31:0] read_data2,            // Register rs2 value
    input [31:0] imm_out,               // Immediate value
    input [1:0] ALUOp,                  // ALU operation type (from Control Unit)
    input ALUSrc,                       // 1 = use immediate, 0 = use reg2
    input [6:0] funct7,                 // From instruction [31:25]
    input [2:0] funct3                  // From instruction [14:12]
);
    
    wire [31:0] ALU_operand2;   // Mux output
    wire [3:0] ALUCtrl;         // From ALU Control Unit
    
    // Operand Mux: Choose between register and immediate
    assign ALU_operand2 = (ALUSrc) ? imm_out : read_data2;
    
    // ALU Control Unit
    alu_control ALU_CTRL_UNIT (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUCtrl(ALUCtrl)
    );
    
    // ALU Operation
    alu ALU_MAIN (
        .a(read_data1),
        .b(ALU_operand2),
        .alu_control(ALUCtrl),
        .result(ALU_result),
        .zero(zero)
    );
    
endmodule