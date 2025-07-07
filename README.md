# CHACHA20 – Verilog RTL Implementation

This repository provides a modular and synthesizable Verilog RTL implementation of the **ChaCha20 stream cipher**, originally designed by Daniel J. Bernstein. The project targets secure hardware design and simulation, with potential extensions for FPGA/ASIC acceleration and cryptographic IP development.

---

## Project Objectives

The main goal is to design, verify, and eventually integrate the internal blocks of the ChaCha20 cipher, beginning with the essential **Quarter Round (QR)** unit. The focus is on creating clean, modular, and synthesizable Verilog code suitable for academic use, IP integration, and hardware security research.

Planned outcomes:
- Verified RTL implementation of core ChaCha20 components
- Simulation-ready testbenches for validation
- Modular structure for easy expansion
- Future support for ChaCha20-Poly1305 AEAD integration
- Possible extension to UVM/SystemVerilog test environments

---

## Repository Structure

CHACHA20/
- qr.v # Quarter Round module
- tb_qr.v # Testbench for Quarter Round
- core.v #  Full ChaCha20 block processor
- top.v #  Top-level module with I/O wrapper
- tb.v #  Testbench for full integration
- README.md # Project documentation


---

## Module Description

### 1. `qr.v`: ChaCha Quarter Round

Implements one **Quarter Round** operation on four 32-bit state words `a`, `b`, `c`, and `d`. This building block is used repeatedly in ChaCha20’s 512-bit transformation rounds.

The quarter round performs the following sequence:

- a += b; d ^= a; d <<< 16;
- c += d; b ^= c; b <<< 12;
- a += b; d ^= a; d <<< 8;
- c += d; b ^= c; b <<< 7;

Each line uses:
- 32-bit modular addition
- Bitwise XOR
- Left rotation (circular shift)

---

### 2. `tb_qr.v`: Testbench for Quarter Round

This testbench provides a basic simulation environment for the `qr.v` module. It applies fixed input vectors and prints the output for manual or automated comparison.

**Usage:**
- Instantiate `qr` in testbench
- Apply known ChaCha test vectors
- Simulate and verify output with reference values
  

## Overview of ChaCha20 Algorithm

ChaCha20 is a high-speed stream cipher that operates on a **512-bit internal state** organized as 16 words, each 32 bits wide. The state consists of:

- 4 constant words
- 8 key words (256-bit key)
- 1 block counter
- 3 nonce words (96-bit nonce)

The cipher applies **20 rounds** of transformation, divided into:
- 10 **column rounds**
- 10 **diagonal rounds**

Each round is composed of multiple **quarter round (QR)** operations that perform modular addition, XOR, and bitwise left rotations to ensure high diffusion and security.

### ChaCha20 Highlights

- Designed for **high performance** on both hardware and software platforms
- **Secure** against timing attacks and cache side-channel attacks
- Utilizes only three operations:
  - Addition modulo 2³²
  - Bitwise XOR
  - Bitwise rotation
- Requires no lookup tables or S-boxes (unlike AES)
- Simple, regular structure suitable for efficient hardware implementation

### Real-World Usage

ChaCha20 is widely adopted in modern cryptographic systems:

- **TLS encryption** (used by Google, Cloudflare)
- **OpenSSH** secure shell protocol
- **Disk encryption** on Android and iOS
- **Google’s QUIC protocol** for fast internet transport
