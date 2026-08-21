# Adaptive Self-Seeding 16-bit Galois LFSR PRNG

A compact 16-bit Galois Linear Feedback Shift Register (LFSR) based Pseudo-Random Number Generator (PRNG) designed for Tiny Tapeout using the SKY130 open-source PDK.

## Project Overview

This project implements a **self-seeding and adaptive 16-bit Galois LFSR-based Pseudo-Random Number Generator (PRNG)**.

Conventional LFSR-based PRNGs require an external non-zero seed and normally operate using a fixed feedback polynomial. The proposed design addresses these limitations by incorporating **internal self-seeding** and **adaptive polynomial selection**.

The design automatically initializes the LFSR with a non-zero seed and monitors the generated output sequence. When consecutive output samples become identical, an adaptive event is triggered and the feedback polynomial is changed to a different primitive polynomial. This helps avoid prolonged repetition and improves the robustness of the generated pseudo-random sequence.

The design is intended as a compact and low-area digital PRNG suitable for applications such as:

- Built-In Self-Test (BIST)
- Hardware security
- Digital testing
- Randomized digital logic
- Embedded systems
- Lightweight cryptographic and security applications

## Key Features

- **16-bit Galois LFSR architecture**
- **Self-seeding mechanism**
- **Three selectable primitive feedback polynomials**
- **Adaptive feedback polynomial selection**
- Detection of **consecutive repeated 8-bit outputs**
- Automatic adaptation when a repetition event is detected
- Lower 8 bits used as the pseudo-random output
- Fully synchronous digital implementation
- Designed for **SKY130** technology
- Compatible with **Tiny Tapeout**
- Compact hardware implementation

## Architecture

The major functional blocks of the design are:

```text
             +----------------------+
             |   Self-Seeding       |
             |      Logic           |
             +----------+-----------+
                        |
                        v
             +----------------------+
             |    16-bit Galois     |
             |       LFSR           |
             +----------+-----------+
                        |
                        v
             +----------------------+
             |   8-bit Output       |
             |     Selection        |
             +----------+-----------+
                        |
                        v
                  PRNG Output
                    [7:0]
                        |
                        v
             +----------------------+
             | Consecutive Output   |
             | Repetition Detector  |
             +----------+-----------+
                        |
                  Adaptive Event
                        |
                        v
             +----------------------+
             | Feedback Polynomial  |
             |     Selection        |
             +----------------------+
                        |
                        +----> LFSR
