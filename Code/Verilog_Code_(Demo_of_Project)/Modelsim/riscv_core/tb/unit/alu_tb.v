`timescale 1ns/1ps
// ============================================================
// Testbench: ALU
// Tests: Operations, zero flag, and edge cases including SLTU, SRA.
// ============================================================

module alu_tb;
    wire [31:0] result;
    wire        zero;
    reg  [31:0] a, b;
    reg  [3:0]  alu_control;
    
    // Instantiate alu module
    alu a1(result, zero, alu_control, a, b);
    
    integer pass_count = 0;
    integer fail_count = 0;
    
    initial begin
        $display("---- ALU Testbench Start ----");
        
        a = 10; b = 5;
        
        // Test 1: ADD
        alu_control = 4'b0010; #10;
        if (result == 15 && zero == 0) begin
            $display("? PASS: ADD %d + %d = %d, zero=%b", a, b, result, zero);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: ADD %d + %d = %d (expected 15), zero=%b", a, b, result, zero);
            fail_count = fail_count + 1;
        end
        
        // Test 2: SUB
        alu_control = 4'b0110; #10;
        if (result == 5 && zero == 0) begin
            $display("? PASS: SUB %d - %d = %d, zero=%b", a, b, result, zero);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: SUB %d - %d = %d (expected 5), zero=%b", a, b, result, zero);
            fail_count = fail_count + 1;
        end
        
        // Test 3: AND (10 & 5 = 0)
        alu_control = 4'b0000; #10;
        if (result == 0 && zero == 1) begin
            $display("? PASS: AND %d & %d = %d, zero=%b", a, b, result, zero);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: AND %d & %d = %d (expected 0), zero=%b", a, b, result, zero);
            fail_count = fail_count + 1;
        end
        
        // Test 4: OR (10 | 5 = 15)
        alu_control = 4'b0001; #10;
        if (result == 15 && zero == 0) begin
            $display("? PASS: OR %d | %d = %d, zero=%b", a, b, result, zero);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: OR %d | %d = %d (expected 15), zero=%b", a, b, result, zero);
            fail_count = fail_count + 1;
        end
        
        // Test 5: SLT (signed) 10 < 5 ? 0
        alu_control = 4'b0111; #10;
        if (result == 0 && zero == 1) begin
            $display("? PASS: SLT (%d < %d) = %d, zero=%b", a, b, result, zero);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: SLT (%d < %d) = %d (expected 0), zero=%b", a, b, result, zero);
            fail_count = fail_count + 1;
        end
        
        // Test 6: XOR (10 ^ 5 = 15)
        alu_control = 4'b0100; #10;
        if (result == 15 && zero == 0) begin
            $display("? PASS: XOR %d ^ %d = %d, zero=%b", a, b, result, zero);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: XOR %d ^ %d = %d (expected 15), zero=%b", a, b, result, zero);
            fail_count = fail_count + 1;
        end
        
        // Test 7: SLL (10 << 2 = 40)
        alu_control = 4'b1000; b = 2; #10;
        if (result == 40 && zero == 0) begin
            $display("? PASS: SLL %d << %d = %d, zero=%b", a, b, result, zero);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: SLL %d << %d = %d (expected 40), zero=%b", a, b, result, zero);
            fail_count = fail_count + 1;
        end
        
        // Test 8: SRL (10 >> 2 = 2)
        alu_control = 4'b1001; #10;
        if (result == 2 && zero == 0) begin
            $display("? PASS: SRL %d >> %d = %d, zero=%b", a, b, result, zero);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: SRL %d >> %d = %d (expected 2), zero=%b", a, b, result, zero);
            fail_count = fail_count + 1;
        end

        // Test 9: SLTU (unsigned) : (10 < 5) = 0
        a = 10; b = 5; alu_control = 4'b1010; #10;
        if (result == 0 && zero == 1) begin
            $display("? PASS: SLTU (%0d < %0d) = %0d (expected 0)", a, b, result);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: SLTU (%0d < %0d) = %0d (expected 0)", a, b, result);
            fail_count = fail_count + 1;
        end

        // SLTU where a<b
        a = 5; b = 10; alu_control = 4'b1010; #10;
        if (result == 1 && zero == 0) begin
            $display("? PASS: SLTU (%0d < %0d) = %0d (expected 1)", a, b, result);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: SLTU (%0d < %0d) = %0d (expected 1)", a, b, result);
            fail_count = fail_count + 1;
        end

        // Test 10: SRA (arithmetic): a = -8 (0xFFFFFFF8), >> 1 = -4
        a = -8; b = 1; alu_control = 4'b1011; #10;
        if (result == -4 && zero == 0) begin
            $display("? PASS: SRA %0d >>> %0d = %0d (expected -4)", a, b, result);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: SRA %0d >>> %0d = %0d (expected -4)", a, b, result);
            fail_count = fail_count + 1;
        end
        
        // Test 11: Edge case - Zero result
        a = 5; b = 5; alu_control = 4'b0110; #10;  // SUB
        if (result == 0 && zero == 1) begin
            $display("? PASS: Zero result %d - %d = %d, zero=%b", a, b, result, zero);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: Zero result %d - %d = %d, zero=%b", a, b, result, zero);
            fail_count = fail_count + 1;
        end
        
        $display("---- Testbench Summary: Passed=%0d, Failed=%0d ----", pass_count, fail_count);
        if (fail_count == 0) begin
            $display("SUCCESS: All tests passed!");
        end else begin
            $display("ERROR: Some tests failed. Check logic.");
        end
        $display("---- ALU Testbench End ----");
        $stop;
    end
endmodule
