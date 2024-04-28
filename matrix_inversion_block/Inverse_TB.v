module Inverse_TB();

reg  signed [15:0] R_Mat1;
reg  signed [15:0] R_Mat2;
reg				   Start;
reg 			   Valid;
reg 			   CLK;
reg				   RST_n;
wire signed [15:0] R_Mat_Inv;
wire 			   Done;


Inverse 	DUT (
.regfile_out1(R_Mat1),
.regfile_out2(R_Mat2),
.start_inverse(Start),
.valid_inverse(Valid),
.CLK(CLK),
.RST_n(RST_n),

.r_mat_inv(R_Mat_Inv),
.done_inverse(Done)
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

initial begin
	R_Mat1 = 16'd4<<<12;
	R_Mat2 = 16'd4<<<12;
	#13
	Valid = 1;
	#2
	Valid = 0;
	wait(Done == 1);
	#2
	R_Mat1 = 16'd4<<<12;
	R_Mat2 = 16'd4<<<12;
	#2
	Valid = 1;
	#2
	Valid = 0;
	wait(Done == 1);
	#2
	R_Mat1 = 16'd4<<<12;
	R_Mat2 = 16'd4<<<12;
	#2
	Valid = 1;
	#2
	Valid = 0;
	wait(Done == 1);
	#4
	Start = 1;
	#2
	Start = 0;
	wait(Done == 1);
	#10;
	$stop;
end

endmodule