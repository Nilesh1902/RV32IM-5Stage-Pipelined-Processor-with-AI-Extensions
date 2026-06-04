// ============================================================
// Testbench: Fetch Stage
// Tests: PC reset, sequential increment, and instruction fetching.
// ============================================================

`timescale 1ns/1ps
module fetch_stage_tb;
    wire [31:0] instr;
    reg clk, reset;
    
    // Instantiate fetch_stage module
    fetch_stage f1(instr, reset, clk);
    
    // Internal wires for monitoring (hierarchical access)
    wire [31:0] pc_out  = f1.pc_out;
    wire [31:0] next_pc = f1.next_pc;
    
    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;
    
    integer pass_count = 0;
    integer fail_count = 0;
    
    initial begin
        $display("==============================================");
        $display("        Fetch Stage Testbench Start");
        $display("==============================================");
        
        // Test 1: Asynchronous reset
        reset = 1;
        #10;  // Wait for reset
        if (pc_out == 32'b0) begin
            $display("? PASS: PC reset to 0 correctly (pc_out = %h)", pc_out);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: PC reset failed (pc_out = %h, expected 0)", pc_out);
            fail_count = fail_count + 1;
            $stop;
        end
        
        // Test 2: Release reset and check sequential fetch
        reset = 0;
        $display("\nTime\tPC_OUT\t\tNEXT_PC\t\tINSTR\t\tExpected");
        #5;  // Align with clock
        repeat (4) begin  // Test first 4 instructions from instr_mem
            #10;
            case (pc_out)
                32'd0: if (instr == 32'h00000093) begin
                    $display("%0t\t%h\t%h\t%h\tADDI x1,x0,0 ? PASS", $time, pc_out, next_pc, instr);
                    pass_count = pass_count + 1;
                end else begin
                    $display("%0t\t%h\t%h\t%h\tADDI x1,x0,0 ? FAIL", $time, pc_out, next_pc, instr);
                    fail_count = fail_count + 1;
                end
                32'd4: if (instr == 32'h00100113) begin
                    $display("%0t\t%h\t%h\t%h\tADDI x2,x0,1 ? PASS", $time, pc_out, next_pc, instr);
                    pass_count = pass_count + 1;
                end else begin
                    $display("%0t\t%h\t%h\t%h\tADDI x2,x0,1 ? FAIL", $time, pc_out, next_pc, instr);
                    fail_count = fail_count + 1;
                end
                32'd8: if (instr == 32'h002081B3) begin
                    $display("%0t\t%h\t%h\t%h\tADD x3,x1,x2 ? PASS", $time, pc_out, next_pc, instr);
                    pass_count = pass_count + 1;
                end else begin
                    $display("%0t\t%h\t%h\t%h\tADD x3,x1,x2 ? FAIL", $time, pc_out, next_pc, instr);
                    fail_count = fail_count + 1;
                end
                32'd12: if (instr == 32'h00000013) begin
                    $display("%0t\t%h\t%h\t%h\tNOP ? PASS", $time, pc_out, next_pc, instr);
                    pass_count = pass_count + 1;
                end else begin
                    $display("%0t\t%h\t%h\t%h\tNOP ? FAIL", $time, pc_out, next_pc, instr);
                    fail_count = fail_count + 1;
                end
                default: $display("%0t\t%h\t%h\t%h\tUnknown", $time, pc_out, next_pc, instr);
            endcase
        end
        
        // Test 3: PC increment pattern
        if (next_pc == pc_out + 4) begin
            $display("? PASS: PC increment working correctly (next_pc = pc_out + 4)");
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: PC increment logic error (next_pc = %h, expected %h)", next_pc, pc_out + 4);
            fail_count = fail_count + 1;
        end
        
        // Test 4: Reset during operation
        reset = 1;
        #10;
        if (pc_out == 32'b0) begin
            $display("? PASS: Async reset during operation works (pc_out = %h)", pc_out);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: Async reset failed (pc_out = %h)", pc_out);
            fail_count = fail_count + 1;
        end
        
        $display("==============================================");
        $display("Fetch Stage Test Summary: Passed=%0d, Failed=%0d", pass_count, fail_count);
        if (fail_count == 0) begin
            $display("SUCCESS: All tests passed!");
        end else begin
            $display("ERROR: Some tests failed. Check logic.");
        end
        $display("==============================================");
        $display("        Fetch Stage Testbench End");
        $display("==============================================");
        $stop;
    end
endmodule