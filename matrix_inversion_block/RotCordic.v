module Rotational_Cordic
/////////////////////////// Parameter //////////////////////////////////
#(parameter WORDLEN            = 16,               // WORDLENgth of data {4""integer",12 "Fraction"}
            N_STAGES           = 12,               // number of stages --> Rule of thumb, Number of Iterations < WORDLENgth by 4
            FRACTION_WIDTH     = 12 )              // Fracation bit number = 12 
//////////////////////////  Input and Output Ports ////////////////////
(
    input wire  signed [WORDLEN - 1 : 0]     regfile_out_opr1,   // x Input 
    input wire  signed [WORDLEN - 1 : 0]     regfile_out_opr2,   // Y Input 
    input wire  signed [WORDLEN - 1 : 0]     vec_out_theta,      // Theta Input 

    input wire                               CLK,
    input wire                               RST_n,

    input wire                               valid_rot,

    output reg                               done_rot,          
    output reg  signed [WORDLEN - 1 : 0]     rot_out_opr1,       // Updated X
    output reg  signed [WORDLEN - 1 : 0]     rot_out_opr2        // Updated Y

);

////////////////////////    Look-Up Table  //////////////////////////////

            wire signed [WORDLEN - 1: 0]           LUT [N_STAGES  - 1: 0] ;   // Arctan() Look-Up Table


            `define BETA_0  16'h0c90    // = atan 2^0     = 0.7853981633974483

            `define BETA_1  16'h076b    // = atan 2^(-1)  = 0.4636476090008061

            `define BETA_2  16'h03eb    // = atan 2^(-2)  = 0.24497866312686414

            `define BETA_3  16'h01fd    // = atan 2^(-3)  = 0.12435499454676144

            `define BETA_4  16'h00ff    // = atan 2^(-4)  = 0.06241880999595735

            `define BETA_5  16'h007f    // = atan 2^(-5)  = 0.031239833430268277

            `define BETA_6  16'h003f    // = atan 2^(-6)  = 0.015623728620476831

            `define BETA_7  16'h001f    // = atan 2^(-7)  = 0.007812341060101111

            `define BETA_8  16'h000f    // = atan 2^(-8)  = 0.0039062301319669718

            `define BETA_9  16'h0007    // = atan 2^(-9)  = 0.0019531225164788188

            `define BETA_10 16'h0003    // = atan 2^(-10) = 0.0009765621895593195

            `define BETA_11 16'h0001    // = atan 2^(-11) = 0.0004882812111948983

           // `define BETA_12 16'h0000    // = atan 2^(-12) = 0.0002441406201

            assign LUT[0]  = `BETA_0   ;

            assign LUT[1]  = `BETA_1   ;

            assign LUT[2]  = `BETA_2   ;

            assign LUT[3]  = `BETA_3   ;

            assign LUT[4]  = `BETA_4   ;

            assign LUT[5]  = `BETA_5   ;

            assign LUT[6]  = `BETA_6   ;

            assign LUT[7]  = `BETA_7   ;

            assign LUT[8]  = `BETA_8   ;

            assign LUT[9]  = `BETA_9   ;

            assign LUT[10] = `BETA_10  ;

            assign LUT[11] = `BETA_11  ;

            //assign LUT[12] = `BETA_12  ; 

////////////////////////////////////////////////////////////////////////////////////////

            reg signed [WORDLEN :0]          Reg_x_current                       ;   // the size is 17 bit, due to addition process
            reg signed [WORDLEN :0]          Reg_y_current          	         ;   // the size is 17 bit, due to addition process
            reg signed [WORDLEN :0]          Reg_theta_current                   ;   // the size is 17 bit, due to addition process


            wire signed [2*WORDLEN+1:0]      x_factored                          ;   // the size is 34 bits, due to multiplication process (17 bits * 17 bits)
            wire signed [2*WORDLEN+1:0]      y_factored                          ;   // the size is 34 bits, due to multiplication process (17 bits * 17 bits)

            reg signed  [WORDLEN    :0]      correction_factor = 17'h09b8        ; 
        
            wire  signed 				     sign_bit                            ;
            wire   signed [WORDLEN :0]        x_shifted                           ;
            wire   signed [WORDLEN :0]        y_shifted                           ;

            integer                          i                                   ;
            reg                              done_flag,start  					 ;

            
///////////////////////////// Combinational Logic ///////////////////////////////////
            assign  x_shifted   =   $signed((Reg_x_current) >>> i)                        ; // signed shift Right 
            assign  y_shifted   =   $signed((Reg_y_current) >>> i )                      ; // signed shift Right
            assign  sign_bit    =   Reg_theta_current[WORDLEN -1]                ; 
            assign  x_factored  =   $signed(Reg_x_current)*correction_factor     ;
            assign  y_factored  =   $signed(Reg_y_current)*correction_factor     ;

                always @(posedge CLK or negedge RST_n)
                        begin
                            if (!RST_n)
                                begin
                                        done_rot                   <= 1'b0     ;
                                        start                      <= 1'b0     ;
                                        done_flag                  <= 1'b0     ;
                                        rot_out_opr1               <= 'b0      ;
                                        rot_out_opr2               <= 'b0      ;
                                        Reg_x_current              <= 'b0      ;
                                        Reg_y_current              <= 'b0      ;
                                        Reg_theta_current          <= 'h1ffff  ;
                                        i                          <= 1'b0     ;
                                end
                            else
                                begin
                                        if (valid_rot)
                                            begin
                                                Reg_x_current      <= {1'b0,regfile_out_opr1}   ;
                                                Reg_y_current      <= {1'b0,regfile_out_opr2}   ;
                                                Reg_theta_current  <= {1'b0,vec_out_theta}      ;
                                                start              <= 1'b1                      ;
                                                i                  <= 1'b0                      ;
                                            end
                                        if (start)
                                            begin 
                                                    begin 
                                                        Reg_x_current      <= (sign_bit) ? Reg_x_current + y_shifted  : Reg_x_current - y_shifted            ;
                                                        Reg_y_current      <= (sign_bit) ? Reg_y_current - x_shifted  : Reg_y_current + x_shifted            ;
                                                        Reg_theta_current  <= (sign_bit) ? Reg_theta_current + LUT[i] : Reg_theta_current - LUT[i]           ;
                                                        if (i == N_STAGES - 1 )
                                                            begin 
                                                                        start <= 1'b0                       ;
                                                                        done_flag <= 1'b1                   ;
                                                            end
                                                        else 
                                                            begin 
                                                                        i <= i + 1                          ;
                                                            end 
                                                    end 
                                            end
                                            if (done_flag)
                                            begin
                                                done_rot <= 1'b1;
                                                rot_out_opr1 <= x_factored[WORDLEN + FRACTION_WIDTH - 1 : FRACTION_WIDTH];
                                                rot_out_opr2 <= y_factored[WORDLEN + FRACTION_WIDTH - 1 : FRACTION_WIDTH];
                                            end
                                            if (done_rot)
                                            begin 
                                                    done_rot        <= 1'b0;
                                                    done_flag       <= 1'b0;
                                            end 
                                end 
                        end
endmodule