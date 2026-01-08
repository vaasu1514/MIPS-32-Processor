# 5-Stage MIPS32 Processor – Verilog RISC Pipeline

# Description
This project implements a 5-stage pipelined MIPS32 RISC processor using Verilog HDL, following a classical pipeline architecture with Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), and Write Back (WB) stages.
The design focuses on RTL structure, pipeline register organization, and functional correctness, and is verified using multiple custom Verilog testbenches with two-phase non-overlapping clocking.
This project was developed as part of an NPTEL Hardware Modeling using Verilog course and serves as a hands-on RTL implementation of pipelined processor concepts.

## Processor Features

* 5-stage pipelined datapath (IF, ID, EX, MEM, WB)
* Separate pipeline registers between each stage
* Two-phase non-overlapping clocking (clk1, clk2)
* 32 × 32-bit register file
* Word-addressed instruction and data memory
* Centralized control logic based on opcode decoding

