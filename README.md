# RISC-V Processor in Verilog

## Overview
This project implements a **RISC-V processor** using Verilog HDL, supporting both **sequential** and **pipelined** execution models. It features comprehensive **hazard detection and handling** mechanisms to ensure accurate instruction execution through techniques such as **data forwarding** and **pipeline stalls**.

## Features
- **Sequential and Pipelined Architectures**: Enables performance analysis and comparison.
- **Hazard Detection and Resolution**: Handles data, control, and structural hazards.
- **RISC-V Instruction Set**: Supports a subset of essential RISC-V instructions.
- **Performance Optimizations**: Implements forwarding, stalling, and basic prediction.

## Implementation Details

- **Sequential Core**: Executes one instruction per cycle, with a simple fetch-decode-execute model.

- **Pipelined Core**: Follows a 5-stage RISC-V pipeline:
  - Instruction Fetch (IF)
  - Instruction Decode (ID)
  - Execute (EX)
  - Memory Access (MEM)
  - Write Back (WB)

- **Hazard Handling Techniques**:
  - **Data Forwarding**: Minimizes stalls from data dependencies.
  - **Pipeline Stalling**: Introduced where dependencies can't be bypassed.
  - **Branch Handling**: Basic branch detection and resolution.

## Setup & Simulation

### Prerequisites
- Verilog Simulator (e.g., Icarus Verilog, ModelSim, Vivado)
- RISC-V assembly programs for testing

### Running the Simulation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/riscv-processor.git
   cd riscv-processor

2. Compile and run the simulation:
    ```bash
    Copy
    Edit
    iverilog -o riscv_sim core.v testbench.v
    vvp riscv_sim
## Author
- **Parth Tokekar**
- **Email: parth.tokekar@students.iiit.ac.in**
- **GitHub: github.com/PatGB5**
