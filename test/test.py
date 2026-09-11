# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge

#input  PAR_TYP, uio_in[0]
#input  PAR_EN, uio_in[1]
#input  DATA_VALID, uio_in[2]
#output TX_OUT, uo_out[0]
#output BUSY  uo_out[1]


async def data_tx(dut,data):
    dut.uio_in.value[2] = 1   
    dut.ui_in.value = data
    await FallingEdge(dut.clk)
    dut.uio_in.value[2] = 0

async def check_data_out(dut,data_out_expec,num_test):
    if int(dut.uio_in.value[1]) == 1:
        num = 11
    else:
        num = 10
    
    data_out_dut = 0

    for i in range(num):
        bit = int(dut.uo_out.value[0])
        data_out_dut |= (bit << i) 
        await FallingEdge(dut.clk)

    assert data_out_dut == data_out_expec, (
            f"Test Case {num_test} is failed\n"
            f"Expected={data_out_expec}, "
            f"Got={data_out_dut}"
        )


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
            f"BUSY={int(dut.uo_out.value[1])},"
            f"TX={int(dut.uo_out.value[0])},"
        )
    else:
        dut._log.error(
            f"Reset is failed,"
            f"BUSY={int(dut.uo_out.value[1])},"
            f"TX={int(dut.uo_out.value[0])},"
        )
    dut.rst_n.value = 1

     # Read input files
    with open("DATA_h.txt","r") as f:
        DATA_IN = [
            int(line.strip(), 16)
            for line in f
            if line.strip()
        ]

    with open("Expec_Out_b.txt", "r") as f:
        Expec_Outs = [
            int(line.strip(), 2)
            for line in f
            if line.strip()
        ]

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    # ODD PARITY
    dut.uio_in.value[1] = 1
    dut.uio_in.value[0] = 1
    for TEST_NUM in range(0, 2):
        await data_tx(
            dut,
            DATA_IN[TEST_NUM]
        )

        await check_data_out(
            dut,
            Expec_Outs[TEST_NUM],
            TEST_NUM
        )

    # EVEN PARITY
    dut.uio_in.value[0] = 0
    for TEST_NUM in range(2, 4):
        await data_tx(
            dut,
            DATA_IN[TEST_NUM]
        )

        await check_data_out(
            dut,
            Expec_Outs[TEST_NUM],
            TEST_NUM
        )
    
    for _ in range(4):
        await FallingEdge(dut.clk)
    
    # NO PARITY
    dut.uio_in.value[1] = 0
    for TEST_NUM in range(4, 6):
        await data_tx(
            dut,
            DATA_IN[TEST_NUM]
        )

        await check_data_out(
            dut,
            Expec_Outs[TEST_NUM],
            TEST_NUM
        )
    
    dut._log.info("UART TX test completed")


    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    #assert dut.uo_out.value == 50

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
