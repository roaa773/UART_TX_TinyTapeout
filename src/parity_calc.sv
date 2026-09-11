module parity_calc #(parameter DATA_WIDTH = 8)
(
	input  clk,
	input  rst,
	input  [DATA_WIDTH-1:0] data,    
	input  valid,
	input  parity_type,
	output reg parity_bit
);

always @(posedge clk or negedge rst) begin
	if(~rst)
		parity_bit <= 0;
	else begin
		if(valid) begin
		    if(~parity_type)
			    parity_bit <= ^data;  //even parity
		    else
			    parity_bit <= ~^data; //odd parity
	    end
	end	
end
endmodule : parity_calc