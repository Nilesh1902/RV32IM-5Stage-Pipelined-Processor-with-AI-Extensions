// ============================================================
// Testbench: Instruction Memory (IMEM)
// Tests: Fetches at various addresses, checks initialized values,
//        and handles out-of-bounds.
// ============================================================

`timescale 1ns/1ps
module instr_mem_tb;
    wire [31:0] instr;
    reg [31:0] addr;
    
    // Instantiate IMEM module
    instr_mem i1(instr, addr);
    
    initial begin
        $display("---- Starting IMEM Testbench ----");
        
        // Test 1: Fetch initialized instructions
        addr = 32'd0;  // Address 0 (word 0)
        #10;
        if (instr == 32'h00000093) begin
            $display("? PASS: Addr %d -> Instr %h (ADDI x1, x0, 0)", addr, instr);
        end else begin
            $display("? FAIL: Addr %d -> Instr %h (expected 00000093)", addr, instr);
        end
        
        addr = 32'd4;  // Address 4 (word 1)
        #10;
        if (instr == 32'h00100113) begin
            $display("? PASS: Addr %d -> Instr %h (ADDI x2, x0, 1)", addr, instr);
        end else begin
            $display("? FAIL: Addr %d -> Instr %h (expected 00100113)", addr, instr);
        end
        
        addr = 32'd8;  // Address 8 (word 2)
        #10;
        if (instr == 32'h002081B3) begin
            $display("? PASS: Addr %d -> Instr %h (ADD x3, x1, x2)", addr, instr);
        end else begin
            $display("? FAIL: Addr %d -> Instr %h (expected 002081B3)", addr, instr);
        end
        
        addr = 32'd12; // Address 12 (word 3)
        #10;
        if (instr == 32'h00000013) begin
            $display("? PASS: Addr %d -> Instr %h (NOP)", addr, instr);
        end else begin
            $display("? FAIL: Addr %d -> Instr %h (expected 00000013)", addr, instr);
        end
        
        // Test 2: Fetch uninitialized address (should be 0)
        addr = 32'd16; // Address 16 (word 4, uninitialized)
        #10;
        if (instr == 32'h00000000) begin
            $display("? PASS: Addr %d -> Instr %h (uninitialized, NOP)", addr, instr);
        end else begin
            $display("? FAIL: Addr %d -> Instr %h (expected 00000000)", addr, instr);
        end
        
        // Test 3: Out-of-bounds address (should be 0)
        addr = 32'h400; // Address 1024 (beyond 1023, out-of-bounds)
        #10;
        if (instr == 32'h00000000) begin
            $display("? PASS: Addr %h -> Instr %h (out-of-bounds, NOP)", addr, instr);
        end else begin
            $display("? FAIL: Addr %h -> Instr %h (expected 00000000)", addr, instr);
        end
        
        $display("---- IMEM Testbench Complete ----");
        $stop;
    end
endmodule