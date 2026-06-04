// ============================================================
// Testbench: Execute Stage
// Tests: ALU operations, operand mux, and zero flag.
// ============================================================

`timescale 1ns/1ps
module execute_stage_tb;
    wire [31:0] ALU_result;
    wire zero;
    reg [31:0] read_data1, read_data2, imm_out;
    reg [1:0] ALUOp;
    reg ALUSrc;
    reg [6:0] funct7;
    reg [2:0] funct3;
    
    // Instantiate execute_stage module
    execute_stage es1(
        .ALU_result(ALU_result),
        .zero(zero),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .imm_out(imm_out),
        .ALUOp(ALUOp),
        .ALUSrc(ALUSrc),
        .funct7(funct7),
        .funct3(funct3)
    );
    
    integer pass_count = 0;
    integer fail_count = 0;
    
    initial begin
        $display("---- Execute Stage Testbench Start ----");
        
        read_data1 = 10; read_data2 = 5; imm_out = 3;
        funct7 = 7'b0000000;
        
        // Test 1: ADD with register operands (ALUSrc=0)
        ALUOp = 2'b10; ALUSrc = 0; funct3 = 3'b000; #10;
        if (ALU_result == 15 && zero == 0) begin
            $display("? PASS: ADD reg %d + %d = %d, zero=%b", read_data1, read_data2, ALU_result, zero);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: ADD reg %d + %d = %d (expected 15), zero=%b", read_data1, read_data2, ALU_result, zero);
            fail_count = fail_count + 1;
        end
        
        // Test 2: ADD with immediate (ALUSrc=1)
        ALUOp = 2'b00; ALUSrc = 1; #10;  // ALUOp=00 for ADD in load/store
        if (ALU_result == 13 && zero == 0) begin
            $display("? PASS: ADD imm %d + %d = %d, zero=%b", read_data1, imm_out, ALU_result, zero);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: ADD imm %d + %d = %d (expected 13), zero=%b", read_data1, imm_out, ALU_result, zero);
            fail_count = fail_count + 1;
        end
        
        // Test 3: SUB (R-type)
        ALUOp = 2'b10; ALUSrc = 0; funct3 = 3'b000; funct7 = 7'b0100000; #10;
        if (ALU_result == 5 && zero == 0) begin
            $display("? PASS: SUB %d - %d = %d, zero=%b", read_data1, read_data2, ALU_result, zero);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: SUB %d - %d = %d (expected 5), zero=%b", read_data1, read_data2, ALU_result, zero);
            fail_count = fail_count + 1;
        end
        
        // Test 4: SLT (signed less than)
        ALUOp = 2'b10; ALUSrc = 0; funct3 = 3'b010; funct7 = 7'b0000000; #10;
        if (ALU_result == 0 && zero == 1) begin
            $display("? PASS: SLT (%d < %d) = %d, zero=%b", read_data1, read_data2, ALU_result, zero);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: SLT (%d < %d) = %d (expected 0), zero=%b", read_data1, read_data2, ALU_result, zero);
            fail_count = fail_count + 1;
        end
        
        // Test 5: Zero flag (SUB resulting in zero)
        read_data1 = 5; read_data2 = 5; ALUOp = 2'b10; ALUSrc = 0; funct3 = 3'b000; funct7 = 7'b0100000; #10;
        if (ALU_result == 0 && zero == 1) begin
            $display("? PASS: Zero flag %d - %d = %d, zero=%b", read_data1, read_data2, ALU_result, zero);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: Zero flag %d - %d = %d, zero=%b", read_data1, read_data2, ALU_result, zero);
            fail_count = fail_count + 1;
        end
        
        $display("---- Testbench Summary: Passed=%0d, Failed=%0d ----", pass_count, fail_count);
        if (fail_count == 0) begin
            $display("SUCCESS: All tests passed!");
        end else begin
            $display("ERROR: Some tests failed. Check logic.");
        end
        $display("---- Execute Stage Testbench End ----");
        $stop;
    end
endmodule