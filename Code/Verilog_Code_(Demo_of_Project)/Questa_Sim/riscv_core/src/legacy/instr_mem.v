// ============================================================
// Module: Instruction Memory (IMEM)
// Function: Stores and fetches 32-bit RISC-V instructions.
//          Word-aligned access (addresses must be multiples of 4).
// Inputs : addr (32-bit address, but only lower bits used for indexing)
// Outputs: instr (32-bit instruction fetched)
// Notes  : Memory size is 256 words (1024 bytes). Expand as needed.
//          Uninitialized locations default to 0 (NOP).
//          For real-time testing, add loops (e.g., JAL to address 0).
//          Synthesis: Can be inferred as block RAM in FPGAs.
// ============================================================

`timescale 1ns/1ps
module instr_mem(
    output reg [31:0] instr,     // Fetched instruction
    input wire [31:0] addr       // Address (word-aligned)
);
    // Memory: 256 x 32-bit (expandable, e.g., to 1024 for larger programs)
    reg [31:0] memory [0:255];
    
    // Initialize with example instructions (rest defaults to 0)
    initial begin
        memory[0] = 32'h00000093;   // ADDI x1, x0, 0
        memory[1] = 32'h00100113;   // ADDI x2, x0, 1
        memory[2] = 32'h002081B3;   // ADD  x3, x1, x2
        memory[3] = 32'h00000013;   // NOP
        // Add more instructions here for testing (e.g., branches or loops)
        // Example: memory[4] = 32'h0000006F; // JAL x0, 0 (loop back)
    end
    
        // Combinational read: Word-aligned access
        always @(*) begin
            // Mask address to 10 bits (for 256 words: 2^8 = 256, but 9:2 for 512, etc.)
            // Adjust mask if expanding memory size
            if (addr[31:10] == 22'b0) begin  // Bounds check (valid for 0-1023 byte addresses)
                instr = memory[addr[9:2]];  // addr[9:2] for 256 words (2^8=256)
                // Ensure uninitialized returns 0 (simulation fix)
                if (instr === 32'bx) instr = 32'b0;
            end else begin
                instr = 32'b0;  // Out-of-bounds: Return NOP (0)
            end
        end
endmodule