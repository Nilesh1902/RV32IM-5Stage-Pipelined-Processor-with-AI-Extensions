// ============================================================
// Testbench: Register File
// Tests: Reads, writes, x0 hardwiring, and edge cases.
// ============================================================

`timescale 1ns/1ps
module regfile_tb;
    wire [31:0] rd1, rd2;
    reg clk, we;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] wd;
    
    // Instantiate regfile module
    regfile r1(rd1, rd2, wd, rd, rs1, rs2, we, clk);
    
    integer pass_count = 0;
    integer fail_count = 0;
    
    initial begin
        $display("---- Register File Testbench Start ----");
        clk = 0; we = 0;
        rd = 0; wd = 0;
        rs1 = 0; rs2 = 0;
    end
    
    always #5 clk = ~clk;
    
    initial begin
        // Test 1: Write to x1 and read back
        we = 1; rd = 5'd1; wd = 32'd25; #10;
        we = 0; rs1 = 5'd1; #10;
        if (rd1 == 32'd25) begin
            $display("? PASS: Write/Read x1 = %d", rd1);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: Write/Read x1 = %d (expected 25)", rd1);
            fail_count = fail_count + 1;
        end
        
        // Test 2: Write to x2 and read both x1 and x2
        we = 1; rd = 5'd2; wd = 32'd50; rs1 = 5'd1; rs2 = 5'd2; #10;
        we = 0; #10;
        if (rd1 == 32'd25 && rd2 == 32'd50) begin
            $display("? PASS: Read x1=%d, x2=%d", rd1, rd2);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: Read x1=%d (expected 25), x2=%d (expected 50)", rd1, rd2);
            fail_count = fail_count + 1;
        end
        
        // Test 3: x0 hardwiring (read should be 0)
        rs1 = 5'd0; rs2 = 5'd0; #10;
        if (rd1 == 32'd0 && rd2 == 32'd0) begin
            $display("? PASS: x0 read = %d (hardwired to 0)", rd1);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: x0 read = %d (expected 0)", rd1);
            fail_count = fail_count + 1;
        end
        
        // Test 4: Attempt to write to x0 (should not change)
        we = 1; rd = 5'd0; wd = 32'd999; rs1 = 5'd0; #10;
        we = 0; #10;
        if (rd1 == 32'd0) begin
            $display("? PASS: Write to x0 ignored, x0 = %d", rd1);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: Write to x0 succeeded, x0 = %d (expected 0)", rd1);
            fail_count = fail_count + 1;
        end
        
        // Test 5: Simultaneous read/write to different registers
        we = 1; rd = 5'd3; wd = 32'd100; rs1 = 5'd1; rs2 = 5'd3; #10;
        we = 0; #10;
        if (rd1 == 32'd25 && rd2 == 32'd100) begin
            $display("? PASS: Simultaneous read x1=%d, write/read x3=%d", rd1, rd2);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: Simultaneous ops failed", rd1, rd2);
            fail_count = fail_count + 1;
        end
        
        // Test 6: Edge case - Read uninitialized register (should be 0)
        rs1 = 5'd31; #10;
        if (rd1 == 32'd0) begin
            $display("? PASS: Uninitialized x31 = %d", rd1);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: Uninitialized x31 = %d (expected 0)", rd1);
            fail_count = fail_count + 1;
        end
        
        $display("---- Testbench Summary: Passed=%0d, Failed=%0d ----", pass_count, fail_count);
        if (fail_count == 0) begin
            $display("SUCCESS: All tests passed!");
        end else begin
            $display("ERROR: Some tests failed. Check logic.");
        end
        $display("---- Register File Testbench End ----");
        $stop;
    end
endmodule