// ===========================================================
// Testbench: Memory Stage
// Tests: Read/write operations, multiple accesses, and edge cases.
// ===========================================================

`timescale 1ns/1ps
module memory_stage_tb;
    reg clk;
    reg MemRead, MemWrite;
    reg [31:0] alu_result, write_data;
    wire [31:0] read_data;
    
    // Instantiate memory_stage module
    memory_stage m1(read_data, write_data, alu_result, MemWrite, MemRead, clk);
    
    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;
    
    integer pass = 0, fail = 0;
    
    initial begin
        $display("===============================================");
        $display("          Memory Stage Testbench Start          ");
        $display("===============================================");
        
        // Initialize
        MemRead = 0;
        MemWrite = 0;
        alu_result = 0;
        write_data = 0;
        #10;
        
        // Test 1: Write operation
        MemWrite = 1;
        alu_result = 32'h10;
        write_data = 32'hDEADBEEF;
        #10;  // Wait for write
        MemWrite = 0;
        $display("[Write] Addr=0x%h, Data=0x%h", alu_result, write_data);
        // Note: Internal check via read in next test
        
        // Test 2: Read operation
        MemRead = 1;
        #10;
        $display("[Read]  Addr=0x%h, Data_out=0x%h", alu_result, read_data);
        if (read_data == 32'hDEADBEEF) begin
            $display("? PASS: Read matches written data");
            pass = pass + 1;
        end else begin
            $display("? FAIL: Expected 0xDEADBEEF, Got 0x%h", read_data);
            fail = fail + 1;
        end
        MemRead = 0;
        
        // Test 3: Multiple writes and reads
        MemWrite = 1;
        alu_result = 32'h20;
        write_data = 32'h12345678;
        #10;
        MemWrite = 0;
        
        MemRead = 1;
        #10;
        if (read_data == 32'h12345678) begin
            $display("? PASS: Second write/read at addr 0x20");
            pass = pass + 1;
        end else begin
            $display("? FAIL: Second read failed, Got 0x%h", read_data);
            fail = fail + 1;
        end
        MemRead = 0;
        
        // Test 4: Read without MemRead (should be 0)
        MemRead = 0;
        #10;
        if (read_data == 32'b0) begin
            $display("? PASS: Read disabled returns 0");
            pass = pass + 1;
        end else begin
            $display("? FAIL: Read disabled returned 0x%h", read_data);
            fail = fail + 1;
        end
        
        // Test 5: Out-of-bounds address (masking test)
        MemWrite = 1;
        alu_result = 32'h100;  // >255, masks to 0
        write_data = 32'hABCDEF01;
        #10;
        MemWrite = 0;
        
        MemRead = 1;
        #10;
        if (read_data == 32'hABCDEF01) begin
            $display("? PASS: Out-of-bounds write/read at masked addr 0");
            pass = pass + 1;
        end else begin
            $display("? FAIL: Out-of-bounds failed, Got 0x%h", read_data);
            fail = fail + 1;
        end
        MemRead = 0;
        
        // Summary
        $display("===============================================");
        $display("Memory Stage Test Summary:");
        $display("  ? Passed: %0d", pass);
        $display("  ? Failed: %0d", fail);
        if (fail == 0) begin
            $display("SUCCESS: All tests passed!");
        end else begin
            $display("ERROR: Some tests failed. Check logic.");
        end
        $display("===============================================");
        $display("          Memory Stage Testbench End            ");
        $display("===============================================");
        $stop;
    end
endmodule