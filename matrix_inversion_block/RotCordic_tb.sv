`timescale 1ns/1ps

module Rotational_cordic_tb();

/////////////////////////// Parameter //////////////////////////////////
parameter   WORDLEN                 = 16,
            N_STAGES                = 12,
            FRACTION_WIDTH          = 12;

//////////////////////////  Internal Signals ////////////////////
logic                               CLK; 
logic                               RST_n; 
logic signed [WORDLEN-1:0]          regfile_out_opr1;
logic signed [WORDLEN-1:0]          regfile_out_opr2;
logic signed [WORDLEN-1:0]          vec_out_theta;
logic                               valid_rot;

logic                               done_rot;
logic signed  [WORDLEN-1:0]         rot_out_opr1;
logic signed  [WORDLEN-1:0]         rot_out_opr2 ;


parameter PERIOD = 10;



initial begin
    CLK     = 0;
    RST_n   = 0;
    regfile_out_opr1    = 0;
    regfile_out_opr2    = 0;
    vec_out_theta= 0;
    valid_rot = 0;

    #100
    RST_n = 1;

    #105;
    valid_rot = 1'b1;
    regfile_out_opr1     = 16'b0001_000000000000;
    regfile_out_opr2     = 16'b0000_000000000000;
    vec_out_theta        = 16'h0860;  // 30 degree 
    
    #PERIOD
    valid_rot = 1'b0;

    #(14*PERIOD); 
    valid_rot = 1'b1;
    regfile_out_opr1     = 16'b0001_000000000000;
    regfile_out_opr2     = 16'b0000_000000000000;
    vec_out_theta = 16'h02ca;        // 10 Degree
    #PERIOD
    valid_rot = 1'b0;
    
    #(14*PERIOD); 
    valid_rot = 1'b1;
    regfile_out_opr1     = 16'hAFBD;
    regfile_out_opr2     = 16'h543A;
    vec_out_theta = 16'h0C90;     // 45 Degree
    #PERIOD
    valid_rot = 1'b0;
    #(15*PERIOD);
    
    
    $stop();
end

//////////////////////////// Clock Generation ///////////////
always #(PERIOD/2) CLK = ~CLK;


//////////////////////////////// Instantiation //////////////////
Rotational_Cordic
#(
    .WORDLEN (WORDLEN),
    .FRACTION_WIDTH(FRACTION_WIDTH),
    .N_STAGES(N_STAGES)
) Dut
(
    .CLK                    (CLK),
    .RST_n                  (RST_n),   
    .regfile_out_opr1       (regfile_out_opr1),
    .regfile_out_opr2       (regfile_out_opr2),
    .vec_out_theta          (vec_out_theta),
    .valid_rot              (valid_rot),
    .done_rot               (done_rot),
    .rot_out_opr1           (rot_out_opr1),
    .rot_out_opr2           (rot_out_opr2)
);


endmodule: Rotational_cordic_tb