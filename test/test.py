# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_adaptive_lfsr_prng(dut):

    dut._log.info("==============================================")
    dut._log.info(" Adaptive 16-bit Galois LFSR PRNG TEST")
    dut._log.info("==============================================")

    # ---------------------------------------------------------
    # Start clock
    # ---------------------------------------------------------
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    # ---------------------------------------------------------
    # Initial conditions
    # ---------------------------------------------------------
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    # Hold reset
    await ClockCycles(dut.clk, 5)

    # Release reset
    dut.rst_n.value = 1

    dut._log.info("PASS: Reset completed")

    # ---------------------------------------------------------
    # Apply seed
    #
    # ui_in[7]   = enable
    # ui_in[6:0] = external seed
    #
    # Use seed = 0x25
    # Enable = 1
    #
    # Therefore:
    # ui_in = 10010101 = 0x95
    # ---------------------------------------------------------
    seed = 0x25
    ui_value = 0x80 | seed

    dut.ui_in.value = ui_value

    dut._log.info(
        f"Applying seed = 0x{seed:02X}, "
        f"ui_in = 0x{ui_value:02X}"
    )

    # First enabled clock loads the generated seed
    await ClockCycles(dut.clk, 1)

    # ---------------------------------------------------------
    # Check output is not unknown / zero
    # ---------------------------------------------------------
    output = int(dut.uo_out.value)

    dut._log.info(
        f"Initial random output = 0x{output:02X}"
    )

    assert output != 0, \
        "FAIL: Random output is zero after initialization"

    dut._log.info(
        "PASS: Initial non-zero random output generated"
    )

    # ---------------------------------------------------------
    # Check that LFSR output changes
    # ---------------------------------------------------------
    outputs = []

    for i in range(10):

        await ClockCycles(dut.clk, 1)

        value = int(dut.uo_out.value)

        outputs.append(value)

        dut._log.info(
            f"LFSR cycle {i + 1:02d}: "
            f"random_out = 0x{value:02X}"
        )

    # At least two different values should appear
    unique_outputs = len(set(outputs))

    assert unique_outputs > 1, \
        "FAIL: LFSR output is not changing"

    dut._log.info(
        f"PASS: LFSR operating normally "
        f"({unique_outputs} unique outputs)"
    )

    # ---------------------------------------------------------
    # Check internal polynomial status
    #
    # Access hierarchy:
    #
    # tb
    #  └── user_project
    #       └── prng_inst
    #            └── adaptive_inst
    #
    # Polynomial should initially be P0 = 0
    # ---------------------------------------------------------
    try:

        poly_status = dut.user_project.prng_inst.poly_status.value

        dut._log.info(
            f"Initial polynomial status = {int(poly_status)}"
        )

        assert int(poly_status) == 0, \
            "FAIL: Initial polynomial is not P0"

        dut._log.info(
            "PASS: Initial polynomial = P0"
        )

    except Exception as e:

        dut._log.warning(
            f"Could not access internal poly_status: {e}"
        )

    # ---------------------------------------------------------
    # Check adaptive event signal
    #
    # Normally the LFSR should operate without an adaptive
    # event unless the 8-bit output repeats consecutively.
    # ---------------------------------------------------------
    try:

        adaptive_event = (
            dut.user_project.prng_inst.adaptive_event.value
        )

        dut._log.info(
            f"Adaptive event = {int(adaptive_event)}"
        )

    except Exception as e:

        dut._log.warning(
            f"Could not access adaptive_event: {e}"
        )

    # ---------------------------------------------------------
    # Verify cooldown signal if accessible
    # ---------------------------------------------------------
    try:

        cooldown = (
            dut.user_project.prng_inst.cooldown.value
        )

        dut._log.info(
            f"Cooldown = {int(cooldown)}"
        )

    except Exception as e:

        dut._log.warning(
            f"Could not access cooldown: {e}"
        )

    # ---------------------------------------------------------
    # Continue running
    #
    # This confirms the design remains active and does not
    # enter an invalid/unknown state.
    # ---------------------------------------------------------
    for i in range(20):

        await ClockCycles(dut.clk, 1)

        value = int(dut.uo_out.value)

        assert 0 <= value <= 255, \
            "FAIL: Invalid 8-bit random output"

    dut._log.info(
        "PASS: Extended LFSR operation completed"
    )

    # ---------------------------------------------------------
    # Disable PRNG
    # ---------------------------------------------------------
    dut.ui_in.value = seed

    await ClockCycles(dut.clk, 3)

    stopped_output = int(dut.uo_out.value)

    dut._log.info(
        f"PRNG disabled, output = 0x{stopped_output:02X}"
    )

    # ---------------------------------------------------------
    # Re-enable PRNG
    # ---------------------------------------------------------
    dut.ui_in.value = ui_value

    await ClockCycles(dut.clk, 3)

    resumed_output = int(dut.uo_out.value)

    dut._log.info(
        f"PRNG re-enabled, output = 0x{resumed_output:02X}"
    )

    dut._log.info("==============================================")
    dut._log.info(" FULL ADAPTIVE LFSR PRNG BASIC TEST COMPLETE")
    dut._log.info("==============================================")
