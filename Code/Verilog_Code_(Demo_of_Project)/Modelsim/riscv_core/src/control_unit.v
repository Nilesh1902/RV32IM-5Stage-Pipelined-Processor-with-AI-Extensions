// ============================================================
// Module: Control Unit
// Function: Generates control signals based on opcode for RV32I instructions.
// Inputs : opcode (7-bit from decode stage)
// Outputs: Branch, MemRead, MemtoReg, ALUOp[1:0], MemWrite, ALUSrc, RegWrite
// Notes  : Combinational logic. ALUOp: 00=ADD, 01=SUB, 10=R-type.
//          For jumps, Branch is set to enable PC updates in top-level.
//          Synthesis: No latches or registers.
// ============================================================

// FIXED control_unit.v port list (match your original module exactly)
`timescale 1ns/1ps
module control_unit (
  output reg Branch,    // 1 for branch/jump instructions
  output reg MemRead,   // 1 for load instructions
  output reg MemtoReg,  // 1 to select memory data for reg write
  output reg ALUOp1,    // ALU operation control MSB  
  output reg ALUOp0,    // ALU operation control LSB
  output reg MemWrite,  // 1 for store instructions
  output reg ALUSrc,    // 1 to select immediate for ALU
  output reg RegWrite,  // 1 to enable register write
  input  wire [6:0] opcode  // Instruction opcode
);

always @(*) begin
  case (opcode)
    7'b0110011: begin  // R-type (ADD, SUB, AND, OR, SLT...)
      Branch   = 1'b0; MemRead = 1'b0; MemtoReg = 1'b0;
      ALUOp1   = 1'b1; ALUOp0  = 1'b0;  // 10: R-type/I-type ALU
      MemWrite = 1'b0; ALUSrc   = 1'b0; RegWrite = 1'b1;
    end
    7'b0010011: begin  // I-type ALU (ADDI, ORI, ANDI, SLTI, SLLI...)
      Branch   = 1'b0; MemRead = 1'b0; MemtoReg = 1'b0;
      ALUOp1   = 1'b1; ALUOp0  = 1'b0;  // 10: Uses funct3/funct7
      MemWrite = 1'b0; ALUSrc   = 1'b1; RegWrite = 1'b1;
    end
    7'b0000011: begin  // Load (LW)
      Branch   = 1'b0; MemRead = 1'b1; MemtoReg = 1'b1;
      ALUOp1   = 1'b0; ALUOp0  = 1'b0;  // 00: ADD
      MemWrite = 1'b0; ALUSrc   = 1'b1; RegWrite = 1'b1;
    end
    7'b0100011: begin  // Store (SW)
      Branch   = 1'b0; MemRead = 1'b0; MemtoReg = 1'b0;
      ALUOp1   = 1'b0; ALUOp0  = 1'b0;  // 00: ADD (don't care)
      MemWrite = 1'b1; ALUSrc   = 1'b1; RegWrite = 1'b0;
    end
    7'b1100011: begin  // Branch (BEQ, BNE...)
      Branch   = 1'b1; MemRead = 1'b0; MemtoReg = 1'b0;
      ALUOp1   = 1'b0; ALUOp0  = 1'b1;  // 01: SUB
      MemWrite = 1'b0; ALUSrc   = 1'b0; RegWrite = 1'b0;
    end
    7'b1101111: begin  // JAL
      Branch   = 1'b1; MemRead = 1'b0; MemtoReg = 1'b0;
      ALUOp1   = 1'b0; ALUOp0  = 1'b0;  // 00: ADD
      MemWrite = 1'b0; ALUSrc   = 1'b1; RegWrite = 1'b1;
    end
    7'b1100111: begin  // JALR
      Branch   = 1'b1; MemRead = 1'b0; MemtoReg = 1'b0;
      ALUOp1   = 1'b0; ALUOp0  = 1'b0;
      MemWrite = 1'b0; ALUSrc   = 1'b1; RegWrite = 1'b1;
    end
    7'b0110111: begin  // LUI
      Branch   = 1'b0; MemRead = 1'b0; MemtoReg = 1'b0;
      ALUOp1   = 1'b0; ALUOp0  = 1'b0;
      MemWrite = 1'b0; ALUSrc   = 1'b1; RegWrite = 1'b1;
    end
    7'b0010111: begin  // AUIPC
      Branch   = 1'b0; MemRead = 1'b0; MemtoReg = 1'b0;
      ALUOp1   = 1'b0; ALUOp0  = 1'b0;
      MemWrite = 1'b0; ALUSrc   = 1'b1; RegWrite = 1'b1;
    end
    default: begin
      Branch   = 1'b0; MemRead = 1'b0; MemtoReg = 1'b0;
      ALUOp1   = 1'b0; ALUOp0  = 1'b0;
      MemWrite = 1'b0; ALUSrc   = 1'b0; RegWrite = 1'b0;
    end
  endcase
end
endmodule
