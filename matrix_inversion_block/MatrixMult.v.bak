module  matrix_multiplication
    #(
        parameter   WORDLEN            = 16,
                    MATRIX_ELEMENT_NUM = 9,
                    FRACTION_WIDTH     = 12
    )
    (
        input   wire    signed [WORDLEN-1:0]                                r_mat_inv,
        input   wire    signed [WORDLEN-1:0]                                transpose_out,

        input   wire                                                        CLK,RST_n,
        input   wire                                                        valid_mul, 

        output  reg                                                         done_mul,           
        output  reg     signed  [(WORDLEN) - 1:0]        mul_out
    );

                reg signed [WORDLEN-1:0]                                    matrix_in1 [2:0][2:0];
                reg signed [WORDLEN-1:0]                                    matrix_in2 [2:0][2:0];
                reg signed [(2*WORDLEN+2) - 1:0]                            matrix [2:0][2:0]    ;

    
                reg                                             done_flag;  
                reg                                             cal_flag, output_flag;  
                reg signed    [(2*WORDLEN) - 1:0]             Temp_reg1,Temp_reg2,Temp_reg3;  
                reg           [3:0]                             counter;

                integer                                         i = 0, j = 0 ;      
                
                always @(posedge CLK or negedge RST_n)
                    begin 
                            if (!RST_n)
                                begin 
                                        mul_out         <= 'b0 ;
                                        done_mul        <= 1'b0;
                                        done_flag       <= 1'b0;
                                        cal_flag        <= 1'b0;
                                        output_flag     <= 1'b0;
                                        Temp_reg1       <= 1'b0;
                                        Temp_reg2       <= 1'b0;
                                        Temp_reg3       <= 1'b0;
                                        counter         <= 4'b0;
                                end 
                            else 
                                begin 
                                                if (valid_mul) 
                                                    begin 
                                                            matrix_in1 [i][j] <= r_mat_inv ;
                                                            matrix_in2 [i][j] <= transpose_out ;
                                                            j <= j + 1  ;

                                                            if (j == 2)
                                                                begin 
                                                                    i <= i + 1 ;
                                                                    j <= 0 ;
                                                                end 
                                                    end
                                                if ((matrix_in1 [2][2] != 'd0) & (!output_flag))
                                                    begin 
                                                            cal_flag <= 1'd1 ;

                                                    end 

                                                if (cal_flag)
                                                    begin 
                                                        case (counter)
                                                        4'd0: begin 
                                                            matrix [2][0] <= matrix_in1 [2][2] * matrix_in2 [2][0];  // F * N ; i will take 12 + 15 : 12
                                                            matrix [2][1] <= matrix_in1 [2][2] * matrix_in2 [2][1];  // F * G ; i will take 12 + 15 : 12
                                                            matrix [2][2] <= matrix_in1 [2][2] * matrix_in2 [2][2];  // F * H ; i will take 12 + 15 : 12
                                                            counter       <= counter + 1'd1 ;
                                                            end
                                                        4'd1:   begin 
                                                            Temp_reg1     <= matrix_in1 [0][0] * matrix_in2 [0][0]; // A . M
                                                            Temp_reg2     <= matrix_in1 [0][1] * matrix_in2 [1][0]; // B . Z
                                                            Temp_reg3     <= matrix_in1 [0][2] * matrix_in2 [2][0]; // C . N
                                                            counter       <= counter + 1'd1 ;
                                                            end 
                                                        4'd2:   begin
                                                            matrix [0][0] <= Temp_reg1 + Temp_reg2 + Temp_reg3 ;    // i will take 12 + 15 : 12
                                                            Temp_reg1     <= matrix_in1 [0][1] * matrix_in2 [1][1]; // B . W
                                                            Temp_reg2     <= matrix_in1 [0][2] * matrix_in2 [2][1]; // C . G
                                                            Temp_reg3     <= matrix_in1 [0][0] * matrix_in2 [0][1]; // A . X
                                                            counter       <= counter + 1'd1 ;
                                                            end
                                                        4'd3:   begin 
                                                            matrix [0][1] <= Temp_reg1 + Temp_reg2 + Temp_reg3  ;    // i will take 12 + 15 : 12
                                                            Temp_reg1     <= matrix_in1 [0][2] * matrix_in2 [2][2];  // C . H                                                            Temp_reg2     <= matrix_in1 [0][0] * matrix_in2 [0][2];  // h
                                                            Temp_reg3     <= matrix_in1 [0][1] * matrix_in2 [1][2];  // B . U
                                                            Temp_reg2     <= matrix_in1 [0][0] * matrix_in2 [0][2];  // A . Y
                                                            counter       <= counter + 1'd1 ;
                                                            end
                                                        4'd4:   begin
                                                            matrix [0][2] <= Temp_reg1 + Temp_reg2 + Temp_reg3 ;
                                                            Temp_reg1     <= matrix_in1 [1][1] * matrix_in2 [1][0]; // D . Z
                                                            Temp_reg2     <= matrix_in1 [1][2] * matrix_in2 [2][0]; // E . N
                                                              counter       <= counter + 1'd1 ;
                                                            end
                                                        4'd5:   begin
                                                            matrix [1][0] <= Temp_reg1 + Temp_reg2  ; 
                                                            Temp_reg1     <= matrix_in1 [1][1] * matrix_in2 [1][1]; // D . W
                                                            Temp_reg2     <= matrix_in1 [1][2] * matrix_in2 [2][1]; // E . G 
                                                            counter       <= counter + 1'd1 ;
                                                            end
                                                        4'd6: begin 
                                                            matrix [1][1] <= Temp_reg1 + Temp_reg2;
                                                            Temp_reg1     <= matrix_in1 [1][2] * matrix_in2 [2][2]; // E . H
                                                            Temp_reg2     <= matrix_in1 [1][1] * matrix_in2 [1][2]; // D . U
                                                            counter       <= counter + 1'd1 ;
                                                            end
                                                        4'd7: begin 
                                                            matrix [1][2] <= Temp_reg2 + Temp_reg1;
                                                            output_flag <= 1'b1 ;
                                                            cal_flag    <= 1'b0 ;
                                                            counter     <= 4'd0 ;
                                                        end 
                                                      endcase 
                                                end 
                                                     
                                                if (output_flag)
                                                    begin 
                                                        case (counter)
                                                        4'd0: begin 
                                                            mul_out       <= matrix [0][0][WORDLEN + FRACTION_WIDTH - 1: FRACTION_WIDTH]; 
                                                            done_mul        <= 1'b1 ;
                                                            counter       <= counter + 1'd1 ;
                                                            end
                                                        4'd1:   begin 
                                                            mul_out       <= matrix [0][1][WORDLEN + FRACTION_WIDTH - 1: FRACTION_WIDTH]; 
                                                            done_mul        <= 1'b1 ;
                                                            counter       <= counter + 1'd1 ;
                                                            end 
                                                        4'd2:   begin
                                                            mul_out       <= matrix [0][2][WORDLEN + FRACTION_WIDTH - 1: FRACTION_WIDTH]; 
                                                            done_mul        <= 1'b1 ;
                                                            counter       <= counter + 1'd1 ;
                                                            end
                                                        4'd3:   begin 
                                                            mul_out       <= matrix [1][0][WORDLEN + FRACTION_WIDTH - 1: FRACTION_WIDTH]; 
                                                            done_mul        <= 1'b1 ;
                                                            counter       <= counter + 1'd1 ;
                                                            end
                                                        4'd4:   begin
                                                            mul_out       <= matrix [1][1][WORDLEN + FRACTION_WIDTH - 1: FRACTION_WIDTH]; 
                                                            done_mul        <= 1'b1 ;
                                                            counter       <= counter + 1'd1 ;
                                                            end
                                                        4'd5:   begin
                                                            mul_out       <= matrix [1][2][WORDLEN + FRACTION_WIDTH - 1: FRACTION_WIDTH]; 
                                                            done_mul        <= 1'b1 ;
                                                            counter       <= counter + 1'd1 ;
                                                            end
                                                        4'd6: begin 
                                                            mul_out       <= matrix [2][0][WORDLEN + FRACTION_WIDTH - 1: FRACTION_WIDTH]; 
                                                            done_mul        <= 1'b1 ;
                                                            counter       <= counter + 1'd1 ;
                                                            end
                                                        4'd7: begin 
                                                            mul_out       <= matrix [2][1][WORDLEN + FRACTION_WIDTH - 1: FRACTION_WIDTH]; 
                                                            done_mul      <= 1'b1 ;
                                                            counter       <= counter + 1'd1 ;
                                                        end 
                                                        4'd8: begin 
                                                            mul_out       <= matrix [2][2][WORDLEN + FRACTION_WIDTH - 1: FRACTION_WIDTH]; 
                                                            done_mul      <= 1'b1 ;
                                                            counter       <= counter + 1'd1 ;
                                                            output_flag   <= 1'b0 ;
                                                            matrix [2][2]  <= 'b0;
                                                                end
							 
                                                        endcase
                                                end
					if (!output_flag)
								begin
									mul_out       <= 'b0; 
                                                                        done_mul      <= 1'b0 ;	
								end
                                        end 
                                                             
                                                
                                                
                                end 
                         

endmodule