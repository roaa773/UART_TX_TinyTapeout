module serializer #(parameter DATA_WIDTH = 8)
(
	input  clk,    
	input  rst,
	input  [DATA_WIDTH-1:0] parallel_data,
	input  ser_en,
	input  data_valid,
	output reg ser_done,
	output reg ser_data
);

reg [2:0] cnt;
reg [DATA_WIDTH-1:0] data_reg;

always @(posedge clk or negedge rst) begin
    if(~rst) begin
        data_reg <= 0;
        ser_data <= 0;
    end
	else if(data_valid) 
			//if(cnt == 0)
		{data_reg,ser_data} <= {1'b0,parallel_data};
	else if(ser_en)
		{data_reg,ser_data} <= {1'b0,data_reg};		
end

always @(*) begin
		if(ser_en) begin
			if(cnt == 7)begin
				ser_done = 1;
			end
			else
				ser_done = 0;
		end
		else 
			ser_done = 0;
end


always @(posedge clk or negedge rst) begin 
	if(~rst) begin
		cnt <= 0;
	end 
	else if(ser_en) begin
		cnt <= cnt + 1;
	end
	else
		cnt <= 0;
end

endmodule : serializer