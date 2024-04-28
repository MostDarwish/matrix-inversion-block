module regfile #(
        parameter   WORDLEN = 5'd16,
        parameter   MATRIX_ROWS = 2'd3,
        parameter   MATRIX_COLUMNS = 2'd3
    ) (
        input           wire                          CLK,
        input           wire                          RST_n,
        
        ///////////////////////////// Handshake with FSM //////////////////////////////
        input   wire                                  valid_regfile,
        input   wire                [1:0]             opr_regfile,
        
        //////////////// Interface with vector cordic and inverse block ///////////////
        input   wire    signed      [WORDLEN-1:0]    vec_out_mag,
        output  reg     signed      [WORDLEN-1:0]    regfile_out1,
        output  reg     signed      [WORDLEN-1:0]    regfile_out2,
        
        ///////////////////// Interface with rotational cordic 1 //////////////////////
        input   wire    signed      [WORDLEN-1:0]    rot_out2_opr1,
        input   wire    signed      [WORDLEN-1:0]    rot_out2_opr2,
        output  reg     signed      [WORDLEN-1:0]    regfile_out3,
        output  reg     signed      [WORDLEN-1:0]    regfile_out4,
        
        ///////////////////// Interface with rotational cordic 2 //////////////////////
        input   wire    signed      [WORDLEN-1:0]    rot_out3_opr1,
        input   wire    signed      [WORDLEN-1:0]    rot_out3_opr2,
        output  reg     signed      [WORDLEN-1:0]    regfile_out5,
        output  reg     signed      [WORDLEN-1:0]    regfile_out6
    );
    
    /*
        States:
            1) IDLE: don't make anything
            2) CORDIC_DATA: send data to cordic (whether vector and rotational)
            3) INVERSE_DATA: send data to inverse block
    */
    localparam  [1:0]   IDLE         = 2'b00,
                        CORDIC_DATA  = 2'b01,
                        INVERSE_DATA = 2'b10;
    
    // Register File
    reg signed  [WORDLEN-1:0]    mem [0:MATRIX_ROWS-1][0:MATRIX_COLUMNS-1];
    
    // Internal Counter
    reg     [3:0]       count;
    
    // Internal register
    reg                 flag;
    
    always @(posedge CLK or negedge RST_n) begin
        
        if(!RST_n) begin
            
            // Clear memory
            mem[0][0] <= 'b0;
            mem[0][1] <= 'b0;
            mem[0][2] <= 'b0;
            mem[1][0] <= 'b0;
            mem[1][1] <= 'b0;
            mem[1][2] <= 'b0;
            mem[2][0] <= 'b0;
            mem[2][1] <= 'b0;
            mem[2][2] <= 'b0;
            
            // Clear Counter
            count <= 'b0;
            
            // Clear flag register
            flag <= 'b0;
            
            // Clear Outputs
            regfile_out1 <= 'b0;
            regfile_out2 <= 'b0;
            regfile_out3 <= 'b0;
            regfile_out4 <= 'b0;
            regfile_out5 <= 'b0;
            regfile_out6 <= 'b0;
        end
        else begin
            
            case (opr_regfile)
                IDLE: begin
                    
                    // Clear counter
                    count <= 'b0;
                    
                    // Clear flag register
                    flag <= 'b0;
                    
                    // Clear Outputs
                    regfile_out1 <= 'b0;
                    regfile_out2 <= 'b0;
                    regfile_out3 <= 'b0;
                    regfile_out4 <= 'b0;
                    regfile_out5 <= 'b0;
                    regfile_out6 <= 'b0;
                end
                CORDIC_DATA: begin
                    
                    case (count)
                        'b000: begin
                            
                            // Clear flag register
                            flag <= 'b0;
                            
                            // prepare data for vector cordic
                            regfile_out1 <= mem[0][0];
                            regfile_out2 <= mem[1][0];
                            
                            if(valid_regfile) begin
                                
                                // set flag register
                                flag <= 'b1;
                            end
                        end
                        'b001: begin
                            
                            // Clear flag register
                            flag <= 'b0;
                            
                            // Prepare data for next vector cordic
                            regfile_out1 <= vec_out_mag;
                            regfile_out2 <= mem[2][0];
                            
                            // Prepare data for next rotational cordic 1
                            regfile_out3 <= mem[0][1];
                            regfile_out4 <= mem[1][1];
                            
                            // Prepare data for next rotational cordic 2
                            regfile_out5 <= mem[0][2];
                            regfile_out6 <= mem[1][2];
                            
                            if(valid_regfile) begin
                                
                                // set flag register
                                flag <= 'b1;
                                
                                // Read values of vector cordic and update it in register file
                                mem[0][0] <= vec_out_mag;
                                mem[1][0] <= 'b0;
                            end
                        end
                        'b010: begin
                            
                            // Clear flag register
                            flag <= 'b0;
                            
                            // Prepare data for next rotational cordic 1
                            regfile_out3 <= rot_out2_opr1;
                            regfile_out4 <= mem[2][1];
                            
                            // Prepare data for next rotational cordic 2
                            regfile_out5 <= rot_out3_opr1;
                            regfile_out6 <= mem[2][2];
                            
                            if(valid_regfile) begin
                                
                                // set flag register
                                flag <= 'b1;
                                
                                // Read values of vector cordic and update it in register file
                                mem[0][0] <= vec_out_mag;
                                mem[2][0] <= 'b0;
                                
                                // Read values of both rotational cordic and update it in register file
                                mem[0][1] <= rot_out2_opr1;
                                mem[1][1] <= rot_out2_opr2;
                                mem[0][2] <= rot_out3_opr1;
                                mem[1][2] <= rot_out3_opr2;
                            end
                        end
                        'b011: begin
                            
                            // Clear flag register
                            flag <= 'b0;
                            
                            // Prepare data for next vector cordic
                            regfile_out1 <= mem[1][1];
                            regfile_out2 <= rot_out2_opr2;
                            
                            if(valid_regfile) begin
                                
                                // set flag register
                                flag <= 'b1;
                                
                                // Read values of both rotational cordic and update it in register file
                                mem[0][1] <= rot_out2_opr1;
                                mem[2][1] <= rot_out2_opr2;
                                mem[0][2] <= rot_out3_opr1;
                                mem[2][2] <= rot_out3_opr2;
                            end
                        end
                        'b100: begin
                            
                            // Clear flag register
                            flag <= 'b0;
                            
                            // Prepare data for next rotational cordic 1
                            regfile_out3 <= mem[1][2];
                            regfile_out4 <= mem[2][2];
                            
                            if(valid_regfile) begin
                                
                                // set flag register
                                flag <= 'b1;
                                
                                // Read values of vector cordic and update it in register file
                                mem[1][1] <= vec_out_mag;
                                mem[2][1] <= 'b0;
                            end
                        end
                        'b101: begin
                            
                            // Clear flag register
                            flag <= 'b0;
                            
                            // Send R11 and R12 to inverse block
                            regfile_out1 <= mem[0][0];
                            regfile_out2 <= mem[0][1];
                            
                            if(valid_regfile) begin
                                
                                // set flag register
                                flag <= 'b1;
                                
                                // Read values of rotational cordic 1 and update it in register file
                                mem[1][2] <= rot_out2_opr1;
                                mem[2][2] <= rot_out2_opr2;
                            end
                        end
                    endcase
                    
                    // if received valid signal increment counter, else don't change it's value
                    if(flag) begin
                        
                        // increment counter
                        count <= count + 'b1;
                    end
                end
                INVERSE_DATA: begin
                    
                    case (count)
                        'b101: begin
                            
                            // Send R22 and R13 to inverse block
                            regfile_out1 <= mem[1][1];
                            regfile_out2 <= mem[0][2];
                        end
                        'b110: begin
                            
                            // Send R33 and R23 to inverse block
                            regfile_out1 <= mem[2][2];
                            regfile_out2 <= mem[1][2];
                        end
                    endcase
                    
                    // if received valid signal increment counter, else don't change it's value
                    if(valid_regfile) begin
                        
                        // increment counter
                        count <= count + 'b1;
                    end
                end
            endcase
        end
    end
endmodule