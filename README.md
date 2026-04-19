TEA Cryptographic Accelerator (Verilog)
=======================================

This repository contains two Verilog implementations of the **Tiny Encryption Algorithm (TEA)**, supporting 64-bit block encryption/decryption with 128-bit keys.

The project explores architectural tradeoffs between area efficiency and throughput, using a shared round implementation to ensure identical cryptographic behavior.

Design Overview
---------------

Both architectures are built around a unified tea\_round module, ensuring consistent logic while enabling different performance profiles.

### **Iterative Core**

A resource-efficient design that reuses a single round unit across all 32 rounds via an FSM.

*   **Latency:** 32+ cycles per block
    
*   **Throughput:** Low
    
*   **Area:** Minimal (55 cells with yosys synthesis)
    

### **Pipelined Core**

A high-performance design that unrolls the algorithm into a 5-stage pipeline (8 rounds per stage).

*   **Latency:** 5 cycles
    
*   **Throughput:** 1 block per cycle (steady state)
    
*   **Area:** Higher (921cells with yosys synthesis)
    

Throughput vs Footprint Tradeoff
--------------------------------

The pipelined design achieves maximum throughput by replicating round logic and inserting registers between stages, allowing a new block to be processed every clock cycle. This comes at a significant area cost, as multiple rounds are implemented in parallel instead of being reused.

In contrast, the iterative design minimizes hardware usage by reusing a single round unit, but requires many cycles to complete a block.

Technical Features
------------------

*   The tea\_round module supports both encryption and decryption by switching between addition and subtraction via a mode signal, maximizing reuse.
    
*   Implements a ready/valid protocol, making the design easy to integrate into streaming interfaces such as **AXI-Stream** or **Wishbone**.
    
*   Correctness is verified against a Python-based golden model using randomized test vectors.
    

Tech Stack & Requirements
-------------------------

To run simulations and verification:

*   **Python** – test vector generation
    
*   **Icarus Verilog** – simulation
    
*   **GTKWave** – waveform viewing
    

Synthesis was performed using **Yosys**.

Project Structure
-----------------

*   RTL/ – Verilog source files + synthesis reports (stats.txt)
    
*   DV/ – Testbenches + Python test generation scripts
    

How to Run
----------

1.  **gen-tests.bat** – Generate test vectors (requires Python)
    
2.  **run-iterative.bat** – Simulate iterative core
    
3.  **run-pipelined.bat** – Simulate pipelined core