# MyCoreAI32 - Architecture Documentation

Complete microarchitecture reference for the RV32IM 5-Stage Pipelined RISC-V Processor with AI Extensions.

---

## Table of Contents

1. [High-Level Architecture](#high-level-architecture)
2. [Pipeline Overview](#pipeline-overview)
3. [Execution Stages](#execution-stages)
4. [Instruction Set](#instruction-set)
5. [Hazard Detection & Resolution](#hazard-detection--resolution)
6. [Data Forwarding](#data-forwarding)
7. [Branch Handling](#branch-handling)
8. [Arithmetic Units](#arithmetic-units)
9. [Memory Interface](#memory-interface)
10. [Signal Definitions](#signal-definitions)

---

## High-Level Architecture

### Block Diagram

```
┌─────────────────────────────────────────────────────────┐
│              RISC-V Processor (32-bit)                  │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │         Instruction & Data Memory System         │  │
│  │  ┌─────────────────┐      ┌─────────────────┐   │  │
│  │  │ Instruction Mem │      │  Data Memory    │   │  │
│  │  │ (32-bit words)  │      │  (Byte addr.)   │   │  │
│  │  └─────────────────┘      └─────────────────┘   │  │
│  └──────────────────────────────────────────────────┘  │
│           ▲                              ▲              │
│           │                              │              │
│  ┌────────┴──────────────────────────────┴──────────┐  │
│  │         5-Stage Pipeline with Hazard Unit        │  │
│  │                                                   │  │
│  │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐ ┌──────┐ │  │
│  │  │ IF   │→ │ ID   │→ │ EX   │→ │ MEM  │→│ WB   │ │  │
│  │  │Fetch │  │Decode│  │Execute  │Access │Write  │ │  │
│  │  │      │  │      │  │  AI   │ │      │Back    │ │  │
│  │  └──────┘  └──────┘  └──────┘  └──────┘ └──────┘ │  │
│  │                                                   │  │
│  │  ◄────── Forwarding & Hazard Control ────────►   │  │
│  └───────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │         Control & Register File Unit             │  │
│  │  ┌──────────────┐      ┌──────────────────────┐ │  │
│  │  │ Control Unit │      │  Register File (32)  │ │  │
│  │  │ Decoder      │      │  Dual-Read/Single-WR│ │  │
│  │  └──────────────┘      └──────────────────────┘ │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Key Components

| Component | Description | Width | Bits |
|-----------|-------------|-------|------|
| **Program Counter (PC)** | Current instruction address | 32 | [31:0] |
| **Register File** | 32 × 32-bit registers (x0-x31) | 32 | [31:0] |
| **ALU** | Arithmetic & Logic operations | 32 | [31:0] |
| **Data Memory** | Synchronous data access | 32 | [31:0] |
| **Instruction Decode** | Opcode-based instruction routing | Varies | - |

---

## Pipeline Overview

### 5-Stage Pipeline Structure

The processor employs a **classic 5-stage pipeline** with each stage operating on a different instruction simultaneously.

```
Cycle:  0   1   2   3   4   5   6   7   8
Inst0: [IF][ID][EX][MEM][WB]
Inst1:     [IF][ID][EX][MEM][WB]
Inst2:         [IF][ID][EX][MEM][WB]
Inst3:             [IF][ID][EX][MEM][WB]
Inst4:                 [IF][ID][EX][MEM][WB]
```

**Ideal CPI (Clock Per Instruction):** 1.0 (with no hazards)

### Stage Latencies

| Stage | Latency | Function |
|-------|---------|----------|
| **IF** | 1 cycle | Fetch instruction from memory |
| **ID** | 1 cycle | Decode & read register file |
| **EX** | 1 cycle | Execute ALU/AI operation |
| **MEM** | 1 cycle | Read/Write data memory |
| **WB** | 0 cycles | Write back to register |

---

## Execution Stages

### Stage 1: Instruction Fetch (IF)

**Function:** Retrieve instruction from instruction memory

**Inputs:**
- `clk` - Clock signal
- `rst` - Reset signal
- `pc_next` - Next PC value (from branch logic or PC+4)
- `flush` - Pipeline flush on branch mispredict

**Outputs:**
- `inst` - 32-bit instruction
- `pc` - Current program counter value

**Logic:**
```verilog
always @(posedge clk) begin
    if (rst) begin
        pc <= 32'h0;
    end else if (flush) begin
        pc <= branch_target;  // Flush & redirect to branch target
    end else if (!stall) begin
        pc <= pc_next;        // PC + 4 (normal increment)
    end
end

assign inst = instruction_memory[pc[31:2]];  // Fetch instruction
```

**Pipeline Register:** IF/ID
- `if_id_inst` - Instruction
- `if_id_pc` - Program counter

---

### Stage 2: Instruction Decode (ID)

**Function:** Decode instruction and read register operands

**Inputs:**
- `if_id_inst` - Instruction from IF stage
- `if_id_pc` - PC from IF stage
- `rd_data` - Write-back data
- `reg_write` - Write-back enable

**Outputs:**
- `opcode` - Instruction opcode
- `rs1_data` - First register operand
- `rs2_data` - Second register operand
- `imm` - Immediate value (sign-extended)
- `rd_addr` - Destination register address

**Key Operations:**
1. **Instruction Decoding**
   - Extract opcode, function codes (funct3, funct7)
   - Generate control signals for execution

2. **Register File Read**
   - Dual-read ports for rs1, rs2
   - Asynchronous read (combinational)

3. **Immediate Generation**
   - Sign-extend immediate values
   - Support for I-type, S-type, B-type, U-type, J-type formats

**Control Signals Generated:**
```verilog
alu_op    // ALU operation select
mem_read  // Memory read enable
mem_write // Memory write enable
reg_write // Register write enable
forwarding_enable // Enable data forwarding
ai_inst   // Custom AI instruction flag
```

**Pipeline Register:** ID/EX
- `id_ex_rs1_data` - Register 1 operand
- `id_ex_rs2_data` - Register 2 operand
- `id_ex_imm` - Immediate value
- `id_ex_rd_addr` - Destination register
- `id_ex_control_signals` - All control signals

---

### Stage 3: Execute (EX)

**Function:** Perform arithmetic/logic operations and address calculation

**Inputs:**
- `id_ex_rs1_data` - Operand 1
- `id_ex_rs2_data` - Operand 2
- `id_ex_imm` - Immediate value
- `alu_op` - ALU operation
- `forwarded_data_1` - Forwarded result (optional)
- `forwarded_data_2` - Forwarded result (optional)
- `ai_inst` - AI instruction flag

**Outputs:**
- `alu_result` - ALU computation result
- `branch_taken` - Branch decision
- `branch_target` - Target address
- `ai_result` - AI instruction result (VDOT4, VMAX4)

**Key Components:**

#### ALU Operations
```
Arithmetic: ADD, ADDI, SUB
Logical:    AND, ANDI, OR, ORI, XOR, XORI
Shift:      SLL, SLLI, SRL, SRLI, SRA, SRAI
Comparison: SLT, SLTI, SLTU, SLTUI
Multiply:   MUL, MULH, MULHSU, MULHU (RV32M)
Divide:     DIV, DIVU, REM, REMU (RV32M)
```

#### AI Execution Unit
```
VDOT4:  rd = (rs1[7:0]×rs2[7:0]) + (rs1[15:8]×rs2[15:8]) +
            (rs1[23:16]×rs2[23:16]) + (rs1[31:24]×rs2[31:24])

VMAX4:  rd = MAX(rs1[7:0], rs1[15:8], rs1[23:16], rs1[31:24])
```

#### Branch Resolution (EX Stage)
Branches are resolved in the **Execute stage**, not Fetch:
- Condition evaluation occurs in EX
- Branch target calculated immediately
- Pipeline flush occurs on branch taken
- **No branch prediction implemented** (can be added for enhancement)

**Branch Types:**
- **BEQ** - Branch if equal
- **BNE** - Branch if not equal
- **BLT** - Branch if less than
- **BGE** - Branch if greater or equal
- **BLTU** - Branch if less than (unsigned)
- **BGEU** - Branch if greater or equal (unsigned)

**Pipeline Register:** EX/MEM
- `ex_mem_alu_result` - ALU/AI result
- `ex_mem_mem_data` - Data for memory write
- `ex_mem_rd_addr` - Destination register
- `ex_mem_control_signals` - Carry-through control signals

---

### Stage 4: Memory Access (MEM)

**Function:** Perform memory read/write operations

**Inputs:**
- `ex_mem_alu_result` - Address for memory operation
- `ex_mem_mem_data` - Data to write (stores)
- `mem_read` - Read enable
- `mem_write` - Write enable
- `data_memory` - Memory array

**Outputs:**
- `mem_data` - Data from memory (loads)
- `mem_valid` - Data valid signal

**Memory Operations:**
```
Load Instructions:   LW, LH, LB, LHU, LBU
Store Instructions:  SW, SH, SB
```

**Memory Interface (Synchronous):**
```verilog
// Read path
always @(posedge clk) begin
    if (mem_read) begin
        mem_data <= data_memory[address[31:2]];
    end
end

// Write path
always @(posedge clk) begin
    if (mem_write) begin
        data_memory[address[31:2]] <= write_data;
    end
end
```

**Pipeline Register:** MEM/WB
- `mem_wb_data` - Result (from ALU or memory)
- `mem_wb_rd_addr` - Destination register
- `mem_wb_reg_write` - Write-back enable

---

### Stage 5: Write Back (WB)

**Function:** Update register file with result

**Inputs:**
- `mem_wb_data` - Result to write back
- `mem_wb_rd_addr` - Destination register
- `mem_wb_reg_write` - Write enable

**Operations:**
```verilog
always @(posedge clk) begin
    if (mem_wb_reg_write && mem_wb_rd_addr != 5'b0) begin
        register_file[mem_wb_rd_addr] <= mem_wb_data;
    end
end
```

**Note:** Register x0 (zero register) is write-protected and always reads 0.

---

## Instruction Set

### RV32I Base Integer Instructions

| Instruction | Type | Operation |
|-------------|------|-----------|
| ADD, SUB | R | Addition/Subtraction |
| ADDI | I | Add Immediate |
| AND, OR, XOR | R | Logical operations |
| ANDI, ORI, XORI | I | Logical with Immediate |
| SLL, SRL, SRA | R | Shift operations |
| SLLI, SRLI, SRAI | I | Shift with Immediate |
| SLT, SLTU | R | Set if less than |
| SLTI, SLTUI | I | Set if less than Immediate |
| LUI | U | Load Upper Immediate |
| AUIPC | U | Add Upper Immediate to PC |
| LW, LH, LB, LHU, LBU | I | Load operations |
| SW, SH, SB | S | Store operations |
| BEQ, BNE, BLT, BGE | B | Branch operations |
| BLTU, BGEU | B | Branch unsigned |
| JAL | J | Jump and Link |
| JALR | I | Jump and Link Register |

### RV32M Multiply/Divide Instructions

| Instruction | Operation |
|-------------|-----------|
| MUL, MULH, MULHSU, MULHU | Multiply (signed/unsigned) |
| DIV, DIVU | Divide (signed/unsigned) |
| REM, REMU | Remainder (signed/unsigned) |

### Custom AI Instructions

| Instruction | Operation |
|-------------|-----------|
| VDOT4 | Vector dot product (4×8-bit) |
| VMAX4 | Vector maximum (4×8-bit) |

---

## Hazard Detection & Resolution

### Data Hazards
- **RAW (Read-After-Write)** - Resolved by forwarding + stalling
- **WAR, WAW** - Not possible in in-order pipeline

### Load-Use Hazard Detection

```verilog
wire hazard_from_ex = (id_ex_reg_write) && 
                      (id_ex_rd_addr != 5'b0) &&
                      ((id_ex_rd_addr == if_id_rs1_addr) || 
                       (id_ex_rd_addr == if_id_rs2_addr));
```

### Load-Use Hazard Stalling
When load is followed immediately by use, **one stall cycle** is required.

---

## Data Forwarding

### Forwarding Paths

#### EX/MEM → EX Forwarding
Forward ALU result directly with **0-cycle latency**.

#### MEM/WB → EX Forwarding
Forward write-back value with **1-cycle latency**.

**Forwarding Priority:**
1. EX/MEM result (most recent)
2. MEM/WB result (older)
3. Register file value (no stall)

---

## Branch Handling

Branches are **resolved in EX stage**, causing a **2-cycle penalty** on misprediction:
- IF stage fetches wrong instruction
- ID stage decodes wrong instruction
- EX stage detects branch taken
- Both IF and ID instructions flushed (converted to NOPs)

---

## Arithmetic Units

### 32-bit Integer ALU
```verilog
module alu_32bit (
    input  wire [31:0] a, b,
    input  wire [3:0]  alu_op,
    output wire [31:0] result,
    output wire        zero_flag
);
```

Supports: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU

### Hardware Multiplier (RV32M)
- Pipelined 32×32 multiplier
- Supports signed and unsigned operations
- 1-cycle throughput (fully pipelined)

### Hardware Divider (RV32M)
- Iterative restoring divider
- 32 cycles to complete
- Pipeline stall during division

### AI Execution Unit

#### VDOT4
```verilog
wire [15:0] p0 = rs1[7:0] * rs2[7:0];
wire [15:0] p1 = rs1[15:8] * rs2[15:8];
wire [15:0] p2 = rs1[23:16] * rs2[23:16];
wire [15:0] p3 = rs1[31:24] * rs2[31:24];
assign vdot4_result = p0 + p1 + p2 + p3;
```

#### VMAX4
```verilog
wire max_01 = (rs1[7:0] > rs1[15:8]) ? rs1[7:0] : rs1[15:8];
wire max_23 = (rs1[23:16] > rs1[31:24]) ? rs1[23:16] : rs1[31:24];
assign vmax4_result = (max_01 > max_23) ? max_01 : max_23;
```

---

## Memory Interface

### Instruction Memory
- 32-bit width, word-addressable
- Combinational (asynchronous) read

### Data Memory
- 32-bit width, byte-addressable
- Synchronous read/write
- 1-cycle read latency

---

## Performance Characteristics

### CPI Analysis

| Scenario | CPI |
|----------|-----|
| No hazards | 1.0 |
| Load-use hazard | 1.5 |
| Branch misprediction | 2.0 |
| Realistic workload | ~1.4-1.6 |

### Synthesis Results (SAED32nm)

| Metric | Value |
|--------|-------|
| **Frequency** | ~16.67 MHz (60ns) |
| **WNS** | +54.22ns ✅ |
| **Area** | ~0.25-0.35 mm² |
| **Power** | ~5-8mW @ 1GHz |

---

**Document Version:** 1.0 | **Last Updated:** June 2026
