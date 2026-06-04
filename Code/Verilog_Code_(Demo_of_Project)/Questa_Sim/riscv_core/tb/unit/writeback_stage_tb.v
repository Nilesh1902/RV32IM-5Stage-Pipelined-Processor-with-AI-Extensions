// ============================================================
// Testbench: Writeback Stage
// Tests: Data selection mux for ALU vs. memory results.
// ============================================================

`timescale 1ns/1ps
module writeback_stage_tb;
    reg [31:0] alu_result, mem_data;
    reg mem_to_reg;
    wire [31:0] wb_data;
    
    // Instantiate writeback_stage module
    writeback_stage ws1(wb_data, mem_to_reg, mem_data, alu_result);
    
    integer pass_count = 0;
    integer fail_count = 0;
    
    initial begin
        $display("===============================================");
        $display("         Writeback Stage Testbench Start       ");
        $display("===============================================");
        
        // Test 1: Select ALU result (mem_to_reg=0)
        alu_result = 32'h12345678;
        mem_data   = 32'hDEADBEEF;
        mem_to_reg = 0;
        #5;
        if (wb_data == alu_result) begin
            $display("? PASS: ALU result selected (0x%h)", wb_data);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: Expected ALU 0x%h, Got 0x%h", alu_result, wb_data);
            fail_count = fail_count + 1;
        end
        
        // Test 2: Select Memory result (mem_to_reg=1)
        alu_result = 32'h11111111;
        mem_data   = 32'hABCDEF01;
        mem_to_reg = 1;
        #5;
        if (wb_data == mem_data) begin
            $display("? PASS: Memory result selected (0x%h)", wb_data);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: Expected Mem 0x%h, Got 0x%h", mem_data, wb_data);
            fail_count = fail_count + 1;
        end
        
        // Test 3: Edge case - Zero values
        alu_result = 32'b0;
        mem_data   = 32'b0;
        mem_to_reg = 0;
        #5;
        if (wb_data == 32'b0) begin
            $display("? PASS: Zero ALU selected (0x%h)", wb_data);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: Expected 0, Got 0x%h", wb_data);
            fail_count = fail_count + 1;
        end
        
        // Test 4: Same inputs, switch selection
        alu_result = 32'hFFFFFFFF;
        mem_data   = 32'hFFFFFFFF;
        mem_to_reg = 1;
        #5;
        if (wb_data == mem_data) begin
            $display("? PASS: Same inputs, mem selected (0x%h)", wb_data);
            pass_count = pass_count + 1;
        end else begin
            $display("? FAIL: Expected Mem 0x%h, Got 0x%h", mem_data, wb_data);
            fail_count = fail_count + 1;
        end
        
        $display("===============================================");
        $display("Writeback Stage Test Summary:");
        $display("  ? Passed: %0d", pass_count);
        $display("  ? Failed: %0d", fail_count);
        if (fail_count == 0) begin
            $display("SUCCESS: All tests passed!");
        end else begin
            $display("ERROR: Some tests failed. Check logic.");
        end
        $display("===============================================");
        $display("Writeback Stage Testbench End");
        $display("===============================================");
        $stop;
    end
endmodule