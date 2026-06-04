// ============================================================
// Testbench: Decode Stage
// Tests: Field extraction for various RISC-V instruction types.
// ============================================================

`timescale 1ns/1ps
module decode_stage_tb;
    wire [6:0] opcode;
    wire [4:0] rd, rs1, rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;
    reg [31:0] instr;
    
    // Instantiate decode_stage module
    decode_stage d1(opcode, rd, funct3, rs1, rs2, funct7, instr);
    
    integer pass_count = 0;
    integer fail_count = 0;
    
    initial begin
        $display("===============================================");
        $display("         Decode Stage Testbench Start           ");
        $display("===============================================");
        
        // ----------------------------
        // Test 1: R-type ADD x3, x1, x2
        // ----------------------------
        instr = 32'b0000000_00010_00001_000_00011_0110011;
        #10;
        $display("\n[ R-type ADD ]");
        $display("INSTR = %b", instr);
        $display("opcode=%b, rd=%d, rs1=%d, rs2=%d, funct3=%b, funct7=%b",
                  opcode, rd, rs1, rs2, funct3, funct7);
        
        if (opcode == 7'b0110011 && rd == 3 && rs1 == 1 && rs2 == 2 && funct3 == 3'b000 && funct7 == 7'b0000000) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        // ----------------------------
        // Test 2: I-type ADDI x1, x0, 5
        // ----------------------------
        instr = 32'b000000000101_00000_000_00001_0010011;
        #10;
        $display("\n[ I-type ADDI ]");
        $display("INSTR = %b", instr);
        $display("opcode=%b, rd=%d, rs1=%d, rs2=%d, funct3=%b, funct7=%b",
                  opcode, rd, rs1, rs2, funct3, funct7);
        
        if (opcode == 7'b0010011 && rd == 1 && rs1 == 0 && funct3 == 3'b000) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        // ----------------------------
        // Test 3: R-type SUB x4, x2, x1
        // ----------------------------
        instr = 32'b0100000_00001_00010_000_00100_0110011;
        #10;
        $display("\n[ R-type SUB ]");
        $display("INSTR = %b", instr);
        $display("opcode=%b, rd=%d, rs1=%d, rs2=%d, funct3=%b, funct7=%b",
                  opcode, rd, rs1, rs2, funct3, funct7);
        
        if (opcode == 7'b0110011 && rd == 4 && rs1 == 2 && rs2 == 1 && funct3 == 3'b000 && funct7 == 7'b0100000) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        // ----------------------------
        // Test 4: Load LW x5, 0(x1)
        // ----------------------------
        instr = 32'b000000000000_00001_010_00101_0000011;
        #10;
        $display("\n[ I-type LW ]");
        $display("INSTR = %b", instr);
        $display("opcode=%b, rd=%d, rs1=%d, rs2=%d, funct3=%b, funct7=%b",
                  opcode, rd, rs1, rs2, funct3, funct7);
        
        if (opcode == 7'b0000011 && rd == 5 && rs1 == 1 && funct3 == 3'b010) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        // ----------------------------
        // Test 5: Store SW x2, 8(x1)
        // ----------------------------
        instr = 32'b0000000_00010_00001_010_01000_0100011;
        #10;
        $display("\n[ S-type SW ]");
        $display("INSTR = %b", instr);
        $display("opcode=%b, rd=%d, rs1=%d, rs2=%d, funct3=%b, funct7=%b",
                  opcode, rd, rs1, rs2, funct3, funct7);
        
        if (opcode == 7'b0100011 && rs1 == 1 && rs2 == 2 && funct3 == 3'b010) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        // ----------------------------
        // Test 6: Branch BEQ x1, x2, 16
        // ----------------------------
        instr = 32'b0000000_00010_00001_000_10000_1100011;
        #10;
        $display("\n[ B-type BEQ ]");
        $display("INSTR = %b", instr);
        $display("opcode=%b, rd=%d, rs1=%d, rs2=%d, funct3=%b, funct7=%b",
                  opcode, rd, rs1, rs2, funct3, funct7);
        
        if (opcode == 7'b1100011 && rs1 == 1 && rs2 == 2 && funct3 == 3'b000) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        // ----------------------------
        // Test 7: Jump JAL x0, 32
        // ----------------------------
        instr = 32'b00000001000000000000_00000_1101111;
        #10;
        $display("\n[ J-type JAL ]");
        $display("INSTR = %b", instr);
        $display("opcode=%b, rd=%d, rs1=%d, rs2=%d, funct3=%b, funct7=%b",
                  opcode, rd, rs1, rs2, funct3, funct7);
        
        if (opcode == 7'b1101111 && rd == 0) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        // ----------------------------
        // Test 8: Edge case - All-zero instruction
        // ----------------------------
        instr = 32'b0;
        #10;
        $display("\n[ Edge Case: All-Zero ]");
        $display("INSTR = %b", instr);
        $display("opcode=%b, rd=%d, rs1=%d, rs2=%d, funct3=%b, funct7=%b",
                  opcode, rd, rs1, rs2, funct3, funct7);
        
        if (opcode == 7'b0 && rd == 0 && rs1 == 0 && rs2 == 0 && funct3 == 3'b0 && funct7 == 7'b0) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        // ----------------------------
        // Summary
        // ----------------------------
        $display("\n===============================================");
        $display("Decode Stage Test Summary:");
        $display("  ? Passed: %0d", pass_count);
        $display("  ? Failed: %0d", fail_count);
        if (fail_count == 0) begin
            $display("SUCCESS: All tests passed!");
        end else begin
            $display("ERROR: Some tests failed. Check logic.");
        end
        $display("===============================================");
        $display("         Decode Stage Testbench End             ");
        $display("===============================================");
        $stop;
    end
endmodule