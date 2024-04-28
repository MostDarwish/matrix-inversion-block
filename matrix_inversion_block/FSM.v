module FSM (
        input   wire                CLK,
        input   wire                RST_n,
        
        ////////////////////////////// Handshake with User ////////////////////////////
        input   wire                start,
        output  reg                 done,
        
        ///////////////////////// Handshake with vector cordic ////////////////////////
        input   wire                done_vec,
        output  reg                 valid_vec,
        
        /////////////////////////// Handshake with regfile ////////////////////////////
        output  reg                 valid_regfile,
        output  reg     [1:0]       opr_regfile,
        
        ////////////////// Handshake with the three rotational cordics ////////////////
        input   wire                done_rot1,
        input   wire                done_rot2,
        input   wire                done_rot3,
        output  reg                 valid_rot1,
        output  reg                 valid_rot2,
        output  reg                 valid_rot3,
        
        ////////////// Handshake with the multiplier and transpose block //////////////
        output  reg                 valid_transpose,
        output  reg                 start_transpose,
        
        /////////////////////// Handshake with the inverse block //////////////////////
        input   wire                done_inverse,
        output  reg                 valid_inverse,
        output  reg                 start_inverse,
        
        ///////////////////// Handshake with the multiplier block /////////////////////
        input   wire                done_mul,
        output  reg                 valid_mul
    );
    
    /*
        States of FSM:
            1) IDLE: Wait for Start Signal
            2) VEC_START: Start Vector Cordic
            3) VEC_ROT_BUSY: Vector Cordic and three Rotational Cordic are all working
            4) ROT_LAST_UPDATE: Wait for the last two Rotational Cordic to finish (after this state we have Q and R)
            5) VEC_INVERSE: Wait for inverse block to finish (after this state we have Q transpose and R invers)
            6) MUL_READY: Send data to mul block
            7) MUL_BUSY: Wait for mul block to finishes (Data is availabe at output)
    */
    localparam  [2:0]   IDLE             = 3'b000,
                        VEC_START        = 3'b001,
                        VEC_ROT_BUSY     = 3'b011,
                        ROT_LAST_UPDATE  = 3'b010,
                        VEC_INVERSE      = 3'b110,
                        MUL_READY        = 3'b111,
                        MUL_BUSY         = 3'b101;
    
    // current state and next state pointers
    reg     [2:0]   curr_state, next_state;
    
    // Internal counter
    reg     [3:0]   count;
    
    // internal signals
    reg             clear_counter, increment_counter;
    
    
    
    // Internal wires
    reg             valid_vec_reg;
    reg             valid_rot1_reg;
    reg             valid_rot2_reg;
    reg             valid_rot3_reg;
    reg             valid_transpose_reg;
    reg             valid_mul_reg;
    reg             valid_inverse_reg;
    
    always @(posedge CLK or negedge RST_n) begin
        
        if(!RST_n) begin
            
            // Return to IDLE state
            curr_state <= IDLE;
        end
        else begin
            
            // Go to next state
            curr_state <= next_state;
        end
    end
    
    always @(*) begin
        
        //////////////////// default values ////////////////////
        
        // Internal wires
        valid_vec_reg = 1'b0;
        valid_rot1_reg = 1'b0;
        valid_rot2_reg = 1'b0;
        valid_rot3_reg = 1'b0;
        valid_transpose_reg = 1'b0;
        valid_mul_reg = 1'b0;
        valid_inverse_reg = 1'b0;
        
        // user
        done = 1'b0;
        
        // Regfile
        opr_regfile = 'b0;
        valid_regfile = 1'b0;
        
        // mult_transpose
        start_transpose = 1'b0;
        
        // inverse
        start_inverse = 1'b0;
        
        // counter
        clear_counter = 1'b0;
        increment_counter = 1'b0;
        
        //////////////////// case statement ////////////////////
        case (curr_state)
            IDLE: begin
                
                /************************* next state logic *************************/
                if(start) begin
                    
                    // go to START state and start the vector cordic
                    next_state = VEC_START;
                end
                else begin
                    
                    // Stay in the IDLE state
                    next_state = IDLE;
                end
                
                /*************************** output logic ***************************/
                // make Regfile output data to vector cordic be ready
                opr_regfile = 'b01;
                
                if(start) begin
                    
                    // start vector cordic
                    valid_vec_reg = 1'b1;
                    
                    // make Regfile output data to vector cordic be ready with next data
                    // and also data for rotational cordic ready
                    valid_regfile = 1'b1;
                end
                else begin
                    
                    // don't start vector cordic
                    valid_vec_reg = 1'b0;
                    
                    // make Regfile output data to vector cordic be ready
                    valid_regfile = 1'b0;
                end
            end
            VEC_START: begin
                
                /************************* next state logic *************************/
                if(done_vec) begin
                    
                    // make all cordics activated
                    next_state = VEC_ROT_BUSY;
                end
                else begin
                    
                    // Stay in the same state
                    next_state = VEC_START;
                end
                
                /*************************** output logic ***************************/
                // make Regfile output data to vector and rotational cordic ready
                opr_regfile = 'b01;
                
                if(done_vec) begin
                    
                    // Activate all cordics
                    valid_vec_reg = 1'b1;
                    valid_rot1_reg = 1'b1;
                    valid_rot2_reg = 1'b1;
                    valid_rot3_reg = 1'b1;
                    
                    // make Regfile output data to vector and rotational cordic ready with next data
                    valid_regfile = 1'b1;
                    
                    // Clear counter
                    clear_counter = 1'b1;
                end
                else begin
                    
                    // Deactivate all cordics
                    valid_vec_reg = 1'b0;
                    valid_rot1_reg = 1'b0;
                    valid_rot2_reg = 1'b0;
                    valid_rot3_reg = 1'b0;
                    
                    // make Regfile output data to vector and rotational cordic ready
                    valid_regfile = 1'b0;
                    
                    // Don't clear counter
                    clear_counter = 1'b0;
                end
            end
            VEC_ROT_BUSY: begin
                
                /************************* next state logic *************************/
                if(count == 'b11) begin
                    
                    // Wait for last vector cordic then go to next state
                    next_state = ROT_LAST_UPDATE;
                end
                else begin
                    
                    // Stay in the same state
                    next_state = VEC_ROT_BUSY;
                end
                
                /*************************** output logic ***************************/
                // make Regfile output data to vector and rotational cordic ready
                opr_regfile = 'b01;
                
                if(done_vec || (done_rot1 && done_rot2) || done_rot3) begin
                    
                    if(count == 'b0) begin
                        
                        // Activate rotational cordic 3 
                        valid_rot3_reg = 1'b1;
                    end
                    else begin
                        
                        // Deactivate rotational cordic 3
                        valid_rot3_reg = 1'b0;
                    end
                    
                    if((count == 'b1)) begin
                        
                        // Activate vector cordic
                        valid_vec_reg = 1'b1;
                    end
                    else begin
                        
                        // Deactivate vector cordic
                        valid_vec_reg = 1'b0;
                    end
                    
                    if((count != 'b1)) begin
                        
                        // Activate rotational cordics 1 and 2
                        valid_rot1_reg = 1'b1;
                        valid_rot2_reg = 1'b1;
                    end
                    else begin
                        
                        // Deactivate rotational cordics 1 and 2
                        valid_rot1_reg = 1'b0;
                        valid_rot2_reg = 1'b0;
                    end
                    
                    if(((count == 'b0) || (count == 'b1)) && (done_rot1 && done_rot2)) begin
                        
                        // Activate mul_transpose
                        valid_transpose_reg = 1'b1;
                    end
                    else begin
                        
                        // Deactivate mul_transpose
                        valid_transpose_reg = 1'b0;
                    end
                    
                    // make Regfile output data to vector and rotational cordic ready with next data
                    valid_regfile = 1'b1;
                    
                    // Increment counter
                    increment_counter = 1'b1;
                end
                else begin
                    
                    // Deactivate all cordics
                    valid_vec_reg = 1'b0;
                    valid_rot1_reg = 1'b0;
                    valid_rot2_reg = 1'b0;
                    valid_rot3_reg = 1'b0;
                    
                    // Deactivate mul_transpose
                    valid_transpose_reg = 1'b0;
                    
                    // make Regfile output data to vector and rotational cordic ready
                    valid_regfile = 1'b0;
                    
                    // Don't increment the counter
                    increment_counter = 1'b0;
                end
            end
            ROT_LAST_UPDATE: begin
                
                /************************* next state logic *************************/
                if(done_rot1 && done_rot2) begin
                    
                    // Wait for last vector cordic then go to next state
                    next_state = VEC_INVERSE;
                end
                else begin
                    
                    // Stay in the same state
                    next_state = ROT_LAST_UPDATE;
                end
                
                /*************************** output logic ***************************/
                // make Regfile output data of rotational cordic
                opr_regfile = 'b01;
                
                if(done_rot1 && done_rot2) begin
                    
                    // Activate mul_transpose
                    valid_transpose_reg = 1'b1;
                    
                    // make Regfile output data to vector and rotational cordic ready with next data
                    valid_regfile = 1'b1;
                    
                    // Activate inverse block
                    valid_inverse_reg = 1'b1;
                    
                    // clear counter
                    clear_counter = 1'b1;
                end
                else begin
                    
                    // Deactivate mul_transpose
                    valid_transpose_reg = 1'b0;
                    
                    // make Regfile output data to vector and rotational cordic ready
                    valid_regfile = 1'b0;
                    
                    // Deactivate inverse block
                    valid_inverse_reg = 1'b0;
                    
                    // clear counter
                    clear_counter = 1'b0;
                end
            end
            VEC_INVERSE: begin
                
                /************************* next state logic *************************/
                if(count == 'b11) begin
                    
                    // go to next state (since R inverse is now available) to send data to multiplier block
                    next_state = MUL_READY;
                end
                else begin
                    
                    // Stay in the same state
                    next_state = VEC_INVERSE;
                end
                
                /*************************** output logic ***************************/
                // make Regfile output data to inverse vector cordic
                opr_regfile = 'b10;
                
                if(done_inverse) begin
                    
                    if(count != 'b10) begin
                        
                        // Activate inverse block
                        valid_inverse_reg = 1'b1;
                        
                        // make Regfile output next data ready for inverse block
                        valid_regfile = 1'b1;
                    end
                    else begin
                        
                        // Deactivate inverse block
                        valid_inverse_reg = 1'b0;
                        
                        // don't make Regfile output next data ready for inverse block
                        valid_regfile = 1'b0;
                    end
                    
                    // Increment counter
                    increment_counter = 1'b1;
                end
                else begin
                    
                    // Deactivate inverse block
                    valid_inverse_reg = 1'b0;
                    
                    // don't make Regfile output next data ready for inverse block
                    valid_regfile = 1'b0;
                    
                    // don't increment counter
                    increment_counter = 1'b0;
                end
                
                if(count == 'b11) begin
                        
                    // Clear counter
                    clear_counter = 1'b1;
                end
                else begin
                    
                    // Don't clear the counter
                    clear_counter = 1'b0;
                end
            end
            MUL_READY: begin
                
                /************************* next state logic *************************/
                if(count == 'b1000) begin
                    
                    // go to next state to produce the output
                    next_state = MUL_BUSY;
                end
                else begin
                    
                    // Stay in the same state
                    next_state = MUL_READY;
                end
                
                /*************************** output logic ***************************/
                // Increment counter
                increment_counter = 1'b1;
                
                // make mul_transpose sends data
                start_transpose = 1'b1;
                
                // make inverse send data
                start_inverse = 1'b1;
                
                // make multiplier block receives data
                valid_mul_reg = 1'b1;
                
                // If counter reached 8 clear it
                if(count == 'b1000) begin
                    
                    // Clear counter
                    clear_counter = 'b1;
                end
                else begin
                    
                    // don't clear it
                    clear_counter = 'b0;
                end
            end
            MUL_BUSY: begin
                
                /************************* next state logic *************************/
                if(count == 'b1000) begin
                    
                    // Finished and go to IDLE state
                    next_state = IDLE;
                end
                else begin
                    
                    // Stay in the same state wait for multiplier to finishes
                    next_state = MUL_BUSY;
                end
                
                /*************************** output logic ***************************/
                if(done_mul) begin
                    
                    // Set done signal
                    done = 1'b1;
                    
                    // Increment counter
                    increment_counter = 'b1;
                end
                else begin
                    
                    // Clear done signal
                    done = 1'b0;
                    
                    // Don't Increment the counter
                    increment_counter = 'b0;
                end
            end
            default: begin
                
                /************************* next state logic *************************/
                // Return to IDLE case
                next_state = IDLE;
            end
        endcase
    end
    
    always @(posedge CLK or negedge RST_n) begin
        
        if (!RST_n) begin
            
            // Clear output signals
            valid_vec <= 'b0;
            valid_rot1 <= 'b0;
            valid_rot1 <= 'b0;
            valid_rot1 <= 'b0;
            valid_transpose <= 'b0;
            valid_mul <= 'b0;
            valid_inverse <= 'b0;
        end else begin
            
            // Set signals
            valid_vec <= valid_vec_reg;
            valid_rot1 <= valid_rot1_reg;
            valid_rot2 <= valid_rot2_reg;
            valid_rot3 <= valid_rot3_reg;
            valid_transpose <= valid_transpose_reg;
            valid_mul <= valid_mul_reg;
            valid_inverse <= valid_inverse_reg;
        end
    end
    always @(posedge CLK or negedge RST_n) begin
        
        if(!RST_n) begin
            
            // Clear counter
            count <= 'b0;
        end
        else if (clear_counter) begin
            
            // Clear counter
            count <= 'b0;
        end
        else if (increment_counter) begin
            
            // increment counter
            count <= count + 'b1;
        end
    end
    
    
endmodule //FSM