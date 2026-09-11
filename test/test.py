# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge

DATA_WIDTH = 8
FRAME_WIDTH = 11
TEST_CASES = 6
    

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    for _ in range(2):
        await FallingEdge(dut.clk)
    #TX_OUT = 1 & BUSY = 0
    if int(dut.uo_out.value) == 1:
        dut._log.info(
            f"Reset is passed,"
            f"BUSY={int(dut.uo_out[1].value)},"
            f"TX={int(dut.uo_out[0].value)},"
        )
    else:
        dut._log.error(
            f"Reset is failed,"
            f"BUSY={int(dut.uo_out[1].value)},"
            f"TX={int(dut.uo_out[0].value)},"
        )
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    dut.uio_in.value = 0b00000111
    dut.ui_in.value = 0xF2
    await FallingEdge(dut.clk)
    dut.uio_in.value = 0b00000011
    
    

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    #assert dut.uo_out.value == 50

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
