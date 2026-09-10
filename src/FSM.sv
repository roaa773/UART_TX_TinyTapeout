module FSM (
	input  clk,    
	input  rst,
	input  data_valid,
	input  parity_en,
	input  serial_done,
	output reg serial_en,
	output reg [2:0] mux_sel,
	output reg busy 	
);

typedef enum logic [2:0] {
                 IDLE         = 0,
                 START        = 1,
                 PROCESS_DATA = 2,
                 PARITY       = 3,
                 STOP         = 4
} state;

state cs,ns;

always @(posedge clk or negedge rst) begin 
	if(~rst) 
		cs <= IDLE;
	else 
		cs <= ns;
end

always @(*) begin 
	case (cs)
	    IDLE: begin
	    	if(data_valid)
	    		ns = START;
	    	else
	    		ns = IDLE;
	    end

	    START: begin
	    	ns = PROCESS_DATA;
	    end

	    PROCESS_DATA: begin
	    	if(serial_done)begin
	    		if(parity_en)
	    			ns = PARITY;
	    		else
	    			ns = STOP;
	    	end
	    	else
	    		ns = PROCESS_DATA;
	    end

	    PARITY: begin
	    	ns = STOP;
	    end

	    STOP: begin
	    	ns = IDLE;
	    end

		default : ns = IDLE;
	endcase
	
end

always @(*) begin 
	case (cs)
	    IDLE: begin
	    	mux_sel   = 4;
	    	busy      = 0;
	    	serial_en = 0;
	    end

	    START: begin
	    	mux_sel   = 0;
	    	busy      = 1;
	    	serial_en = 0;
	    end

	    PROCESS_DATA: begin
	    	mux_sel   = 2;
	    	busy      = 1;
	    	serial_en = 1;
	    end

	    PARITY: begin
	    	mux_sel   = 3;
	    	busy      = 1;
	    	serial_en = 0;
	    end

	    STOP: begin
	    	mux_sel   = 1;
	    	busy      = 1;
	    	serial_en = 0;
	    end

		default : begin 
			mux_sel   = 4;
			busy      = 0;
			serial_en = 0;
		end
	endcase
	
end

endmodule : FSM