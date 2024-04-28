module Vectoring_CORDIC
#(parameter WORDLEN = 16, N_STAGES = 12, COUNTLEN = 4, SCALING_FACTOR = 16'h09b8)
(
	input  wire 		[WORDLEN-1:0]  regfile_out1,
	input  wire 		[WORDLEN-1:0]  regfile_out2,
	input  wire 					   valid_vec,
	input  wire          		       RST_n,
	input  wire 	 			   	   CLK,

	output reg signed  [WORDLEN-1:0]   vec_out_mag,
	output reg signed  [WORDLEN-1:0]   vec_out_theta,
	output reg  					   done_vec
);

reg  signed [WORDLEN-1:0]   X_Vect_In_Reg;
reg  signed [WORDLEN-1:0]   Y_Vect_In_Reg;
reg  signed [WORDLEN-1:0]   X_Vect_Curr_Reg;
reg  signed [WORDLEN-1:0]   Y_Vect_Curr_Reg;
reg  signed [2*WORDLEN-1:0] X_Vect_Out_Temp;
reg  signed [WORDLEN-1:0]   Theta_Vect_Curr_Reg;
reg  signed [WORDLEN-1:0]   Theta_Vect_Out_Temp;
reg 	    [COUNTLEN-1:0]  Count;
reg 			    	    Y_In_Sign;
reg 						X_In_Sign;
wire signed [15:0]          ARCTAN_LUT [0:11];
wire signed [15:0] 			Pi;
wire signed [31:0] 		  	In_Vect;

assign In_Vect        = {regfile_out1,regfile_out2};
assign Pi 			  = 16'h0C91;
assign ARCTAN_LUT[0]  = 16'h0c90;
assign ARCTAN_LUT[1]  = 16'h076b;
assign ARCTAN_LUT[2]  = 16'h03eb;
assign ARCTAN_LUT[3]  = 16'h01fd;
assign ARCTAN_LUT[4]  = 16'h00ff;
assign ARCTAN_LUT[5]  = 16'h007f;
assign ARCTAN_LUT[6]  = 16'h003f;
assign ARCTAN_LUT[7]  = 16'h001f;
assign ARCTAN_LUT[8]  = 16'h000f;
assign ARCTAN_LUT[9]  = 16'h0007;
assign ARCTAN_LUT[10] = 16'h0003;
assign ARCTAN_LUT[11] = 16'h0001;


always@(posedge CLK or negedge RST_n)begin
	if(~RST_n)begin
		X_Vect_In_Reg   	<= 0;
		X_Vect_Curr_Reg 	<= 0;
		X_Vect_Out_Temp 	<= 0;
		vec_out_mag   	    <= 0;
		Y_Vect_In_Reg   	<= 0;
		Y_Vect_Curr_Reg 	<= 0;
		Theta_Vect_Curr_Reg <= 0;
		Theta_Vect_Out_Temp <= 0;
		vec_out_theta      <= 0;
		X_In_Sign       	<= 0;
		Y_In_Sign       	<= 0;
		Count           	<= 0;
		done_vec 		    <= 0;
	end
	else begin
		case(Count)
			3'b000: begin
				done_vec <= 0;
				if(valid_vec)begin
					X_In_Sign     <= In_Vect[2*WORDLEN-1];
					Y_In_Sign     <= In_Vect[WORDLEN-1];
					X_Vect_In_Reg <= In_Vect[2*WORDLEN-1] ? ~(In_Vect[2*WORDLEN-1:WORDLEN])+1'b1 : In_Vect[2*WORDLEN-1:WORDLEN];
					Y_Vect_In_Reg <= In_Vect[WORDLEN-1:0];
					Count 		  <= Count + 1;
				end
			end
			4'b0001: begin
				X_Vect_Curr_Reg 	<= Y_Vect_In_Reg[WORDLEN-1]   ? X_Vect_In_Reg - (Y_Vect_In_Reg >>> (Count-1))  : X_Vect_In_Reg + (Y_Vect_In_Reg >>> (Count-1));
				Y_Vect_Curr_Reg 	<= Y_Vect_In_Reg[WORDLEN-1]   ? Y_Vect_In_Reg + (X_Vect_In_Reg >>> (Count-1))  : Y_Vect_In_Reg - (X_Vect_In_Reg >>> (Count-1));
				Theta_Vect_Curr_Reg <= Y_Vect_In_Reg[WORDLEN-1]   ? 16'b0 - ARCTAN_LUT[Count-1]  		  		   : 16'b0 + ARCTAN_LUT[Count-1];
				Count 				<= Count + 1;
			end
			4'b0010: begin
				COR_Stage(Count);
				Count <= Count + 1'b1;			
			end
			4'b0011: begin
				COR_Stage(Count);
				Count <= Count + 1'b1;
			end
			4'b0100: begin
				COR_Stage(Count);
				Count <= Count + 1'b1;
			end
			4'b0101: begin
				COR_Stage(Count);
				Count <= Count + 1'b1;
			end
			4'b0110: begin
				COR_Stage(Count);
				Count <= Count + 1'b1;
			end
			4'b0111: begin
				COR_Stage(Count);
				Count <= Count + 1'b1;
			end
			4'b1000: begin
				COR_Stage(Count);
				Count <= Count + 1'b1;
			end
			4'b1001: begin
				COR_Stage(Count);
				Count <= Count + 1'b1;
			end
			4'b1010: begin
				COR_Stage(Count);
				Count <= Count + 1'b1;
			end
			4'b1011: begin
				COR_Stage(Count);
				Count <= Count + 1'b1;
			end
			4'b1100: begin
				X_Vect_Out_Temp     <= X_Vect_Curr_Reg * SCALING_FACTOR;
				Theta_Vect_Out_Temp <= X_In_Sign ? (Y_In_Sign ? -(Pi + Theta_Vect_Curr_Reg) : Pi - Theta_Vect_Curr_Reg) : Theta_Vect_Curr_Reg;
				Count 			    <= Count + 1;
			end
			4'b1101: begin
				vec_out_mag    <= X_Vect_Out_Temp >>> N_STAGES;
				vec_out_theta <= Theta_Vect_Out_Temp;
				done_vec 		   <= 1;
				Count 		       <= 0;
			end
		endcase	
	end
end

task COR_Stage;
    input [COUNTLEN-1:0] Count;
    begin
		X_Vect_Curr_Reg 	<= Y_Vect_Curr_Reg [WORDLEN-1]  ? X_Vect_Curr_Reg - (Y_Vect_Curr_Reg >>> (Count-1))  : X_Vect_Curr_Reg + (Y_Vect_Curr_Reg >>> (Count-1));
		Y_Vect_Curr_Reg 	<= Y_Vect_Curr_Reg [WORDLEN-1]  ? Y_Vect_Curr_Reg + (X_Vect_Curr_Reg >>> (Count-1))  : Y_Vect_Curr_Reg - (X_Vect_Curr_Reg >>> (Count-1));
		Theta_Vect_Curr_Reg <= Y_Vect_Curr_Reg [WORDLEN-1]  ? Theta_Vect_Curr_Reg - ARCTAN_LUT[Count-1]  		 : Theta_Vect_Curr_Reg + ARCTAN_LUT[Count-1];
    end

endtask

endmodule