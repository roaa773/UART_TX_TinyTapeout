module MUX (
	input  [2:0] select,
	input  start_bit,
	input  stop_bit,
	input  data,
	input  par_bit,
	output reg mux_out
);

always @(*) begin 
	case (select)
	    0: mux_out = start_bit;
	    1: mux_out = stop_bit;
	    2: mux_out = data;
	    3: mux_out = par_bit;
	    default: mux_out = 1;
	endcase
end

endmodule : MUX