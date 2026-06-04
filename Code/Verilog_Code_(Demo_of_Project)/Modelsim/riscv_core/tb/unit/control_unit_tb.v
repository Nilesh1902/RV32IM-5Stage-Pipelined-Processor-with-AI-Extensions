// ============================================================
// Testbench: Control Unit
// Tests: Control signal generation for various RV32I opcodes.
// ============================================================

`timescale 1ns/1ps
module control_unit_tb;
    reg [6:0] opcode;
    wire Branch, MemRead, MemtoReg, ALUOp1, ALUOp0, MemWrite, ALUSrc, RegWrite;
    
    // Instantiate control_unit module
    control_unit c1(Branch, MemRead, MemtoReg, ALUOp1, ALUOp0, MemWrite, ALUSrc, RegWrite, opcode);
    
    integer pass_count = 0;
    integer fail_count = 0;
    
    initial begin
        $display("---- Control Unit Testbench Start ----");
        
        // Test 1: R-type
        opcode = 7'b0110011; #10;
        $display("R-type: Branch=%b MemRead=%b MemtoReg=%b ALUOp=%b%b MemWrite=%b ALUSrc=%b RegWrite=%b",
                 Branch, MemRead, MemtoReg, ALUOp1, ALUOp0, MemWrite, ALUSrc, RegWrite);
        if (Branch==0 && MemRead==0 && MemtoReg==0 && ALUOp1==1 && ALUOp0==0 && MemWrite==0 && ALUSrc==0 && RegWrite==1) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        // Test 2: I-type
        opcode = 7'b0010011; #10;
        $display("I-type: Branch=%b MemRead=%b MemtoReg=%b ALUOp=%b%b MemWrite=%b ALUSrc=%b RegWrite=%b",
                 Branch, MemRead, MemtoReg, ALUOp1, ALUOp0, MemWrite, ALUSrc, RegWrite);
        if (Branch==0 && MemRead==0 && MemtoReg==0 &&
            ALUOp1==1 && ALUOp0==0 &&   // <- changed from 00 to 10
            MemWrite==0 && ALUSrc==1 && RegWrite==1) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        // Test 3: Load
        opcode = 7'b0000011; #10;
        $display("Load:   Branch=%b MemRead=%b MemtoReg=%b ALUOp=%b%b MemWrite=%b ALUSrc=%b RegWrite=%b",
                 Branch, MemRead, MemtoReg, ALUOp1, ALUOp0, MemWrite, ALUSrc, RegWrite);
        if (Branch==0 && MemRead==1 && MemtoReg==1 && ALUOp1==0 && ALUOp0==0 && MemWrite==0 && ALUSrc==1 && RegWrite==1) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        // Test 4: Store
        opcode = 7'b0100011; #10;
        $display("Store:  Branch=%b MemRead=%b MemtoReg=%b ALUOp=%b%b MemWrite=%b ALUSrc=%b RegWrite=%b",
                 Branch, MemRead, MemtoReg, ALUOp1, ALUOp0, MemWrite, ALUSrc, RegWrite);
        if (Branch==0 && MemRead==0 && MemtoReg==0 && ALUOp1==0 && ALUOp0==0 && MemWrite==1 && ALUSrc==1 && RegWrite==0) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        // Test 5: Branch
        opcode = 7'b1100011; #10;
        $display("Branch: Branch=%b MemRead=%b MemtoReg=%b ALUOp=%b%b MemWrite=%b ALUSrc=%b RegWrite=%b",
                 Branch, MemRead, MemtoReg, ALUOp1, ALUOp0, MemWrite, ALUSrc, RegWrite);
        if (Branch==1 && MemRead==0 && MemtoReg==0 && ALUOp1==0 && ALUOp0==1 && MemWrite==0 && ALUSrc==0 && RegWrite==0) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        // Test 6: JAL
        opcode = 7'b1101111; #10;
        $display("JAL:    Branch=%b MemRead=%b MemtoReg=%b ALUOp=%b%b MemWrite=%b ALUSrc=%b RegWrite=%b",
                 Branch, MemRead, MemtoReg, ALUOp1, ALUOp0, MemWrite, ALUSrc, RegWrite);
        if (Branch==1 && MemRead==0 && MemtoReg==0 && ALUOp1==0 && ALUOp0==0 && MemWrite==0 && ALUSrc==1 && RegWrite==1) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        // Test 7: JALR
        opcode = 7'b1100111; #10;
        $display("JALR:   Branch=%b MemRead=%b MemtoReg=%b ALUOp=%b%b MemWrite=%b ALUSrc=%b RegWrite=%b",
                 Branch, MemRead, MemtoReg, ALUOp1, ALUOp0, MemWrite, ALUSrc, RegWrite);
        if (Branch==1 && MemRead==0 && MemtoReg==0 && ALUOp1==0 && ALUOp0==0 && MemWrite==0 && ALUSrc==1 && RegWrite==1) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        // Test 8: LUI
        opcode = 7'b0110111; #10;
        $display("LUI:    Branch=%b MemRead=%b MemtoReg=%b ALUOp=%b%b MemWrite=%b ALUSrc=%b RegWrite=%b",
                 Branch, MemRead, MemtoReg, ALUOp1, ALUOp0, MemWrite, ALUSrc, RegWrite);
        if (Branch==0 && MemRead==0 && MemtoReg==0 && ALUOp1==0 && ALUOp0==0 && MemWrite==0 && ALUSrc==1 && RegWrite==1) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        // Test 9: AUIPC
        opcode = 7'b0010111; #10;
        $display("AUIPC:  Branch=%b MemRead=%b MemtoReg=%b ALUOp=%b%b MemWrite=%b ALUSrc=%b RegWrite=%b",
                 Branch, MemRead, MemtoReg, ALUOp1, ALUOp0, MemWrite, ALUSrc, RegWrite);
        if (Branch==0 && MemRead==0 && MemtoReg==0 && ALUOp1==0 && ALUOp0==0 && MemWrite==0 && ALUSrc==1 && RegWrite==1) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        // Test 10: Default
        opcode = 7'b1111111; #10;
        $display("Default: Branch=%b MemRead=%b MemtoReg=%b ALUOp=%b%b MemWrite=%b ALUSrc=%b RegWrite=%b",
                 Branch, MemRead, MemtoReg, ALUOp1, ALUOp0, MemWrite, ALUSrc, RegWrite);
        if (Branch==0 && MemRead==0 && MemtoReg==0 && ALUOp1==0 && ALUOp0==0 && MemWrite==0 && ALUSrc==0 && RegWrite==0) begin
            $display("? PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL");
            fail_count = fail_count + 1;
        end
        
        $display("---- Testbench Summary: Passed=%0d, Failed=%0d ----", pass_count, fail_count);
        if (fail_count == 0) begin
            $display("SUCCESS: All tests passed!");
        end else begin
            $display("ERROR: Some tests failed. Check logic.");
        end
        $display("---- Control Unit Testbench End ----");
        $stop;
    end
endmodule