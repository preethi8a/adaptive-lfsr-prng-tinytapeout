# Adaptive Self-Seeding 16-bit Galois LFSR PRNG

**Tiny Tapeout submission, SKY130 130nm, TTSKY26C shuttle**

- [Read the full project documentation](docs/info.md)
- [View the project repository](https://github.com/preethi8a/adaptive-lfsr-prng-tinytapeout)

## What is this?

This project implements a compact **16-bit Galois Linear Feedback Shift Register (LFSR) based Pseudo-Random Number Generator (PRNG)** with an integrated self-seeding and adaptive feedback mechanism.

Unlike a conventional LFSR that requires an externally provided seed and normally operates with a fixed feedback polynomial, this design incorporates **internal self-seeding** and supports **three selectable primitive feedback polynomials**.

The lower 8 bits of the LFSR state are used as the PRNG output. The generated output is continuously monitored for consecutive repetition. When the same 8-bit output is detected for two consecutive samples, an adaptive event is generated and the feedback polynomial is changed, allowing the LFSR to continue operation with a different feedback configuration.

The complete design was implemented through the **Tiny Tapeout SKY130 digital ASIC flow**, generating a final GDSII layout suitable for submission.

## Design summary

- **Architecture:** 16-bit Galois LFSR
- **Function:** Pseudo-Random Number Generation
- **Seed:** Internally generated / self-seeded
- **Feedback:** Three selectable primitive polynomials
- **PRNG output:** Lower 8 bits of the LFSR state
- **Adaptation:** Consecutive 8-bit output repetition detection
- **HDL:** Verilog
- **Technology:** SKY130 130nm
- **Target:** Tiny Tapeout SKY26C
- **Top module:** `tt_um_preethi8a_adaptive_lfsr_prng`
- **Implementation:** RTL-to-GDSII
- **Physical verification:** Tiny Tapeout precheck passed
- **Precheck result:** 15/15 tests passed

## How does it work?

The PRNG begins by initializing the 16-bit LFSR with a valid non-zero seed using the internal self-seeding mechanism.

During normal operation, the Galois LFSR updates its state on every clock cycle according to the currently selected feedback polynomial.

The lower 8 bits of the LFSR state are provided as the pseudo-random output.

The output is simultaneously monitored by storing the previous 8-bit output and comparing it with the current output.

When two consecutive 8-bit outputs are identical, the repetition detector generates an adaptive event. The polynomial-selection logic then switches the LFSR to another available primitive feedback polynomial. Thus, the overall architecture combines:
Self-Seeding + Galois LFSR + Multiple Feedback Polynomials + Output Monitoring + Adaptive Polynomial Selection

## What is Tiny Tapeout?
Tiny Tapeout is an educational project that makes it easier and more affordable to manufacture small digital and analog designs on real silicon.

To learn more, visit:

https://tinytapeout.com/

## Project Team
This project was executed by:

Preethi Aralikatti
Khushi Vishwanath
Shylashree N

RV College of Engineering (RVCE), Bengaluru

## Resources
Tiny Tapeout
Tiny Tapeout FAQ
Digital Design Lessons
Build Your Design Locally
