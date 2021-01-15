`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:    Nadav Nave
//
// Create Date:   14:45:20 01/14/2021
// Design Name:   UART_RX_top
// Module Name:   /home/ise/Uart/UART_RX_top_tb.v
// Project Name:  Uart
// 
////////////////////////////////////////////////////////////////////////////////

module UART_RX_top_tb;

    localparam LP_CLK_CYCLE = 10;
    localparam LP_BIT_CYCLE  = 1000;
    integer j;
    reg [7:0] byte;
    
	// Inputs
	reg CLK;
	reg data_in;
	reg reset;
	reg display_next;

	// Outputs
	wire [3:0] data_out_msd;
	wire [3:0] data_out_lsd;
	wire error;
	wire fifo_empty;
	wire fifo_full;

        task send;
            input [7:0] byte;
            input error;
            integer i ;
            begin
                // Start bit 
                data_in = 0;
                #LP_BIT_CYCLE;
                // DATA
                for ( i = 0; i < 8 ; i = i + 1) begin
                         data_in = byte[i];
                         #LP_BIT_CYCLE;
                end
                // Stop bit
                if (error) begin
                    data_in = 0;
                end
                else begin
                    data_in = 1;
                end
                #LP_BIT_CYCLE;
            end
        endtask
        
	// Instantiate the Unit Under Test (UUT)
	UART_RX_top uut (
		.CLK(CLK), 
		.data_in(data_in), 
		.reset(reset), 
		.display_next(display_next), 
		.data_out_msd(data_out_msd), 
		.data_out_lsd(data_out_lsd), 
		.error(error), 
		.fifo_empty(fifo_empty), 
		.fifo_full(fifo_full)
	);

	initial begin
                $display("Starting testbench");
		// Initialize Inputs
		CLK = 0;
		data_in = 0;
		reset = 0;
		display_next = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
                // get into regular mode   
                data_in = 1;
                #(LP_BIT_CYCLE*15);
                // 
                // error on start bit
                //
                data_in = 0;
                #(LP_BIT_CYCLE/16);
                data_in = 1;
                #LP_BIT_CYCLE;
                if( error ) begin
                    $display("Error on start bit - Pass");
                end
                else begin
                    $display("Error on start bit - Failed");
                //    $finish();
                end
                //
                // Check Error reset
                //
                # LP_CLK_CYCLE;
                reset = 1;
                # (LP_CLK_CYCLE*20);
                reset = 0;
                # LP_CLK_CYCLE;
                if ( error ) begin
                    $display("Reset from Error state - Failed");
                    $finish();
                end
                else begin
                    $display("Reset from Error state - Pass");
                end
                //
                // Get into Regular mode
                //
                data_in = 1;
                #(LP_BIT_CYCLE*15);
                
                //
                // Error on stop bit
                //
                send(8'b01010101, 1);
                if( error ) begin
                    $display("Error on stop bit - Pass");
                end
                else begin
                    $display("Error on stop bit - Failed");
                    $finish();
                end
                //
                // send all possible bytes
                //
                # LP_CLK_CYCLE;
                reset = 1;
                # (LP_CLK_CYCLE*20);
                reset = 0;
                # LP_CLK_CYCLE;
                data_in = 1;
                #(LP_BIT_CYCLE*15);
                for( j = 0; j < 16 ; j = j + 1) begin
                    byte = j;
                    send( byte, 1'b0);
                end
                $finish();
	end

        integer i; 
        initial begin
            for( i = 0; i< 16 ; i = i + 1) begin
                @(negedge fifo_empty);
                display_next = 1;
                # (LP_CLK_CYCLE * 13);
                display_next = 0;
                if ( { data_out_msd, data_out_lsd} == i) begin
                    $display("byte %d is valid", i);
                end
                else begin
                    $display("Error on bit %d", i);
                end
            end
        end

        always begin
            #(LP_CLK_CYCLE/2) CLK = ~CLK;
        end

endmodule

