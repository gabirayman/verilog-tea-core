# TEA Cryptographic Accelerator (Verilog)

A Verilog implementation of the Tiny Encryption Algorithm (TEA) featuring both Encryption and Decryption modes in a single unified core.

---

##  Features

* **Dual-Mode Support:** Unified FSM architecture handles both encryption and decryption via a mode control signal.
* **Iterative Architecture:** Uses dedicated `tea_encrypt_round` and `tea_decrypt_round` engines to maintain mathematical clarity while sharing a central control "brain."
* **Command Sampling:** Implements a Mode Register that samples and locks the operation mode at the start pulse, preventing mid-cycle corruption.
* **Robust Handshake:** Standard `ready`/`valid` protocol for easy integration with CPUs (like RISC-V or ESP32) or DMA controllers.
* **Verification Toolchain:** Integrated Python-to-Verilog workflow for automated mass-testing.

---

## 📂 Project Structure

* `tea_core.v`: Top-level FSM that manages the 32-round iterative process and handles mode-switching.
* `tea_encrypt_round.v`: Combinational logic for the forward TEA round.
* `tea_decrypt_round.v`: Combinational logic for the inverse (decryption) TEA round.
* `tea_core_tb.v`: Self-checking testbench utilizing `$readmemh` for data-driven verification.
* `gen_vectors.py`: Python "Golden Model" script that generates random test vectors and hardware parameters.

---

## Usage

1. **Generate the Test Suite**

   This script generates random keys and plaintexts, calculates the golden ciphertext using a Python TEA model, and updates the Verilog parameters automatically.

   ```bash
   # Generate 100 random test cases
   python gen_vectors.py 100
   ```

2. **Run Hardware Simulation**

   The testbench performs a Symmetric Loopback Test: it encrypts the plaintext, then feeds the result back through the decrypter to verify the original data is recovered perfectly.

   ```bash
   # Compile and run via Icarus Verilog
   run.bat
   ```

##  Implementation Details

The core operates on 64-bit blocks with a 128-bit key. It manages the state transitions below:

* `IDLE`: Core asserts `ready`. Samples plaintext, key, and mode when `start` is high.
* `WORK`: Iterates through 32 cycles. The `sum` register is updated dynamically based on the operation mode.
* `DONE`: Asserts `valid` for one cycle and presents the result on `ciphertext`.

### Mathematical Logic (Decryption vs Encryption)

In hardware, the order of operations is critical. While encryption adds the delta before the round math, decryption subtracts the delta at the end of the round to maintain mathematical symmetry.

**Encryption Round:**

$$v_0 = v_0 + (((v_1 \ll 4) + k_0) \oplus (v_1 + \text{sum}) \oplus ((v_1 \gg 5) + k_1))$$
$$v_1 = v_1 + (((v_0 \ll 4) + k_2) \oplus (v_0 + \text{sum}) \oplus ((v_0 \gg 5) + k_3))$$

**Decryption Round:**

$$v_1 = v_1 - (((v_0 \ll 4) + k_2) \oplus (v_0 + \text{sum}) \oplus ((v_0 \gg 5) + k_3))$$
$$v_0 = v_0 - (((v_1 \ll 4) + k_0) \oplus (v_1 + \text{sum}) \oplus ((v_1 \gg 5) + k_1))$$

## Code Algorithm in C:

```c
#include <stdint.h>

void encrypt (uint32_t v[2], const uint32_t k[4]) {
    uint32_t v0=v[0], v1=v[1], sum=0, i;           /* set up */
    uint32_t delta=0x9E3779B9;                     /* a key schedule constant */
    uint32_t k0=k[0], k1=k[1], k2=k[2], k3=k[3];   /* cache key */
    for (i=0; i<32; i++) {                         /* basic cycle start */
        sum += delta;
        v0 += ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        v1 += ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
    }                                              /* end cycle */
    v[0]=v0; v[1]=v1;
}

void decrypt (uint32_t v[2], const uint32_t k[4]) {
    uint32_t v0=v[0], v1=v[1], sum=0xC6EF3720, i;  /* set up; sum is (delta << 5) & 0xFFFFFFFF */
    uint32_t delta=0x9E3779B9;                     /* a key schedule constant */
    uint32_t k0=k[0], k1=k[1], k2=k[2], k3=k[3];   /* cache key */
    for (i=0; i<32; i++) {                         /* basic cycle start */
        v1 -= ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
        v0 -= ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        sum -= delta;
    }                                              /* end cycle */
    v[0]=v0; v[1]=v1;
}
```
