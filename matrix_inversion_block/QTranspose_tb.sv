`timescale 1ns/1ps

module Q_Transpose_tb();
       //parameters 
    parameter   WORDLEN       = 16, MATRIX_ELEMENT_NUM = 9, 
                FRACTION_WIDTH = 12;


        logic        [WORDLEN-1:0]              rot_out1_opr1;
        logic        [WORDLEN-1:0]              rot_out1_opr2;

        logic                                   CLK,RST_n;
        logic                                   valid_transpose; 

        logic                                   start_transpose;           
        logic        [(WORDLEN) - 1:0]          element_out;

        /// Instantiation 
    Q_Transpose
    #(
        .WORDLEN (WORDLEN),
        .MATRIX_ELEMENT_NUM (MATRIX_ELEMENT_NUM),
        .FRACTION_WIDTH (FRACTION_WIDTH)
    ) Dut
    (
        .rot_out1_opr1   (rot_out1_opr1),
        .rot_out1_opr2   (rot_out1_opr2),
        .CLK    (CLK),
        .RST_n  (RST_n),
        .valid_transpose (valid_transpose),
        .start_transpose (start_transpose),
        .transpose_out(element_out)
    );

    initial begin 
            CLK     = 0;
            RST_n   = 0;
	    rot_out1_opr1 = 'b0;
	    rot_out1_opr2 = 'b0 ;
            valid_transpose = 1'b0;
            start_transpose = 1'b0 ;

            #5
            RST_n = 1;
            
            #10;
            valid_transpose = 1'b1;
            rot_out1_opr1     = 16'h04cd;
            rot_out1_opr2     = 16'h0333;

            #10;
            valid_transpose = 1'b0;
            rot_out1_opr1     = 16'h0;
            rot_out1_opr2     = 16'h0;

            #10;
            valid_transpose = 1'b1;
            rot_out1_opr1     = 16'h0666;
            rot_out1_opr2     = 16'h0B33;

            #10;
            valid_transpose = 1'b0;
            rot_out1_opr1     = 16'h0;
            rot_out1_opr2     = 16'h0;

            #10;
            valid_transpose = 1'b1;
            rot_out1_opr1     = 16'h0400;
            rot_out1_opr2     = 16'h0a66;

            #10;
            valid_transpose = 1'b0;
            rot_out1_opr1     = 16'h0;
            rot_out1_opr2     = 16'h0;

            #100;
            start_transpose = 1'b1 ;
#90
start_transpose = 1'b0 ;


            #200;
            $stop();
        end
parameter PERIOD = 10; 
always #(PERIOD/2) CLK = ~CLK;




endmodule: Q_Transpose_tb;