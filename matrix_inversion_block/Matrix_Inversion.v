module Matrix_Inversion #(
        parameter   N_STAGES = 12,
        parameter   FRACTION_WIDTH = 12,
        parameter   SCALING_FACTOR = 16'h09b8,
        parameter   WORDLEN = 16,
        parameter   MATRIX_ROWS = 3,
        parameter   MATRIX_COLUMNS = 3,
        parameter   MATRIX_ELEMENT_NUM = MATRIX_ROWS * MATRIX_COLUMNS,
        parameter   MATRIX_WIDTH = MATRIX_ELEMENT_NUM * WORDLEN
    ) (
        input           wire                            CLK,
        input           wire                            RST_n,
        
        ////////////////////////////// Handshake with User ////////////////////////////
        input   wire                                    start,
        output  wire                                    done,
        output  wire    signed  [WORDLEN-1:0]      data_out      
    );
    
    /* Internal Wires */
    // FSM and register file
    wire                                valid_regfile;
    wire            [1:0]               opr_regfile;
    
    // FSM and Vector Cordic
    wire                                done_vec;
    wire                                valid_vec;
    
    // FSM and all Rotational Cordic
    wire                                done_rot1;
    wire                                done_rot2;
    wire                                done_rot3;
    wire                                valid_rot1;
    wire                                valid_rot2;
    wire                                valid_rot3;
    
    // FSM and mul_transpose block
    wire                                valid_transpose;
    wire                                start_transpose;
    
    // FSM and inverse block
    wire                                done_inverse;
    wire                                valid_inverse;
    wire                                start_inverse;
    
    // FSM and mul block
    wire                                done_mul;
    wire                                valid_mul;
    
    // register file and Vector Cordic
    wire    signed  [WORDLEN-1:0]       vec_out_mag;
    wire    signed  [WORDLEN-1:0]       regfile_out1;
    wire    signed  [WORDLEN-1:0]       regfile_out2;
    
    // transpose and Rotational Cordic
    wire    signed  [WORDLEN-1:0]       rot_out1_opr1;
    wire    signed  [WORDLEN-1:0]       rot_out1_opr2;
    
    // register file and one of Rotaional Cordic 
    wire    signed  [WORDLEN-1:0]       rot_out2_opr1;
    wire    signed  [WORDLEN-1:0]       rot_out2_opr2;
    wire    signed  [WORDLEN-1:0]       regfile_out3;
    wire    signed  [WORDLEN-1:0]       regfile_out4;
    
    // register file and another Rotational Cordic
    wire    signed  [WORDLEN-1:0]       rot_out3_opr1;
    wire    signed  [WORDLEN-1:0]       rot_out3_opr2;
    wire    signed  [WORDLEN-1:0]       regfile_out5;
    wire    signed  [WORDLEN-1:0]       regfile_out6;
    
    // Inverse block and Multiplier block
    wire    signed  [WORDLEN-1:0]       transpose_out;
    
    // Matrix multilpier Output
    wire    signed  [WORDLEN-1:0]  mul_out;
    
    // Vector Cordic and Rotational Cordic
    wire    signed  [WORDLEN-1:0]       vec_out_theta;
    wire    signed  [WORDLEN-1:0]       vec_out_theta_neg;
    
    // Inverse and Multiplican blocks
    wire    signed  [WORDLEN-1:0]       r_mat_inv;
    
    /* Assign negative theta */
    assign vec_out_theta_neg = -vec_out_theta;
    
    /* Assign the Output */
    assign  data_out = mul_out;
    
    ////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////// Instantiations ////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    
    // Instantiate FSM
    FSM U0_FSM (
        .CLK(CLK),
        .RST_n(RST_n),
        .start(start),
        .done(done),
        .done_vec(done_vec),
        .valid_vec(valid_vec),
        .valid_regfile(valid_regfile),
        .opr_regfile(opr_regfile),
        .done_rot1(done_rot1),
        .done_rot2(done_rot2),
        .done_rot3(done_rot3),
        .valid_rot1(valid_rot1),
        .valid_rot2(valid_rot2),
        .valid_rot3(valid_rot3),
        .valid_transpose(valid_transpose),
        .start_transpose(start_transpose),
        .done_inverse(done_inverse),
        .valid_inverse(valid_inverse),
        .start_inverse(start_inverse),
        .done_mul(done_mul),
        .valid_mul(valid_mul)
    );
    
    // Instantiate register file
    regfile #(.WORDLEN(WORDLEN), .MATRIX_ROWS(MATRIX_ROWS), .MATRIX_COLUMNS(MATRIX_COLUMNS)) U0_regfile (
        .CLK(CLK),
        .RST_n(RST_n),
        .valid_regfile(valid_regfile),
        .opr_regfile(opr_regfile),
        .vec_out_mag(vec_out_mag),
        .regfile_out1(regfile_out1),
        .regfile_out2(regfile_out2),
        .rot_out2_opr1(rot_out2_opr1),
        .rot_out2_opr2(rot_out2_opr2),
        .regfile_out3(regfile_out3),
        .regfile_out4(regfile_out4),
        .rot_out3_opr1(rot_out3_opr1),
        .rot_out3_opr2(rot_out3_opr2),
        .regfile_out5(regfile_out5),
        .regfile_out6(regfile_out6)
    );
    
    // Instantiate First Rotational Cordic Used to get Sine and Cosine
    Rotational_Cordic #(.WORDLEN(WORDLEN), .FRACTION_WIDTH(FRACTION_WIDTH), .N_STAGES(N_STAGES)) U0_Rotational_Cordic (
        .CLK(CLK),
        .RST_n(RST_n),   
        .regfile_out_opr1(16'd4096),
        .regfile_out_opr2(16'b0),
        .vec_out_theta(vec_out_theta_neg),
        .valid_rot(valid_rot1),
        .done_rot(done_rot1),
        .rot_out_opr1(rot_out1_opr1),
        .rot_out_opr2(rot_out1_opr2)
    );
    
    // Instantiate Second Rotational Cordic used to update Second Column in the matrix
    Rotational_Cordic #(.WORDLEN(WORDLEN), .FRACTION_WIDTH(FRACTION_WIDTH), .N_STAGES(N_STAGES)) U1_Rotational_Cordic (
        .CLK(CLK),
        .RST_n(RST_n),   
        .regfile_out_opr1(regfile_out3),
        .regfile_out_opr2(regfile_out4),
        .vec_out_theta(vec_out_theta_neg),
        .valid_rot(valid_rot2),
        .done_rot(done_rot2),
        .rot_out_opr1(rot_out2_opr1),
        .rot_out_opr2(rot_out2_opr2)
    );
    
    // Instantiate Third Rotational Cordic used to update Third Column in the matrix
    Rotational_Cordic #(.WORDLEN(WORDLEN), .FRACTION_WIDTH(FRACTION_WIDTH), .N_STAGES(N_STAGES)) U2_Rotational_Cordic (
        .CLK(CLK),
        .RST_n(RST_n),   
        .regfile_out_opr1(regfile_out5),
        .regfile_out_opr2(regfile_out6),
        .vec_out_theta(vec_out_theta_neg),
        .valid_rot(valid_rot3),
        .done_rot(done_rot3),
        .rot_out_opr1(rot_out3_opr1),
        .rot_out_opr2(rot_out3_opr2)
    );
    
    // Instantiate Q_Transpose block
    Q_Transpose #(.WORDLEN (WORDLEN), .MATRIX_ELEMENT_NUM (MATRIX_ELEMENT_NUM), .FRACTION_WIDTH(FRACTION_WIDTH)) U0_Q_Transpose (
        .rot_out1_opr1(rot_out1_opr1),
        .rot_out1_opr2(rot_out1_opr2),
        .CLK(CLK),
        .RST_n(RST_n),
        .valid_transpose(valid_transpose),
        .start_transpose(start_transpose),
        .transpose_out(transpose_out)
    );
    
    // Instantiate matrix_multiplication block 
    matrix_multiplication #(.WORDLEN(WORDLEN), .MATRIX_ELEMENT_NUM(MATRIX_ELEMENT_NUM), .FRACTION_WIDTH(FRACTION_WIDTH)) U0_matrix_multiplication (
        .r_mat_inv(r_mat_inv),
        .transpose_out(transpose_out),
        .CLK(CLK),
        .RST_n (RST_n),
        .valid_mul(valid_mul),
        .done_mul(done_mul),
        .mul_out(mul_out)
    );
    
    // Instantiate Vector Cordic
    Vectoring_CORDIC #(.WORDLEN(WORDLEN), .N_STAGES(N_STAGES), .SCALING_FACTOR(SCALING_FACTOR)) U0_Vectoring_CORDIC (
        .regfile_out1(regfile_out1),
        .regfile_out2(regfile_out2),
        .valid_vec(valid_vec),
        .RST_n(RST_n),
        .CLK(CLK),
        .vec_out_mag(vec_out_mag),
        .vec_out_theta(vec_out_theta),
        .done_vec(done_vec)
    );
    
    // Instantiate Inverse block
    Inverse U0_Inverse (
        .regfile_out1(regfile_out1),
        .regfile_out2(regfile_out2),
        .start_inverse(start_inverse),
        .valid_inverse(valid_inverse),
        .CLK(CLK),
        .RST_n(RST_n),
        .r_mat_inv(r_mat_inv),
        .done_inverse(done_inverse)
    );
endmodule