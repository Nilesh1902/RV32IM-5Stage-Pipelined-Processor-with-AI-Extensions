// ============================================================
// Testbench: Program Counter (PC)
// Tests: Reset behavior, synchronous updates, and basic increment.
// ============================================================

`timescale 1ns/1ps
module pc_tb;
    wire [31:0] pc_out;
    reg [31:0] next_pc;
    reg clk, reset;
    
    // Instantiate PC module
    pc p1(pc_out, next_pc, clk, reset);
    
    // Clock generation: 10ns period (100MHz)
    initial begin
        clk = 1'b0;
    end
    always begin
        #5 clk = ~clk;
    end
    
    initial begin
        $display("---- Starting PC Testbench ----");
        
        // Test 1: Asynchronous reset
        reset = 1;
        next_pc = 32'd0;  // Irrelevant during reset
        #10;  // Wait for reset to take effect
        if (pc_out == 32'b0) begin
            $display("? PASS: PC reset to 0 correctly (pc_out = %h)", pc_out);
        end else begin
            $display("? FAIL: PC reset failed (pc_out = %h, expected 0)", pc_out);
        end
        
        // Test 2: Synchronous update after reset
        reset = 0;
        next_pc = 32'd4;
        #10;  // One clock cycle
        if (pc_out == 32'd4) begin
            $display("? PASS: PC updated to 4 (pc_out = %h)", pc_out);
        end else begin
            $display("? FAIL: PC update failed (pc_out = %h, expected 4)", pc_out);
        end
        
        next_pc = 32'd8;
        #10;
        if (pc_out == 32'd8) begin
            $display("? PASS: PC updated to 8 (pc_out = %h)", pc_out);
        end else begin
            $display("? FAIL: PC update failed (pc_out = %h, expected 8)", pc_out);
        end
        
        next_pc = 32'd12;
        #10;
        if (pc_out == 32'd12) begin
            $display("? PASS: PC updated to 12 (pc_out = %h)", pc_out);
        end else begin
            $display("? FAIL: PC update failed (pc_out = %h, expected 12)", pc_out);
        end
        
        // Test 3: Reset during operation (async check)
        next_pc = 32'd16;
        #5 reset = 1;  // Assert reset mid-cycle
        #5;  // Complete cycle
        if (pc_out == 32'b0) begin
            $display("? PASS: Async reset works during operation (pc_out = %h)", pc_out);
        end else begin
            $display("? FAIL: Async reset failed (pc_out = %h, expected 0)", pc_out);
        end
        
        $display("---- PC Testbench Complete ----");
        $stop;
    end
endmodule