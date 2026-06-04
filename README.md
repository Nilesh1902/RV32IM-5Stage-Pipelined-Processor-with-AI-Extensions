# RV32IM 5-Stage Pipelined Processor with AI Extensions

## Overview

This project presents the design and implementation of **MyCoreAI32**, a 32-bit RV32IM RISC-V processor developed in SystemVerilog. The processor implements a classic **5-stage pipeline architecture** with hazard detection, data forwarding, branch control, RV32M multiply/divide support, and custom AI-oriented instruction extensions.

The project demonstrates RTL design, pipeline optimization, instruction decoding, arithmetic execution, and processor verification methodologies commonly used in modern digital design and FPGA development.

---

## Key Features

### RISC-V ISA Support

* RV32I Base Integer Instruction Set
* RV32M Extension (Multiply and Divide Instructions)

### Pipeline Architecture

* 5-Stage Pipeline

  * Instruction Fetch (IF)
  * Instruction Decode (ID)
  * Execute (EX)
  * Memory Access (MEM)
  * Write Back (WB)

### Pipeline Optimization

* Data Hazard Detection Unit
* Data Forwarding Unit
* Pipeline Stall Generation
* Branch Handling Logic

### Custom AI Extensions

* VDOT4 (Vector Dot Product)
* VMAX4 (Vector Maximum)

### Arithmetic Units

* Integer ALU
* Hardware Multiplier
* Hardware Divider

### Verification

* Functional Verification using ModelSim
* Directed Testbench Development
* Waveform Analysis and Debugging

---

## Processor Architecture

### Pipeline Flow

```text
Instruction Memory
        │
        ▼
+----------------+
| IF Stage       |
+----------------+
        │
        ▼
+----------------+
| ID Stage       |
+----------------+
        │
        ▼
+----------------+
| EX Stage       |
| ALU + AI Unit  |
+----------------+
        │
        ▼
+----------------+
| MEM Stage      |
+----------------+
        │
        ▼
+----------------+
| WB Stage       |
+----------------+
```

---

## Hazard Management

### Data Hazards

The processor implements forwarding paths to minimize performance penalties caused by data dependencies.

Supported forwarding paths:

* EX/MEM → EX
* MEM/WB → EX

### Load-Use Hazards

Load-use dependencies are detected automatically and resolved using pipeline stalls when required.

### Control Hazards

Branch instructions are resolved in the Execute stage, and appropriate pipeline control mechanisms are used to maintain correct execution flow.

---

## Custom AI Instructions

### VDOT4

Performs vector dot-product operation on packed data elements.

```text
VDOT4 rd, rs1, rs2
```

Operation:

```text
rd = a0*b0 + a1*b1 + a2*b2 + a3*b3
```

### VMAX4

Computes the maximum value among packed vector elements.

```text
VMAX4 rd, rs1, rs2
```

---


## Tools Used

* SystemVerilog
* ModelSim / QuestaSim
* Xilinx Vivado
* Git
* GitHub

---

## Learning Outcomes

Through this project, the following concepts were explored and implemented:

* RISC-V Processor Architecture
* Pipeline Design Techniques
* Hazard Detection and Resolution
* Data Forwarding
* RTL Design Methodology
* Processor Verification
* FPGA Design Flow
* Custom Instruction Set Extension Development

---

## Future Enhancements

* Branch Prediction Unit
* Instruction Cache
* Data Cache
* AXI Interface Support
* Performance Benchmarking
* FPGA Hardware Demonstration

---

## Author

**Nilesh Suresh Nadekar**

PG-DVLSI Graduate | RTL Design | FPGA Design | Digital Design Engineer

GitHub: https://github.com/Nilesh1902
