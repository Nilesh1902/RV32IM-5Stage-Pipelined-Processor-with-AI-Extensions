`timescale 1ns/1ps
// ============================================================
// Testbench: ALU Control Unit
// Tests: Control signal decoding for various operations.
// ============================================================

module alu_control_tb();
    wire [3:0] ALUCtrl;
    reg  [1:0] ALUOp;
    reg  [2:0] funct3;
    reg  [6:0] funct7;
    
    // Instantiate alu_control module
    alu_control ac1(ALUCtrl, ALUOp, funct3, funct7);
    
    integer pass_count = 0;
    integer fail_count = 0;
    
    initial begin
        $display("---- ALU Control Testbench Start ----");
        
        // Test 1: Load/Store -> ADD
        ALUOp = 2'b00; funct3 = 3'b000; funct7 = 7'b0000000;
        #10;
        if (ALUCtrl == 4'b0010) begin
            $display("? PASS: Load/Store ALUCtrl=%b (Expected: 0010)", ALUCtrl);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: Load/Store ALUCtrl=%b (Expected: 0010)", ALUCtrl);
            fail_count = fail_count + 1;
        end
        
        // Test 2: Branch -> SUB
        ALUOp = 2'b01; funct3 = 3'b000; funct7 = 7'b0000000;
        #10;
        if (ALUCtrl == 4'b0110) begin
            $display("? PASS: Branch ALUCtrl=%b (Expected: 0110)", ALUCtrl);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: Branch ALUCtrl=%b (Expected: 0110)", ALUCtrl);
            fail_count = fail_count + 1;
        end
        
        // Test 3: R-type ADD
        ALUOp = 2'b10; funct3 = 3'b000; funct7 = 7'b0000000;
        #10;
        if (ALUCtrl == 4'b0010) begin
            $display("? PASS: R-type ADD ALUCtrl=%b (Expected: 0010)", ALUCtrl);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: R-type ADD ALUCtrl=%b (Expected: 0010)", ALUCtrl);
            fail_count = fail_count + 1;
        end
        
        // Test 4: R-type SUB
        ALUOp = 2'b10; funct3 = 3'b000; funct7 = 7'b0100000;
        #10;
        if (ALUCtrl == 4'b0110) begin
            $display("? PASS: R-type SUB ALUCtrl=%b (Expected: 0110)", ALUCtrl);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: R-type SUB ALUCtrl=%b (Expected: 0110)", ALUCtrl);
            fail_count = fail_count + 1;
        end
        
        // Test 5: R-type AND
        ALUOp = 2'b10; funct3 = 3'b111; funct7 = 7'b0000000;
        #10;
        if (ALUCtrl == 4'b0000) begin
            $display("? PASS: R-type AND ALUCtrl=%b (Expected: 0000)", ALUCtrl);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: R-type AND ALUCtrl=%b (Expected: 0000)", ALUCtrl);
            fail_count = fail_count + 1;
        end
        
        // Test 6: R-type OR
        ALUOp = 2'b10; funct3 = 3'b110; funct7 = 7'b0000000;
        #10;
        if (ALUCtrl == 4'b0001) begin
            $display("? PASS: R-type OR ALUCtrl=%b (Expected: 0001)", ALUCtrl);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: R-type OR ALUCtrl=%b (Expected: 0001)", ALUCtrl);
            fail_count = fail_count + 1;
        end
        
        // Test 7: R-type SLT
        ALUOp = 2'b10; funct3 = 3'b010; funct7 = 7'b0000000;
        #10;
        if (ALUCtrl == 4'b0111) begin
            $display("? PASS: R-type SLT ALUCtrl=%b (Expected: 0111)", ALUCtrl);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: R-type SLT ALUCtrl=%b (Expected: 0111)", ALUCtrl);
            fail_count = fail_count + 1;
        end
        
        // Test 8: R-type XOR
        ALUOp = 2'b10; funct3 = 3'b100; funct7 = 7'b0000000;
        #10;
        if (ALUCtrl == 4'b0100) begin
            $display("? PASS: R-type XOR ALUCtrl=%b (Expected: 0100)", ALUCtrl);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: R-type XOR ALUCtrl=%b (Expected: 0100)", ALUCtrl);
            fail_count = fail_count + 1;
        end
        
        // Test 9: R-type SLL
        ALUOp = 2'b10; funct3 = 3'b001; funct7 = 7'b0000000;
        #10;
        if (ALUCtrl == 4'b1000) begin
            $display("? PASS: R-type SLL ALUCtrl=%b (Expected: 1000)", ALUCtrl);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: R-type SLL ALUCtrl=%b (Expected: 1000)", ALUCtrl);
            fail_count = fail_count + 1;
        end
        
        // Test 10: R-type SRL
        ALUOp = 2'b10; funct3 = 3'b101; funct7 = 7'b0000000;
        #10;
        if (ALUCtrl == 4'b1001) begin
            $display("? PASS: R-type SRL ALUCtrl=%b (Expected: 1001)", ALUCtrl);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: R-type SRL ALUCtrl=%b (Expected: 1001)", ALUCtrl);
            fail_count = fail_count + 1;
        end

        // Test 11: R-type SLTU (funct3=011, funct7=0000000)
        ALUOp = 2'b10; funct3 = 3'b011; funct7 = 7'b0000000;
        #10;
        if (ALUCtrl == 4'b1010) begin
            $display("? PASS: R-type SLTU ALUCtrl=%b (Expected: 1010)", ALUCtrl);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: R-type SLTU ALUCtrl=%b (Expected: 1010)", ALUCtrl);
            fail_count = fail_count + 1;
        end

        // Test 12: R-type SRA (funct3=101, funct7=0100000)
        ALUOp = 2'b10; funct3 = 3'b101; funct7 = 7'b0100000;
        #10;
        if (ALUCtrl == 4'b1011) begin
            $display("? PASS: R-type SRA ALUCtrl=%b (Expected: 1011)", ALUCtrl);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: R-type SRA ALUCtrl=%b (Expected: 1011)", ALUCtrl);
            fail_count = fail_count + 1;
        end
        
        // Test 13: Default
        ALUOp = 2'b11; funct3 = 3'b000; funct7 = 7'b0000000;
        #10;
        if (ALUCtrl == 4'b1111) begin
            $display("? PASS: Default ALUCtrl=%b (Expected: 1111)", ALUCtrl);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: Default ALUCtrl=%b (Expected: 1111)", ALUCtrl);
            fail_count = fail_count + 1;
        end
        
        $display("---- Testbench Summary: Passed=%0d, Failed=%0d ----", pass_count, fail_count);
        if (fail_count == 0) begin
            $display("SUCCESS: All tests passed!");
        end else begin
            $display("ERROR: Some tests failed. Check logic.");
        end
        $display("---- ALU Control Testbench End ----");
        $stop;
    end
endmodule
