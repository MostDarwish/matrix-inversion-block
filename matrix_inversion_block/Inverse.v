module Inverse 
(
	input      signed  [15:0] regfile_out1,
	input 	   signed  [15:0] regfile_out2,
	input 	             	  start_inverse,
	input 		         	  valid_inverse,
	input 				 	  CLK,
	input 				 	  RST_n,

	output reg signed [15:0]  r_mat_inv,
	output reg 	  		 	  done_inverse
);
integer i,j;

reg  signed   [15:0] Matrix [0:2][0:2];
reg 	 	  [1:0]  Curr_Column;
reg 		  [2:0]  Count;
reg      	    	 CORDIC_En;
reg  signed   [31:0] CORDIC_In_Data;
reg 		  [1:0]  Curr_Out_Row;
reg 		  [1:0]  Curr_Out_Col;
reg  signed	  [15:0] Mul1_In1;
reg  signed	  [15:0] Mul1_In2;
reg  signed	  [15:0] Mul2_In1;
reg  signed	  [15:0] Mul2_In2;
wire signed	  [31:0] Mul1_Out_Temp;
wire signed   [31:0] Mul2_Out_Temp;
wire signed	  [15:0] Mul1_Out;
wire signed   [15:0] Mul2_Out;
wire signed	  [15:0] CORDIC_Out_Data;
wire      		     CORDIC_Done;

reg [2:0] State;
parameter Idle            = 3'b000;
parameter COR_Mul_Prep_In = 3'b001;
parameter COR_On          = 3'b011;
parameter COR_Wait		  = 3'b010;
parameter Additional_Mul  = 3'b110;
parameter Wait_Valid      = 3'b100;
parameter Wait_Start      = 3'b101;
parameter Out_Data        = 3'b111;

Vectoring_CORDIC C1 (

	.regfile_out1(CORDIC_In_Data[31:16]),
	.regfile_out2(CORDIC_In_Data[15:0]),
	.valid_vec(CORDIC_En),
	.RST_n(RST_n),
	.CLK(CLK),

	.vec_out_theta(CORDIC_Out_Data),
	.done_vec(CORDIC_Done)
);

assign Mul1_Out_Temp = Mul1_In1 * Mul1_In2;
assign Mul2_Out_Temp = Mul2_In1 * Mul2_In2;
assign Mul1_Out 	 = Mul1_Out_Temp[27:12];
assign Mul2_Out 	 = Mul2_Out_Temp[27:12];

always@(posedge CLK or negedge RST_n)begin
	if(~RST_n)begin
		for(i=0;i<3;i=i+1)begin
			for(j=0;j<3;j=j+1)begin
				Matrix[i][j]<=0;
			end
		end
		CORDIC_En 		<= 0;
		CORDIC_In_Data  <= 0;
		Curr_Out_Row	<= 0;
		Curr_Out_Col  	<= 0;
		Mul1_In1 		<= 0;
		Mul1_In2 		<= 0;
		Mul2_In1  		<= 0;
		Mul2_In2 		<= 0;
		r_mat_inv 		<= 0;
		done_inverse  	<= 0;
		Count			<= 0;
		Curr_Column 	<= 0;
		State			<= Idle;
	end
	else begin
		case(State)
			Idle: begin
				done_inverse <= 1'b0;
				if(valid_inverse)begin
					Matrix[0][0] <= regfile_out1;
					Matrix[0][1] <= regfile_out2;
					State 		 <= COR_Mul_Prep_In;
				end
				else
					State <= Idle;
			end
			COR_Mul_Prep_In: begin
				case(Curr_Column)
					2'h0: begin
						CORDIC_In_Data <= Matrix [0][0][15] ? {-1*Matrix[0][0],16'hF000} : {Matrix[0][0],16'h1000};
						State <= COR_On;
					end
					2'h1: begin
						CORDIC_In_Data <= Matrix [1][1][15] ? {-1*Matrix[1][1],16'hF000} : {Matrix[1][1],16'h1000};
						Mul1_In1 	   <= Matrix [0][0];
						Mul1_In2	   <= -1*Matrix [0][1];
						State <= COR_On;
					end
					2'h2: begin
						CORDIC_In_Data <= Matrix [2][2][15] ? {-1*Matrix[2][2],16'hF000} : {Matrix[2][2],16'h1000};
						Mul1_In1 	   <= Matrix [0][0];
						Mul1_In2	   <= -1*Matrix [0][2];
						Mul2_In1	   <= -1*Matrix [1][2];
						Mul2_In2	   <= Matrix [0][1];
						State <= COR_On;
					end
				endcase
			end
			COR_On: begin
				CORDIC_En <= 1;
				State 	  <= COR_Wait;
			end
			COR_Wait: begin
				CORDIC_En <= 0;
				case(Curr_Column)
					2'h0: begin
						if(CORDIC_Done)begin
							Matrix [0][0] <= CORDIC_Out_Data;
							Curr_Column   <= Curr_Column + 1'b1;
							done_inverse  <= 1'b1;
							State 	 	  <= Wait_Valid;
						end
					end
					2'h1: begin
						if(CORDIC_Done)begin
							Matrix [1][1] <= CORDIC_Out_Data;
							Matrix [0][1] <= Mul1_Out;
							State 		  <= Additional_Mul;
						end
					end
					2'h2: begin
						if(CORDIC_Done)begin
							Matrix [2][2] <= CORDIC_Out_Data;
							Matrix [0][2] <= Mul1_Out;
							Matrix [1][0] <= Mul2_Out;
							State 		  <= Additional_Mul;
						end
					end
				endcase
			end
			Additional_Mul: begin
				case(Curr_Column)
					2'h1: begin
						Mul1_In1 <= Matrix [0][1];
						Mul1_In2 <= Matrix [1][1];
						if(Count == 5)begin
							Count <= 0;
							Curr_Column <= Curr_Column + 1'b1;
							Matrix [0][1] <= Mul1_Out;
							State <= Wait_Valid;
							done_inverse  <= 1'b1;
						end
						else Count <= Count + 1'b1;
					end
					2'h2: begin
						Mul1_In1 <= Matrix [1][1];
						Mul1_In2 <= -1*Matrix [1][2];
						Mul2_In1 <= Matrix [1][0];
						Mul2_In2 <= Matrix [2][2];
						if(Count == 5)begin
							Count <= 0;
							Curr_Column <= Curr_Column + 1'b1;
							Matrix [1][2] <= Mul1_Out;
							Matrix [1][0] <= Mul2_Out;
						end
						else Count <= Count + 1'b1;		
					end
					2'h3: begin
						Mul1_In1 <= Matrix [1][2];
						Mul1_In2 <= Matrix [2][2];
						Mul2_In1 <= Matrix [0][2];
						Mul2_In2 <= Matrix [2][2];
						if(Count == 5)begin
							Count <= 0;
							Curr_Column  <= 0;
							Matrix[1][2] <= Mul1_Out;
							Matrix[0][2] <= Mul2_Out + Matrix[1][0];
							Matrix[1][0] <= 0;
							done_inverse <= 1;
							State 		 <= Wait_Start;
						end
						else Count <= Count + 1'b1;
					end
				endcase
			end
			Wait_Valid: begin
				done_inverse <= 0;
				case(Curr_Column)
					2'h1: begin
						if(valid_inverse)begin
							Matrix [1][1] <= regfile_out1;
							Matrix [0][2] <= regfile_out2;
							State <= COR_Mul_Prep_In;
						end
					end
					2'h2: begin
						if(valid_inverse)begin
							Matrix [2][2] <= regfile_out1;
							Matrix [1][2] <= regfile_out2;
							State <= COR_Mul_Prep_In;
						end
					end
				endcase
			end
			Wait_Start: begin
				done_inverse <= 0;
				if(start_inverse)begin
					State <= Out_Data;
					r_mat_inv <= Matrix [Curr_Out_Row][Curr_Out_Col];
					Curr_Out_Col <= Curr_Out_Col + 1'b1;
				end
				else
					State <= Wait_Start;
			end
			Out_Data: begin
				r_mat_inv <= Matrix [Curr_Out_Row][Curr_Out_Col];
				if(Curr_Out_Col == 2'd2 && Curr_Out_Row == 2'd2)begin
					Curr_Out_Col <= 0;
					Curr_Out_Row <= 0;
					done_inverse <= 1'b1;
					State 		 <= Idle;
				end	
				else if(Curr_Out_Col == 2'd2)begin
					Curr_Out_Col <= 0;
					Curr_Out_Row <= Curr_Out_Row + 1'b1;
				end
				else begin
					Curr_Out_Col <= Curr_Out_Col + 1'b1;
				end
			end		
		endcase
	end
end
endmodule