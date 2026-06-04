// ============================================================
// Testbench: Immediate Generator (imm_gen)
// Tests: Extraction and sign-extension for all RV32I immediate types,
//        including edge cases like negatives and defaults.
// ============================================================

`timescale 1ns/1ps
module imm_gen_tb;
    reg [31:0] instr;
    wire [31:0] imm_out;
    
    // Instantiate imm_gen module
    imm_gen i1(imm_out, instr);
    
    integer pass_count = 0;
    integer fail_count = 0;
    
    initial begin
        $display("---- Starting Immediate Generator Testbench ----");
        
        // Test 1: I-type ADDI (positive immediate)
        instr = 32'b000000000101_00000_000_00001_0010011;  // ADDI x1, x0, 5
        #10;
        if (imm_out == 32'd5) begin
            $display("? PASS: I-type ADDI -> imm = %0d (0x%h)", imm_out, imm_out);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: I-type ADDI -> imm = %0d (expected 5)", imm_out);
            fail_count = fail_count + 1;
        end
        
        // Test 2: I-type ADDI (negative immediate)
        instr = 32'b111111111000_00000_000_00001_0010011;  // ADDI x1, x0, -8
        #10;
        if (imm_out == -32'd8) begin
            $display("? PASS: I-type ADDI (neg) -> imm = %0d (0x%h)", imm_out, imm_out);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: I-type ADDI (neg) -> imm = %0d (expected -8)", imm_out);
            fail_count = fail_count + 1;
        end
        
        // Test 3: S-type SW
        instr = 32'b0000000_00010_00001_010_01000_0100011;  // SW x2, 8(x1)
        #10;
        if (imm_out == 32'd8) begin
            $display("? PASS: S-type SW -> imm = %0d (0x%h)", imm_out, imm_out);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: S-type SW -> imm = %0d (expected 8)", imm_out);
            fail_count = fail_count + 1;
        end
        
        // Test 4: B-type BEQ (corrected for offset 16)
        instr = 32'b0000000_00010_00001_000_10000_1100011;  // BEQ x1, x2, 16 (offset 16 bytes)
        #10;
        if (imm_out == 32'd16) begin
            $display("? PASS: B-type BEQ -> imm = %0d (0x%h)", imm_out, imm_out);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: B-type BEQ -> imm = %0d (expected 16)", imm_out);
            fail_count = fail_count + 1;
        end
        
        // Test 5: U-type LUI
        instr = 32'b00010010001101000101_00011_0110111;  // LUI x3, 0x12345
        #10;
        if (imm_out == 32'h12345000) begin
            $display("? PASS: U-type LUI -> imm = %0d (0x%h)", imm_out, imm_out);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: U-type LUI -> imm = %0d (expected 0x12345000)", imm_out);
            fail_count = fail_count + 1;
        end
        
        // Test 6: J-type JAL (corrected expectation: imm=16 for offset=32)
        instr = 32'b00000001000000000000_00000_1101111;  // JAL x0, 32 (offset 32 bytes, imm=16)
        #10;
        if (imm_out == 32'd16) begin
            $display("? PASS: J-type JAL -> imm = %0d (0x%h)", imm_out, imm_out);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: J-type JAL -> imm = %0d (expected 16)", imm_out);
            fail_count = fail_count + 1;
        end
        
        // Test 7: Default case (unsupported opcode)
        instr = 32'b11111111111111111111_11111_1111111;  // Invalid opcode
        #10;
        if (imm_out == 32'b0) begin
            $display("? PASS: Default -> imm = %0d (0x%h)", imm_out, imm_out);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: Default -> imm = %0d (expected 0)", imm_out);
            fail_count = fail_count + 1;
        end
        
        $display("---- Testbench Summary: Passed=%0d, Failed=%0d ----", pass_count, fail_count);
        if (fail_count == 0) begin
            $display("SUCCESS: All tests passed!");
        end else begin
            $display("ERROR: Some tests failed. Check logic.");
        end
        $stop;
    end
endmodule