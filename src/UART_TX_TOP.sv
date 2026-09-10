`default_nettype none

module tt_um_UART_TX #(parameter DATA_WIDTH = 8,
	                 parameter logic START_BIT  = 0,
	                 parameter logic STOP_BIT   = 1)
(
	input  wire       ena,      // always 1 when the design is powered, so you can ignore it
	input  clk,
	input  rst_n,
	input  wire [7:0] uio_in,   // IOs: Input path
	//input  PAR_TYP, uio_in[0]
	//input  PAR_EN, uio_in[1]
	input  [DATA_WIDTH-1:0] ui_in,
	//input  DATA_VALID, uio_in[2]
	output [7:0] uo_out,
	//output TX_OUT, uo_out[0]
	//output BUSY  uo_out[1]
	output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe   // IOs: Enable path (active high: 0=input, 1=output)
);
wire s_en, s_done, s_data, p_bit;
wire [2:0] m_sel;

assign 	uio_out = 0;
assign 	uio_oe = 0;
assign 	uo_out[7:2] = 0;	

wire _unused = &{ena,uio_in[7:3], 1'b0};
	
FSM fsm(
.clk        (clk),
.rst        (rst_n),
.data_valid (uio_in[2]),
.parity_en  (uio_in[1]),
.serial_done(s_done),
.serial_en  (s_en),
.mux_sel    (m_sel),
.busy       (uo_out[1])
);

serializer ser(
.clk          (clk),
.rst          (rst_n),
.parallel_data(ui_in),
.ser_en       (s_en),
.ser_done     (s_done),
.ser_data     (s_data)
);

parity_calc par(
.clk        (clk),
.rst        (rst_n),
.data       (ui_in),
.valid      (uio_in[2]),
.parity_type(uio_in[0]),
.parity_bit (p_bit)
);

MUX mux(
.select   (m_sel),
.start_bit(START_BIT),
.stop_bit (STOP_BIT),
.data     (s_data),
.par_bit  (p_bit),
.mux_out  (uo_out[0])
);

endmodule 
