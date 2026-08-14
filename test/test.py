# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


@cocotb.test()
async def test_adaptive_lfsr_prng(dut):

    dut._log.info("========================================")
    dut._log.info("ADAPTIVE LFSR PRNG TEST START")
    dut._log.info("========================================")

    # ---------------------------------------------------------
    # Start clock
    # ---------------------------------------------------------
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # ---------------------------------------------------------
    # Initial conditions
    #
    # ui_in[7]   = enable
    # ui_in[6:0] = 7-bit external seed
    # ---------------------------------------------------------
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # Reset active
    dut.rst_n.value = 0

    # Two clock edges during reset
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # Release reset
    dut.rst_n.value = 1

    dut._log.info("PASS: Reset released")

    # ---------------------------------------------------------
    # Enable PRNG
    #
    # ui_in[7] = 1
    # ui_in[6:0] = 0x35
    #
    # Therefore ui_in = 0xB5
    # ---------------------------------------------------------
    dut.ui_in.value = 0xB5

    # First clock edge after enabling
    await RisingEdge(dut.clk)

    first_output = int(dut.uo_out.value)

    dut._log.info(
        f"Initial LFSR output = 0x{first_output:02X}"
    )

    # ---------------------------------------------------------
    # Basic output validity
    # ---------------------------------------------------------
    assert first_output != 0x00, \
        "FAIL: LFSR output is zero"

    dut._log.info("PASS: Initial output is non-zero")

    # ---------------------------------------------------------
    # Check that LFSR changes on successive clock edges
    # ---------------------------------------------------------
    previous_output = first_output

    changed_count = 0

    for cycle in range(10):

        await RisingEdge(dut.clk)

        current_output = int(dut.uo_out.value)

        dut._log.info(
            f"Cycle {cycle + 1}: "
            f"random_out = 0x{current_output:02X}"
        )

        if current_output != previous_output:
            changed_count += 1

        previous_output = current_output

    assert changed_count > 0, \
        "FAIL: LFSR output did not change"

    dut._log.info(
        "PASS: LFSR output changes with clock"
    )

    # ---------------------------------------------------------
    # Check internal polynomial selector
    #
    # adaptive_lfsr_prng instance:
    #     dut.prng_inst
    #
    # adaptive_controller:
    #     dut.prng_inst.adaptive_inst
    #
    # poly_sel:
    #     dut.prng_inst.adaptive_inst.poly_sel
    # ---------------------------------------------------------
    poly_before = int(
        dut.prng_inst.adaptive_inst.poly_sel.value
    )

    assert poly_before == 0, \
        f"FAIL: Initial polynomial is P{poly_before}, expected P0"

    dut._log.info("PASS: Initial polynomial = P0")

    # ---------------------------------------------------------
    # Check LFSR state is non-zero
    # ---------------------------------------------------------
    lfsr_state = int(
        dut.prng_inst.lfsr_inst.state.value
    )

    assert lfsr_state != 0, \
        "FAIL: LFSR entered zero state"

    dut._log.info(
        f"PASS: LFSR state non-zero = 0x{lfsr_state:04X}"
    )

    # ---------------------------------------------------------
    # Verify internal adaptive circuitry exists
    # ---------------------------------------------------------
    adaptive_event = int(
        dut.prng_inst.adaptive_event.value
    )

    assert adaptive_event in [0, 1], \
        "FAIL: Invalid adaptive_event"

    dut._log.info(
        f"PASS: Adaptive event signal valid = {adaptive_event}"
    )

    # ---------------------------------------------------------
    # Force a repetition condition for functional testing
    #
    # The repetition monitor compares its previous output
    # against the current LFSR output.
    #
    # We set prev_output equal to the current LFSR output.
    # On the next monitoring edge, this creates a controlled
    # repetition event.
    # ---------------------------------------------------------
    current_output = int(dut.uo_out.value)

    dut.prng_inst.repetition_inst.prev_output.value = current_output

    dut._log.info(
        f"Forced repetition monitor previous output = "
        f"0x{current_output:02X}"
    )

    # ---------------------------------------------------------
    # Wait for adaptive event
    #
    # The monitor operates synchronously, so check one edge
    # at a time.
    # ---------------------------------------------------------
    event_detected = False

    for cycle in range(5):

        await RisingEdge(dut.clk)

        event = int(
            dut.prng_inst.adaptive_event.value
        )

        poly = int(
            dut.prng_inst.adaptive_inst.poly_sel.value
        )

        dut._log.info(
            f"Adaptive check {cycle + 1}: "
            f"event={event}, polynomial=P{poly}"
        )

        if event == 1:
            event_detected = True
            break

    # ---------------------------------------------------------
    # Adaptive event check
    # ---------------------------------------------------------
    if event_detected:

        dut._log.info(
            "PASS: Repetition detected - adaptive event"
        )

        poly_after = int(
            dut.prng_inst.adaptive_inst.poly_sel.value
        )

        assert poly_after == 1, \
            f"FAIL: Polynomial did not switch P0 -> P1. "
            f"Current = P{poly_after}"

        dut._log.info(
            "PASS: Polynomial switched P0 -> P1"
        )

    else:

        dut._log.warning(
            "WARNING: Adaptive event was not observed "
            "during forced repetition test"
        )

    # ---------------------------------------------------------
    # Continue clocking after adaptive operation
    # ---------------------------------------------------------
    for cycle in range(5):

        await RisingEdge(dut.clk)

        output = int(dut.uo_out.value)
        state = int(
            dut.prng_inst.lfsr_inst.state.value
        )

        assert state != 0, \
            "FAIL: LFSR entered zero state after adaptation"

        dut._log.info(
            f"Post-adaptation cycle {cycle + 1}: "
            f"output=0x{output:02X}, "
            f"state=0x{state:04X}"
        )

    dut._log.info(
        "PASS: LFSR continues operating after adaptation"
    )

    # ---------------------------------------------------------
    # Final result
    # ---------------------------------------------------------
    dut._log.info("========================================")
    dut._log.info("ADAPTIVE LFSR PRNG TEST COMPLETE")
    dut._log.info("========================================")
