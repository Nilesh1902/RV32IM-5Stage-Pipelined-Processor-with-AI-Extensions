// ============================================================
// Module: Immediate Generator (imm_gen)
// Function: Extracts and sign-extends immediate values from RISC-V instructions.
//          Supports I-type, S-type, B-type, U-type, and J-type per RV32I spec.
// Inputs : instr (32-bit instruction)
// Outputs: imm_out (32-bit sign-extended immediate)
// Notes  : Sign-extension uses the MSB of the immediate field.
//          Default case returns 0 for unsupported opcodes.
//          Synthesis: Pure combinational logic.
// ============================================================

`timescale 1ns/1ps
module imm_gen(
    output reg [31:0] imm_out,    // Sign-extended immediate value
    input wire [31:0] instr       // 32-bit instruction
);
    
    always @(*) begin
        case (instr[6:0])  // Opcode-based decoding
            // I-type: Load (LW), Immediate Arithmetic (ADDI), JALR
            // Imm: bits [31:20], sign-extended to 32 bits
            7'b0000011,  // Load
            7'b0010011,  // Immediate arithmetic
            7'b1100111:  // JALR
                imm_out = {{20{instr[31]}}, instr[31:20]};
            
            // S-type: Store (SW)
            // Imm: bits [31:25|11:7], sign-extended to 32 bits
            7'b0100011:
                imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            
            // B-type: Branch (BEQ, BNE, etc.)
            // Imm: bits [31|7|30:25|11:8], shifted left by 1 (LSB=0), sign-extended
            7'b1100011:
                imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            
            // U-type: LUI, AUIPC
            // Imm: bits [31:12], shifted left by 12 (LSBs=0)
            7'b0110111,  // LUI
            7'b0010111:  // AUIPC
                imm_out = {instr[31:12], 12'b0};
            
            // J-type: JAL
            // Imm: bits [31|19:12|20|30:21], shifted left by 1 (LSB=0), sign-extended
            7'b1101111:
                imm_out = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            
            default:
                imm_out = 32'b0;  // Unsupported opcode: Return 0
        endcase
    end

endmodule