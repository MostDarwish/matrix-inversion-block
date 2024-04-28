module Vectoring_CORDIC_TB();

parameter WORDLEN = 16;

reg  		[WORDLEN-1:0]   regfile_out1;
reg 		[WORDLEN-1:0]   regfile_out2;
reg     			 		Valid;
reg   				 	    RST_n;
reg 				        CLK;
reg 						First_Flag; //for testing only
wire signed [WORDLEN-1:0]   Mag_Vect_Out_Reg;
wire signed [WORDLEN-1:0]   Theta_Vect_Out_Reg;
wire 						Vect_Done; 


Vectoring_CORDIC DUT (
	.regfile_out1(regfile_out1),
	.regfile_out2(regfile_out2),
	.valid_vec(Valid),
	.RST_n(RST_n),
	.CLK(CLK),
	.vec_out_mag(Mag_Vect_Out_Reg),
	.vec_out_theta(Theta_Vect_Out_Reg),
	.done_vec(Vect_Done)
);

initial begin
	CLK = 0;
	forever
		#1 CLK = ~CLK;
end

initial begin
	RST_n = 0;
	#10
	RST_n = 1;
end

always@(posedge CLK) begin
	if(First_Flag) begin
		Valid = 1;
		First_Flag = 0;
	end
	else if(Vect_Done) Valid = 1;
	else Valid = 0;

end

task input_stim;
    input signed [15:0] X, Y;
    begin
		regfile_out1 = X<<<12;
		regfile_out2 = Y<<<12;
    end

endtask

initial begin //valid range is the range where sqrt(x^2+y^2) <= 20 to get error less than 3%
	input_stim(3,7);
	#20
	First_Flag = 1;
	wait(Vect_Done == 1);
	input_stim(-3,7);
	#3
	wait(Vect_Done == 1);
	input_stim(-3,-7);
	#3
	wait(Vect_Done == 1);
	input_stim(3,-7);
	#3
	wait(Vect_Done == 1);
	input_stim(5,10);
	#3
	wait(Vect_Done == 1);
	input_stim(-5,-10);
	#3
	wait(Vect_Done == 1);
	input_stim(5,-10);
	#3
	wait(Vect_Done == 1);
	$stop;
end

endmodule