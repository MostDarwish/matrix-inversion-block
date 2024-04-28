`timescale 1ns/1ps

module FSM_regfile_tb ();
    
    ////////////////////////////////////////////////////////////////
    ////////////////////////// Parameters //////////////////////////
    ////////////////////////////////////////////////////////////////
    
    parameter   CLK_PERIOD = 20/3;
    parameter   WORDLEN    = 5'd16;
    parameter   MATRIX_ROWS = 2'd3;
    parameter   MATRIX_COLUMNS = 2'd3;
    
    ////////////////////////////////////////////////////////////////
    ////////////////////// Wires and Register //////////////////////
    ////////////////////////////////////////////////////////////////
    
    reg                                 CLK_tb;
    reg                                 RST_n_tb;
    
    ////////////////////////////// Handshake with User ////////////////////////////
    reg                                 start_tb;
    wire                                done_tb;
    
    ///////////////////////// Handshake with vector cordic ////////////////////////
    reg                                 done_vec_tb;
    wire                                valid_vec_tb;
    
    /////////////////////////// Handshake with regfile ////////////////////////////
    wire                                valid_regfile_tb;
    wire            [1:0]               opr_regfile_tb;
    
    ////////////////// Handshake with the three rotational cordics ////////////////
    reg                                 done_rot1_tb;
    reg                                 done_rot2_tb;
    reg                                 done_rot3_tb;
    wire                                valid_rot1_tb;
    wire                                valid_rot2_tb;
    wire                                valid_rot3_tb;
    
    ////////////// Handshake with the multiplier and transpose block //////////////
    wire                                valid_transpose_tb;
    wire                                start_transpose_tb;
    
    /////////////////////// Handshake with the inverse block //////////////////////
    reg                                 done_inverse_tb;
    wire                                valid_inverse_tb;
    wire                                start_inverse_tb;
    
    ///////////////////// Handshake with the multiplier block /////////////////////
    reg                                 done_mul_tb;
    wire                                valid_mul_tb;
    
    //////////////// Interface with vector cordic and inverse block ///////////////
    reg     signed  [WORDLEN - 1:0]    vec_out_mag_tb;
    wire    signed  [WORDLEN - 1:0]    regfile_out1_tb;
    wire    signed  [WORDLEN - 1:0]    regfile_out2_tb;
    
    ///////////////////// Interface with rotational cordic 1 //////////////////////
    reg     signed  [WORDLEN - 1:0]    rot_out2_opr1_tb;
    reg     signed  [WORDLEN - 1:0]    rot_out2_opr2_tb;
    wire    signed  [WORDLEN - 1:0]    regfile_out3_tb;
    wire    signed  [WORDLEN - 1:0]    regfile_out4_tb;
    
    ///////////////////// Interface with rotational cordic 2 //////////////////////
    reg     signed  [WORDLEN - 1:0]    rot_out3_opr1_tb;
    reg     signed  [WORDLEN - 1:0]    rot_out3_opr2_tb;
    wire    signed  [WORDLEN - 1:0]    regfile_out5_tb;
    wire    signed  [WORDLEN - 1:0]    regfile_out6_tb;
    
    // Internal signals for testbench
    reg             [1:0]               type_cordic;
    
    ////////////////////////////////////////////////////////////////
    //////////////////////////// Clock /////////////////////////////
    ////////////////////////////////////////////////////////////////
    
    always #(CLK_PERIOD/2)  CLK_tb = ~CLK_tb;
    
    ////////////////////////////////////////////////////////////////
    //////////////////////// Instantiations ////////////////////////
    ////////////////////////////////////////////////////////////////
    
    FSM DUT_FSM (
        .CLK(CLK_tb),
        .RST_n(RST_n_tb),
        .start(start_tb),
        .done(done_tb),
        .done_vec(done_vec_tb),
        .valid_vec(valid_vec_tb),
        .valid_regfile(valid_regfile_tb),
        .opr_regfile(opr_regfile_tb),
        .done_rot1(done_rot1_tb),
        .done_rot2(done_rot2_tb),
        .done_rot3(done_rot3_tb),
        .valid_rot1(valid_rot1_tb),
        .valid_rot2(valid_rot2_tb),
        .valid_rot3(valid_rot3_tb),
        .valid_transpose(valid_transpose_tb),
        .start_transpose(start_transpose_tb),
        .done_inverse(done_inverse_tb),
        .valid_inverse(valid_inverse_tb),
        .start_inverse(start_inverse_tb),
        .done_mul(done_mul_tb),
        .valid_mul(valid_mul_tb)
    );
    
    regfile #(.WORDLEN(WORDLEN), .MATRIX_ROWS(MATRIX_ROWS), .MATRIX_COLUMNS(MATRIX_COLUMNS)) DUT_regfile (
        .CLK(CLK_tb),
        .RST_n(RST_n_tb),
        .valid_regfile(valid_regfile_tb),
        .opr_regfile(opr_regfile_tb),
        .vec_out_mag(vec_out_mag_tb),
        .regfile_out1(regfile_out1_tb),
        .regfile_out2(regfile_out2_tb),
        .rot_out2_opr1(rot_out2_opr1_tb),
        .rot_out2_opr2(rot_out2_opr2_tb),
        .regfile_out3(regfile_out3_tb),
        .regfile_out4(regfile_out4_tb),
        .rot_out3_opr1(rot_out3_opr1_tb),
        .rot_out3_opr2(rot_out3_opr2_tb),
        .regfile_out5(regfile_out5_tb),
        .regfile_out6(regfile_out6_tb)
    );
    
    ////////////////////////////////////////////////////////////////
    /////////////////////// Variable for loop //////////////////////
    ////////////////////////////////////////////////////////////////
    
    integer i,j;
    
    ////////////////////////////////////////////////////////////////
    //////////////////////// Initial Block /////////////////////////
    ////////////////////////////////////////////////////////////////
    
    initial begin
        
        //Initialization
        initialize();
        
        // Put Values in register file
        for(i=0; i<3;i=i+1) begin
            for(j=0;j<3;j=j+1) begin
                DUT_regfile.mem[i][j] = i*j + 1;
            end
        end
        
        #(CLK_PERIOD);
        
        start_tb = 1'b1;
        
        #(CLK_PERIOD);
        
        start_tb = 1'b0;
        
        //////////////// Test 0 ////////////////
        /************** Only Vector Cordic **************/
        @(posedge valid_vec_tb);
        
        i = 1;
        vector_cordic('b1, 'b1, i);
        
        #(5*CLK_PERIOD);
        
        //////////////// Test 1 ////////////////
        /************** Vector & Rotational Cordic **************/
        done_vec_tb = 1'b1;
        vec_out_mag_tb = 3'b101;
        
        #(CLK_PERIOD);
        done_vec_tb = 'b0;
        
        #(CLK_PERIOD);
        vec_out_mag_tb = 3'b111;
        
        i = 2;
        vector_cordic('b101, 'b1, i);
        
        i = 3;
        type_cordic = 'b0;
        rotational_cordic('b0, 'b0, type_cordic, valid_rot1_tb, 0, 0, i);
        
        i = 4;
        type_cordic = 'b1;
        rotational_cordic('b1, 'b10, type_cordic, valid_rot2_tb, regfile_out3_tb, regfile_out4_tb, i);
        
        i = 5;
        type_cordic = 'b1;
        rotational_cordic('b1, 'b11, type_cordic, valid_rot3_tb, regfile_out5_tb, regfile_out6_tb, i);
        
        #(CLK_PERIOD);
        
        //////////////// Test 2 ////////////////
        /************** Only Rotational Cordics sends data **************/
        // Send done signals
        done_vec_tb = 1'b1;
        done_rot1_tb = 1'b1;
        done_rot2_tb = 1'b1;
        done_rot3_tb = 1'b1;
        
        vec_out_mag_tb = 'b11;
        rot_out2_opr1_tb = 'b101;
        rot_out2_opr2_tb = 'b110;
        rot_out3_opr1_tb = 'b111;
        rot_out3_opr2_tb = 'b1000;
        
        #(CLK_PERIOD);
        done_vec_tb = 1'b0;
        done_rot1_tb = 1'b0;
        done_rot2_tb = 1'b0;
        done_rot3_tb = 1'b0;
        
        @(posedge valid_rot1_tb);
        
        i = 6;
        type_cordic = 'b0;
        rotational_cordic('b0, 'b0, type_cordic, valid_rot1_tb, 0, 0, i);
        
        i = 7;
        type_cordic = 'b1;
        rotational_cordic(rot_out2_opr1_tb, 'b11, type_cordic, valid_rot2_tb, regfile_out3_tb, regfile_out4_tb, i);
        
        i = 8;
        type_cordic = 'b1;
        rotational_cordic(rot_out3_opr1_tb, 'b101, type_cordic, valid_rot2_tb, regfile_out5_tb, regfile_out6_tb, i);
        
        i = 9;
        mul_transpose(i);
        
        #(15*CLK_PERIOD);
        
        //////////////// Test 3 ////////////////
        /************** Only Vector Cordic sends data **************/
        // Send done signals
        // Send done signals
        done_rot1_tb = 1'b1;
        done_rot2_tb = 1'b1;
        done_rot3_tb = 1'b1;
        
        rot_out2_opr1_tb = 'b1010;
        rot_out2_opr2_tb = 'b1001;
        rot_out3_opr1_tb = 'b1011;
        rot_out3_opr2_tb = 'b1100;
        
        #(CLK_PERIOD);
        
        // clear done signals
        done_rot1_tb = 1'b0;
        done_rot2_tb = 1'b0;
        done_rot3_tb = 1'b0;
        
        @(posedge valid_vec_tb);
        
        i = 10;
        vector_cordic('b110, 'b1001, i);
        
        i = 11;
        mul_transpose(i);
        
        #(CLK_PERIOD);
        
        //////////////// Test 4 ////////////////
        /************** Only Rotational Cordic sends data **************/
        // Send done signals
        done_vec_tb = 1'b1;
        
        vec_out_mag_tb = 'b1111;
        
        #(CLK_PERIOD);
        
        done_vec_tb = 1'b0;
        
        @(posedge valid_rot1_tb);
        
        i = 12;
        type_cordic = 'b0;
        rotational_cordic('b0, 'b0, type_cordic, valid_rot1_tb, 0, 0, i);
        
        i = 13;
        type_cordic = 'b1;
        rotational_cordic('b1000, 'b1100, type_cordic, valid_rot2_tb, regfile_out3_tb, regfile_out4_tb, i);
        
        #(5*CLK_PERIOD);
        
        //////////////// Test 5 ////////////////
        /************** Only Vector Cordic sends data **************/
        // Send done signals
        // Send done signals
        done_rot1_tb = 1'b1;
        done_rot2_tb = 1'b1;
        
        rot_out2_opr1_tb = 'b10101;
        rot_out2_opr2_tb = 'b10011;
        
        #(CLK_PERIOD);
        
        // clear done signals
        done_rot1_tb = 1'b0;
        done_rot2_tb = 1'b0;
        
        @(posedge valid_transpose_tb);
        
        i = 14;
        mul_transpose(i);
        
        //////////////// Test 6 ////////////////
        /************** Send to Inverse Block **************/
        
        i = 15;
        inverse('b11, 'b1010, i);
        
        #(15*CLK_PERIOD);
        
        done_inverse_tb = 1'b1;
        
        #(CLK_PERIOD);
        
        done_inverse_tb = 1'b0;
        
        //////////////// Test 7 ////////////////
        /************** Send to Inverse Block **************/
        @(posedge valid_inverse_tb);
        
        i = 16;
        inverse('b1111, 'b1011, i);
        
        #(2*CLK_PERIOD);
        
        done_inverse_tb = 1'b1;
        
        #(CLK_PERIOD);
        
        done_inverse_tb = 1'b0;
        
        //////////////// Test 8 ////////////////
        /************** Send to Inverse Block **************/
        @(posedge valid_inverse_tb);
        
        i = 17;
        inverse('d19, 'd21, i);
        
        #(2*CLK_PERIOD);
        
        done_inverse_tb = 1'b1;
        
        #(CLK_PERIOD);
        
        done_inverse_tb = 1'b0;
        
        //////////////// Test 9 ////////////////
        /************** Sending data to mul **************/
        @(start_inverse_tb);
        
        #(9*CLK_PERIOD);
        
        #(3*CLK_PERIOD);
        
        done_mul_tb = 1'b1;
        
        #(CLK_PERIOD);
        
        done_mul_tb = 1'b0;
        
        #(12*CLK_PERIOD);
        
        // Successful
        $display("Successful");
        
        $stop;
    end
    
    ////////////////////////////////////////////////////////////////
    //////////////////////////// Tasks /////////////////////////////
    ////////////////////////////////////////////////////////////////
    
    // Initialization Task
    task initialize;
        begin
            
            // Clear clock
            CLK_tb = 1'b1;
            
            // Clear input
            start_tb = 'b0;
            
            // Clear all done signals
            done_inverse_tb = 'b0;
            done_mul_tb = 'b0;
            done_rot1_tb = 'b0;
            done_rot2_tb = 'b0;
            done_rot3_tb = 'b0;
            done_vec_tb = 'b0;
            
            // Clear inputs of Regfile
            vec_out_mag_tb = 'b0;
            rot_out2_opr1_tb = 'b0;
            rot_out2_opr2_tb = 'b0;
            rot_out3_opr1_tb = 'b0;
            rot_out3_opr2_tb = 'b0;
            
            // Reset
            reset();
        end
    endtask
    
    // Reset Task
    task reset;
        begin
            
            RST_n_tb = 1'b1;
            
            #(CLK_PERIOD);
            
            RST_n_tb = 1'b0;
            
            #(CLK_PERIOD);
            
            RST_n_tb = 1'b1;
        end
    endtask
    
    // Task to check vector cordic
    task vector_cordic;
        input   [15:0]   in_1;
        input   [15:0]   in_2;
        input   [5:0]   i;
        
        begin
            
            if(valid_vec_tb) begin
                
                $display("vector cordic received valid signal correctly: no.%d", i);
            end
            else begin
                
                $display("Error: vector cordic received valid signal wrongly: no.%d", i);
                
                $stop;
            end
            
            if((regfile_out1_tb == in_1) && (regfile_out2_tb == in_2)) begin
                
                $display("vector cordic received data signal correctly: no.%d", i);
            end
            else begin
                
                $display("Error: vector cordic received data signal wrongly: no.%d", i);
                $display("in_1 = %d, in_2 = %d", in_1, in_2);
                $display("out_1 = %d, out_2 = %d", regfile_out1_tb, regfile_out2_tb);
                $stop;
            end
        end
    endtask
    
    // Task to check rotational cordic
    task rotational_cordic;
        input   [15:0]   in_1;
        input   [15:0]   in_2;
        input           type;
        input           valid;
        input   [15:0]  out_1;
        input   [15:0]  out_2;
        input   [5:0]   i;
        
        begin
            
            if(valid) begin
                
                $display("rotational cordic received valid signal correctly: no.%d", i);
            end
            else begin
                
                $display("Error: rotational cordic received valid signal wrongly: no.%d", i);
                
                $stop;
            end
            
            if(type == 'b1) begin
                
                if((in_1 == out_1) && (in_2 == out_2)) begin
                    
                    $display("rotational cordic received data signal correctly: no.%d", i);
                end
                else begin
                    
                    $display("Error: rotational cordic received data signal correctly: no.%d", i);
                    $display("in_1 = %d, in_2 = %d", in_1, in_2);
                    $display("out_1 = %d, out_2 = %d", out_1, out_2);
                    $stop;
                end
            end
        end
    endtask
    
    // Task to check mul_transpose block
    task mul_transpose;
        input   [5:0]   i;
        
        begin
            
            if(valid_transpose_tb) begin
                
                $display("mul_transpose received valid signal correctly: no.%d", i);
            end
            else begin
                
                $display("Error: mul_transpose received valid signal wrongly: no.%d", i);
                
                $stop;
            end
        end
    endtask
    
    // Task to check inverse block
    task inverse;
        input   [15:0]   in_1;
        input   [15:0]   in_2;
        input   [5:0]   i;
        
        begin
            
            if(valid_inverse_tb) begin
                
                $display("inverse received valid signal correctly: no.%d", i);
            end
            else begin
                
                $display("Error: inverse received valid signal wrongly: no.%d", i);
                
                $stop;
            end
            
            if((regfile_out1_tb == in_1) && (regfile_out2_tb == in_2)) begin
                
                $display("inverse received data signal correctly: no.%d", i);
            end
            else begin
                
                $display("Error: inverse received data signal wrongly: no.%d", i);
                $display("in_1 = %d, in_2 = %d", in_1, in_2);
                $display("out_1 = %d, out_2 = %d", regfile_out1_tb, regfile_out2_tb);
                $stop;
            end
        end
    endtask
endmodule