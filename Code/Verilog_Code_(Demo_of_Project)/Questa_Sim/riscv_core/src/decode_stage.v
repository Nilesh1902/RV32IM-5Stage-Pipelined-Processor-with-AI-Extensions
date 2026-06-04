// ============================================================
// Module: Decode Stage
// Function: Extracts fields from a 32-bit RISC-V instruction for decoding.
//          Fields: opcode, rd, funct3, rs1, rs2, funct7 per RV32I spec.
// Inputs : instr (32-bit instruction)
// Outputs: opcode (7-bit), rd/rs1/rs2 (5-bit each), funct3 (3-bit), funct7 (7-bit)
// Notes  : Combinational logic. Used by control unit and ALU for instruction decoding.
//          Synthesis: No latches or registers.
// ============================================================

`timescale 1ns/1ps
module decode_stage(
    output wire [6:0] opcode,    // Instruction opcode [6:0]
    output wire [4:0] rd,        // Destination register [11:7]
    output wire [2:0] funct3,    // Function code 3 [14:12]
    output wire [4:0] rs1,       // Source register 1 [19:15]
    output wire [4:0] rs2,       // Source register 2 [24:20]
    output wire [6:0] funct7,    // Function code 7 [31:25]
    input wire [31:0] instr      // 32-bit instruction
);
    
    // Extract fields per RISC-V instruction format
    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign funct7 = instr[31:25];
    
endmodule