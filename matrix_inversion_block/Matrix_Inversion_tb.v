`timescale 1ns/1ps

module Matrix_Inversion_tb ();
    
    ////////////////////////////////////////////////////////////////
    ////////////////////////// Parameters //////////////////////////
    ////////////////////////////////////////////////////////////////
    
    parameter   CLK_PERIOD = 20/3;
    parameter   N_STAGES = 12;
    parameter   FRACTION_WIDTH = 12;
    parameter   SCALING_FACTOR = 16'h09b8;
    parameter   WORDLEN = 16;
    parameter   MATRIX_ROWS = 3;
    parameter   MATRIX_COLUMNS = 3;
    parameter   MATRIX_ELEMENT_NUM = MATRIX_ROWS * MATRIX_COLUMNS;
    parameter   MATRIX_WIDTH = MATRIX_ELEMENT_NUM * WORDLEN;
    
    ////////////////////////////////////////////////////////////////
    ////////////////////// Wires and Register //////////////////////
    ////////////////////////////////////////////////////////////////
    
    reg                                 CLK_tb;
    reg                                 RST_n_tb;
    reg                                 start_tb;
    wire                                done_tb;
    wire    signed  [WORDLEN-1:0]  data_out_tb;
    
    ////////////////////////////////////////////////////////////////
    //////////////////////////// Clock /////////////////////////////
    ////////////////////////////////////////////////////////////////
    
    always #(CLK_PERIOD/2)  CLK_tb = ~CLK_tb;
    
    ////////////////////////////////////////////////////////////////
    //////////////////////// Instantiations ////////////////////////
    ////////////////////////////////////////////////////////////////
    
    Matrix_Inversion DUT (
        .CLK(CLK_tb),
        .RST_n(RST_n_tb),
        .start(start_tb),
        .done(done_tb),
        .data_out(data_out_tb)
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
        
        start_opr('h6000_3000_2000_1000_3000_1000_0000_2000_4000);
        
        //////////////// Test case 1 ////////////////
        /************** Only Vector Cordic **************/

        #100;
        @(posedge done_tb);
        
        check_out('h1000_FFFF_0000_0000_0AAA_FAAA_0000_FAAA_0AAA, 'b1);
        
        #100;
        
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
    
    // Task to Start the operation
    task start_opr;
        input   [MATRIX_WIDTH-1:0]   in;
        
        begin
            
            DUT.U0_regfile.mem[0][0] = in[WORDLEN-1:0];
            DUT.U0_regfile.mem[0][1] = in[2*WORDLEN-1:WORDLEN];
            DUT.U0_regfile.mem[0][2] = in[3*WORDLEN-1:2*WORDLEN];
            DUT.U0_regfile.mem[1][0] = in[4*WORDLEN-1:3*WORDLEN];
            DUT.U0_regfile.mem[1][1] = in[5*WORDLEN-1:4*WORDLEN];
            DUT.U0_regfile.mem[1][2] = in[6*WORDLEN-1:5*WORDLEN];
            DUT.U0_regfile.mem[2][0] = in[7*WORDLEN-1:6*WORDLEN];
            DUT.U0_regfile.mem[2][1] = in[8*WORDLEN-1:7*WORDLEN];
            DUT.U0_regfile.mem[2][2] = in[9*WORDLEN-1:8*WORDLEN];
            
            #(CLK_PERIOD);
            
            start_tb = 1'b1;
            
            #(CLK_PERIOD);
            
            start_tb = 1'b0;
        end
    endtask
    
    // Task to Check the output
    task check_out;
        input   [MATRIX_WIDTH-1:0]   out;
        input   [4:0]                i;
        
        begin
            
            if(out == data_out_tb) begin
                
                $display("Successful test case %d", i);
            end
            else begin
                
                $display("Error in testcase %d", i);
                $stop;
            end
        end
    endtask
endmodule