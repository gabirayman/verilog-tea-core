# 🛠️ TEA Cryptographic Accelerator: Development Roadmap

## 📌 Project Overview
A high-performance hardware implementation of the **Tiny Encryption Algorithm (TEA)** in Verilog, transitioning from a basic iterative design to a high-throughput pipelined architecture.

### Core Features
* **Dual-mode:** Encryption & Decryption support.
* **Modular Design:** Dedicated round modules (`tea_encrypt_round.v`, `tea_decrypt_round.v`).
* **Verified:** Python-based golden model and self-checking testbenches.

---

## 🚀 Roadmap

### 🥇 Phase 1: 4-Stage Pipelined Architecture
**Goal:** Transform the design from iterative (1 round/cycle) to a high-throughput pipeline.

* **Logic Unrolling:** Create `tea_8rounds.v` by chaining 8 encryption rounds combinationally.
* **Pipeline Integration:** Implement `tea_core_pipeline.v` featuring 4 stages (each containing an 8-round block).
* **Flow Control:** Replace the FSM with a simple pipeline flow and a valid-signal shift register.

| Metric | Iterative (Current) | Pipelined (Target) |
| :--- | :--- | :--- |
| **Latency** | ~32 cycles | ~4 cycles |
| **Throughput** | 1 block / 32 cycles | 1 block / 1 cycle |
| **Area** | Small | ~8x Larger |

---

### 🥈 Phase 2: Synthesis & Performance Analysis
**Goal:** Evaluate the hardware "cost" of the performance gains.

* **Tooling:** Run synthesis using **Yosys** or vendor tools (Vivado/Quartus).
* **Extraction:** Measure total logic cells, register count, and maximum clock frequency ($F_{max}$).
* **Trade-off Study:** Document the Latency vs. Area trade-offs to justify design decisions.

---

### 🥉 Phase 3: AXI-Lite Interface Integration
**Goal:** Convert the core into a professional Silicon IP block ready for SoC integration.

* **Wrapper:** Develop `tea_axi_wrapper.v` to handle bus transactions.
* **Register Mapping:**
    * `0x00`: Control (Start, Mode)
    * `0x04`: Status (Ready, Valid)
    * `0x08 - 0x0C`: Input Data (Plaintext)
    * `0x10 - 0x1C`: Key Storage
    * `0x20 - 0x24`: Output Data (Ciphertext)

---

### 🟡 Phase 4: System Integration (Optional)
* **Option A:** Connect the TEA IP to a soft-core CPU or an external MCU (like ESP32) for real-world testing.
* **Option B:** Implement an **AXI-Stream** interface for high-speed data processing applications.

---
*Status: 🛠️ Phase 1 in Progress*