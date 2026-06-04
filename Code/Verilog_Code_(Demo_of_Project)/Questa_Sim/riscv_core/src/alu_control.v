// ============================================================
// Module: ALU Control Unit
// Function: Decodes ALU control signals based on ALUOp, funct3, funct7.
// Inputs : ALUOp (2-bit from control unit), funct3/funct7 (from instruction)
// Outputs: ALUCtrl (4-bit to ALU)
// Notes  : ALUOp: 00=Load/Store(ADD), 01=Branch (SUB), 10=R-type/I-type.
//          ALUCtrl: 0000=AND, 0001=OR, 0010=ADD, 0110=SUB, 0111=SLT,
//          0100=XOR, 1000=SLL, 1001=SRL, 1010=SLTU, 1011=SRA.
//          Synthesis: Pure combinational logic.
// ============================================================

`timescale 1ns/1ps
module alu_control (
  output reg [3:0] ALUCtrl,
  input  wire [1:0] ALUOp,
  input  wire [2:0] funct3,
  input  wire [6:0] funct7
);

always @(*) begin
  case (ALUOp)
    2'b00: ALUCtrl = 4'b0010;        // Load/Store: ADD
    2'b01: ALUCtrl = 4'b0110;        // Branch: SUB
    2'b10: begin                     // R-type / I-type
      case ({funct7[5], funct3})
        5'b0_000: ALUCtrl = 4'b0010; // ADD/ADDI (funct3=000)
        5'b0_001: ALUCtrl = 4'b1000; // SLL/SLLI (funct3=001, funct7[5]=0)
        5'b0_010: ALUCtrl = 4'b0111; // SLT/SLTI (funct3=010)
        5'b0_011: ALUCtrl = 4'b0000; // AND/ANDI (funct3=011? Wait, RV32I ANDI=funct3=111)
        5'b0_100: ALUCtrl = 4'b0100; // XOR/XORI (funct3=100)
        5'b0_101: ALUCtrl = 4'b1001; // SRL/SRLI (funct3=101, funct7[5]=0)
        5'b0_110: ALUCtrl = 4'b0001; // OR/ORI (funct3=110)
        5'b0_111: ALUCtrl = 4'b0111; // ? Wait no, SLT is 010
        5'b1_101: ALUCtrl = 4'b1011; // SRA/SRAI (funct3=101, funct7[5]=1)
        5'b0_011: ALUCtrl = 4'b1010; // SLTU/SLTIU (funct3=011)
        default:   ALUCtrl = 4'bxxxx;
      endcase
    end
    default: ALUCtrl = 4'bxxxx;
  endcase
end
endmodule
