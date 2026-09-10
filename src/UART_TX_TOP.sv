module tt_um_UART_TX #(parameter DATA_WIDTH = 8,
	                 parameter logic START_BIT  = 0,
	                 parameter logic STOP_BIT   = 1)
(
	input  CLK,
	input  RST,
	input  PAR_TYP,
	input  PAR_EN,
	input  [DATA_WIDTH-1:0] P_DATA,
	input  DATA_VALID,
	output TX_OUT,
	output BUSY
);
wire s_en, s_done, s_data, p_bit;
wire [2:0] m_sel;

FSM fsm(
.clk        (CLK),
.rst        (RST),
.data_valid (DATA_VALID),
.parity_en  (PAR_EN),
.serial_done(s_done),
.serial_en  (s_en),
.mux_sel    (m_sel),
.busy       (BUSY)
);

serializer ser(
.clk          (CLK),
.rst          (RST),
.parallel_data(P_DATA),
.ser_en       (s_en),
.ser_done     (s_done),
.ser_data     (s_data)
);

parity_calc par(
.clk        (CLK),
.rst        (RST),
.data       (P_DATA),
.valid      (DATA_VALID),
.parity_type(PAR_TYP),
.parity_bit (p_bit)
);

MUX mux(
.select   (m_sel),
.start_bit(START_BIT),
.stop_bit (STOP_BIT),
.data     (s_data),
.par_bit  (p_bit),
.mux_out  (TX_OUT)
);

endmodule : UART_TX_TOP
