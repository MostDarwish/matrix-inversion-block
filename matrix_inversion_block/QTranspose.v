module Q_Transpose 
#(parameter WORDLEN            = 16 , FRACTION_WIDTH = 12, 
            MATRIX_ELEMENT_NUM = 9)
(
    input  wire  signed [WORDLEN - 1 : 0]    rot_out1_opr1,    // cos theta 
    input  wire  signed [WORDLEN - 1 : 0]    rot_out1_opr2,    // sin theta 
    input  wire                              CLK,
    input  wire                              RST_n,
    input  wire                              valid_transpose,
    input  wire                              start_transpose,
    output reg   signed [WORDLEN - 1 : 0]    transpose_out     // elements of Q transpose with this order A11,A12,A13,A21,A22,A23,A31,A32,A33
); 
   
           reg  signed [WORDLEN - 1 : 0]  matrix_reg [5:0];
           reg  signed [WORDLEN - 1 : 0]  trans_matrix_reg [MATRIX_ELEMENT_NUM - 1 : 0]  ;    // to hold "BE-AFD"  
           reg  signed [WORDLEN - 1 : 0]  temp_reg1,temp_reg2;            		       // to hold "BE-AFD"
           reg         [1:0]              state;
           reg         [2:0]              element;
           reg         [3:0]              mult_delay_count;
           reg         [3:0]              out_data_counter;
           reg         [2:0]              In_Data_Counter;
           reg  signed [15:0]             Mul1_In1;
           reg  signed [15:0]             Mul1_In2;
           reg  signed [15:0]             Mul2_In1;
           reg  signed [15:0]             Mul2_In2;
           wire signed [31:0]             Mul1_Temp;
           wire signed [31:0]             Mul2_Temp;
           wire signed [15:0]             Mul1_Out;
           wire signed [15:0]             Mul2_Out;
integer i;

localparam in_data              = 2'b00;
localparam calculation          = 2'b01;
localparam wait_start           = 2'b11;
localparam out_data             = 2'b10;

localparam calc_element00_01_02 = 3'b000;
localparam calc_element13_33    = 3'b001;
localparam calc_element21        = 3'b011;
localparam calc_element22        = 3'b010;
localparam calc_element31        = 3'b110;
localparam calc_element32        = 3'b100;

assign Mul1_Temp = Mul1_In1 * Mul1_In2;
assign Mul2_Temp = Mul2_In1 * Mul2_In2;
assign Mul1_Out  = Mul1_Temp[27:12];
assign Mul2_Out  = Mul2_Temp[27:12];

always @(posedge CLK or negedge RST_n) begin
    if (!RST_n) begin
        for(i=0; i < 6 ; i = i + 1) 
            matrix_reg [i] <= 0; 
        for(i=0; i < MATRIX_ELEMENT_NUM ; i = i + 1)
            trans_matrix_reg [i] <= 0; 
        transpose_out       <= 0;
        mult_delay_count    <= 0;
        out_data_counter    <= 0;
        In_Data_Counter     <= 0;
        state               <= 0;
        element             <= 0;
        temp_reg1           <= 0; 
        temp_reg2           <= 0;
    end 
    else begin
        case(state)
            in_data: begin
                transpose_out <= 'b0;
                if (valid_transpose) begin 
                    matrix_reg [In_Data_Counter]     <= rot_out1_opr1 ;
                    matrix_reg [In_Data_Counter + 1] <= rot_out1_opr2 ;
                    In_Data_Counter <= In_Data_Counter + 2'd2;
                    if(In_Data_Counter == 3'd4)begin
                        state <= calculation;
                        In_Data_Counter <= 0;
                    end
                end
            end
            calculation: begin
                case (element)
                    calc_element00_01_02 : begin
                        Mul1_In1 <= matrix_reg[0];
                        Mul1_In2 <= matrix_reg[2];
                        Mul2_In1 <= matrix_reg[1];
                        Mul2_In2 <= matrix_reg[2];
                        mult_delay_count <= mult_delay_count + 1'b1;
                        if(mult_delay_count == 3'd4)begin
                            trans_matrix_reg [0] <=   Mul1_Out;
                            trans_matrix_reg [1] <= - Mul2_Out;
                            trans_matrix_reg [2] <= - matrix_reg [3] ;
                            mult_delay_count <= 'b0;
                            element <= calc_element13_33;
                        end
                    end
                    calc_element13_33: begin
                        Mul1_In1 <= matrix_reg[2];
                        Mul1_In2 <= matrix_reg[5];
                        Mul2_In1 <= matrix_reg[2];
                        Mul2_In2 <= matrix_reg [4];
                        mult_delay_count <= mult_delay_count + 1'b1;
                        if(mult_delay_count == 3'd4)begin
                            trans_matrix_reg [5] <= - Mul1_Out;
                            trans_matrix_reg [8] <=   Mul2_Out;
                            mult_delay_count <= 'b0;
                            element <= calc_element21;
                        end
                    end
                    calc_element21 : begin 
                        if(mult_delay_count < 5)begin
                            Mul1_In1 <= matrix_reg[3];
                            Mul1_In2 <= matrix_reg[5];
                            Mul2_In1 <= matrix_reg[1];
                            Mul2_In2 <= matrix_reg[4];
                            mult_delay_count <= mult_delay_count + 1'b1;
                            if(mult_delay_count == 3'd4)begin
                                temp_reg1 <= Mul1_Out;
                                temp_reg2 <= Mul2_Out;
                            end
                        end
                        else begin
                            Mul1_In1 <= temp_reg1;
                            Mul1_In2 <= matrix_reg[0];
                            mult_delay_count <= mult_delay_count + 1'b1;
                            if(mult_delay_count == 4'd9)begin
                                trans_matrix_reg[3] <= temp_reg2 - Mul1_Out;
                                mult_delay_count <= 'b0;
                                element <= calc_element22;
                            end
                        end
                    end 
                    calc_element22 : begin 
                        if(mult_delay_count < 5)begin
                            Mul1_In1 <= matrix_reg[3];
                            Mul1_In2 <= matrix_reg[5];
                            Mul2_In1 <= matrix_reg[0];
                            Mul2_In2 <= matrix_reg[4];
                            mult_delay_count <= mult_delay_count + 1'b1;
                            if(mult_delay_count == 3'd4)begin
                                temp_reg1 <= Mul1_Out;
                                temp_reg2 <= Mul2_Out;
                            end
                        end
                        else begin
                            Mul1_In1 <= temp_reg1;
                            Mul1_In2 <= matrix_reg[1];
                            mult_delay_count <= mult_delay_count + 1'b1;
                            if(mult_delay_count == 4'd9)begin
                                trans_matrix_reg[4] <= temp_reg2 + Mul1_Out;
                                mult_delay_count <= 'b0;
                                element <= calc_element31;
                            end
                        end
                    end  
                    calc_element31 : begin 
                        if(mult_delay_count < 5)begin
                            Mul1_In1 <= matrix_reg[4];
                            Mul1_In2 <= matrix_reg[3];
                            Mul2_In1 <= matrix_reg[1];
                            Mul2_In2 <= matrix_reg[5];
                            mult_delay_count <= mult_delay_count + 1'b1;
                            if(mult_delay_count == 3'd4)begin
                                temp_reg1 <= Mul1_Out;
                                temp_reg2 <= Mul2_Out;
                            end
                        end
                        else begin
                            Mul1_In1 <= temp_reg1;
                            Mul1_In2 <= matrix_reg[0];
                            mult_delay_count <= mult_delay_count + 1'b1;
                            if(mult_delay_count == 4'd9)begin
                                trans_matrix_reg[6] <= temp_reg2 + Mul1_Out;
                                mult_delay_count <= 'b0;
                                element <= calc_element32;
                            end
                        end
                    end  
                    calc_element32 : begin 
                        if(mult_delay_count < 5)begin
                            Mul1_In1 <= matrix_reg[1];
                            Mul1_In2 <= matrix_reg[3];
                            Mul2_In1 <= matrix_reg[0];
                            Mul2_In2 <= matrix_reg[5];
                            mult_delay_count <= mult_delay_count + 1'b1;
                            if(mult_delay_count == 3'd4)begin
                                temp_reg1 <= Mul1_Out;
                                temp_reg2 <= Mul2_Out;
                            end
                        end
                        else begin
                            Mul1_In1 <= temp_reg1;
                            Mul1_In2 <= matrix_reg[4];
                            mult_delay_count <= mult_delay_count + 1'b1;
                            if(mult_delay_count == 4'd9)begin
                                trans_matrix_reg[7] <= temp_reg2 - Mul1_Out;
                                mult_delay_count <= 'b0;
                                element <= calc_element00_01_02;
                                state <= wait_start;
                            end
                        end
                    end 
                endcase
            end
            wait_start: begin
                if(start_transpose) begin
                    state <= out_data;
                    transpose_out <= trans_matrix_reg[0]; 
                    out_data_counter <= out_data_counter + 1'b1;
                end
            end
            out_data: begin
                case(out_data_counter)
                    4'd1: begin
                        transpose_out <= trans_matrix_reg[1];
                        out_data_counter <= out_data_counter + 1'b1;
                    end
                    4'd2: begin
                        transpose_out <= trans_matrix_reg[2];
                        out_data_counter <= out_data_counter + 1'b1;
                    end
                    4'd3: begin
                        transpose_out <= trans_matrix_reg[3];
                        out_data_counter <= out_data_counter + 1'b1;
                    end
                    4'd4: begin
                        transpose_out <= trans_matrix_reg[4];
                        out_data_counter <= out_data_counter + 1'b1;
                    end
                    4'd5: begin
                        transpose_out <= trans_matrix_reg[5];
                        out_data_counter <= out_data_counter + 1'b1;
                    end
                    4'd6: begin
                        transpose_out <= trans_matrix_reg[6];
                        out_data_counter <= out_data_counter + 1'b1;
                    end
                    4'd7: begin
                        transpose_out <= trans_matrix_reg[7];
                        out_data_counter <= out_data_counter + 1'b1;
                    end
                    4'd8: begin
                        transpose_out <= trans_matrix_reg[8];
                        out_data_counter <= 'b0;
                        state <= in_data;
                    end
                endcase
            end
        endcase
    end
end         

endmodule