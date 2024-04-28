`timescale 1ns/1ps

module matrix_multiplication_tb();
       //parameters 
    parameter   WORDLEN = 16,
                 MATRIX_ELEMENT_NUM = 9,
                FRACTION_WIDTH= 12;


        logic        [WORDLEN-1:0]           r_mat_inv;
        logic        [WORDLEN-1:0]           transpose_out;

        logic                                   CLK,RST_n;
        logic                                   valid_mul; 

        logic                                   done_mul;           
        logic        [(WORDLEN) - 1:0]     mul_out;

        /// Instantiation 
    matrix_multiplication
    #(
        .WORDLEN(WORDLEN),
        . MATRIX_ELEMENT_NUM( MATRIX_ELEMENT_NUM ),
        
        .FRACTION_WIDTH(FRACTION_WIDTH)
    ) Dut
    (
        .r_mat_inv   (r_mat_inv),
        .transpose_out   (transpose_out),
        .CLK    (CLK),
        .RST_n  (RST_n),
        .valid_mul (valid_mul),
        .done_mul (done_mul),
        .mul_out(mul_out)
    );

    initial begin 
            CLK     = 0;
            RST_n   = 0;
            valid_mul = 1'b0;
            r_mat_inv = 'b0;
            transpose_out = 'b0;   
            #5
            RST_n = 1;
            
            #10;
            valid_mul = 1'b1;
            r_mat_inv     = 16'h0333;
            transpose_out     = 16'h01ec;
            #10;
            valid_mul = 1'b0;

            #10;
            valid_mul = 1'b1;
            r_mat_inv     = 16'h04cd;
            transpose_out     = 16'hfeb8;
            #10;
            valid_mul = 1'b0;

            #10;
            valid_mul = 1'b1;
            r_mat_inv     = 16'h0666;
            transpose_out     = 16'hf4cd;
            #10;
            valid_mul = 1'b0;

            #10;
            valid_mul = 1'b1;
            r_mat_inv     = 16'H0;
            transpose_out     = 16'H01a4;
            #10;
            valid_mul = 1'b0;

            #10;
            valid_mul = 1'b1;
            r_mat_inv     = 16'H019a;
            transpose_out     = 16'Hff5c;
            #10;
            valid_mul = 1'b0;

            #10;
            valid_mul = 1'b1;
            r_mat_inv     = 16'H0800;
            transpose_out     = 16'Hf733;
            #10;
            valid_mul = 1'b0;

            #10;
            valid_mul = 1'b1;
            r_mat_inv     = 16'H0;
            transpose_out     = 16'h0444;
            #10;
            valid_mul = 1'b0;

            #10;
            valid_mul = 1'b1;
            r_mat_inv     = 16'H0;
            transpose_out     = 16'H01aa;
            #10;
            valid_mul = 1'b0;

            #10;
            valid_mul = 1'b1;
            r_mat_inv     = 16'H0ccd;
            transpose_out     = 16'h0829;
            #10;
            valid_mul = 1'b0;

            #200;
            $stop();
        end
parameter PERIOD = 10; 
always #(PERIOD/2) CLK = ~CLK;




endmodule: matrix_multiplication_tb;