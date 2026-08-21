# Testbench – Adaptive Self-Seeding 16-bit Galois LFSR PRNG

This directory contains the simulation and verification environment for the **Adaptive Self-Seeding 16-bit Galois LFSR PRNG** Tiny Tapeout project.

The testbench uses **Cocotb** and Verilog to verify the functionality of the PRNG at RTL and, where applicable, at gate level.

## Testbench Files

- `tb.v` – Verilog testbench and DUT interface
- `test.py` – Cocotb-based functional tests
- `Makefile` – Simulation and gate-level simulation configuration
- `requirements.txt` – Python dependencies
- `tb.gtkw` – GTKWave waveform configuration
- `gate_level_netlist.v` – Gate-level netlist used for post-hardening simulation

## What is Verified?

The verification environment checks the major functional blocks of the PRNG, including:

- Reset operation
- Self-seeding functionality
- Non-zero LFSR initialization
- 16-bit Galois LFSR state progression
- 8-bit PRNG output generation
- Consecutive output comparison
- Repetition detection
- Adaptive polynomial selection
- Continued LFSR operation after polynomial switching

## RTL Simulation
The simulation uses the RTL source specified in the Makefile and runs the Cocotb testbench.

The generated waveform can be inspected using GTKWave or Surfer.

Gate-Level Simulation

After the design has been hardened, the generated gate-level netlist can be used for post-implementation verification.

Copy the generated gate-level netlist into this directory as:

gate_level_netlist.v

The gate-level simulation can then be run using:

make -B GATES=yes

The gate-level simulation uses the SKY130 standard-cell library models and the hardened netlist to verify that the implemented design maintains the expected functionality.

Waveform Output

The default simulation generates an FST waveform.

To generate a VCD waveform instead, modify the testbench to use:

$dumpfile("tb.vcd");

and run:

make -B FST=

This generates:

tb.vcd

instead of:

tb.fst
Viewing Waveforms
GTKWave

To view the FST waveform:

gtkwave tb.fst tb.gtkw

For a VCD waveform:

gtkwave tb.vcd
Surfer

The FST waveform can also be viewed using Surfer:

surfer tb.fst
Expected Verification Behavior

During simulation, the LFSR should:

Initialize to a valid non-zero state.
Generate successive 8-bit pseudo-random outputs.
Monitor consecutive output values.
Detect an adaptive event when two consecutive 8-bit outputs are identical.
Switch to another feedback polynomial.
Continue generating pseudo-random output using the new polynomial.

The waveform can be used to observe the LFSR state, PRNG output, repetition detection, and adaptive polynomial-selection behavior.

Tiny Tapeout Implementation

The design was subsequently hardened using the Tiny Tapeout SKY130 digital flow.

The final GDSII layout passed the Tiny Tapeout precheck, with all required precheck tests passing.

For complete project information, architecture, implementation details, and physical-design results, see [main project README](../README.md).

## References

- [Tiny Tapeout](https://tinytapeout.com/)
- [Cocotb Documentation](https://docs.cocotb.org/en/stable/)
- [Tiny Tapeout HDL Testing](https://tinytapeout.com/hdl/testing/)
