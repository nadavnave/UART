`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:25:57 01/12/2021
// Design Name:   UART_RX
// Module Name:   /home/ise/Uart/UART_RX_tb.v
// Project Name:  Uart
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: UART_RX
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module UART_RX_tb;
	// Localparameters
        localparam LP_CLK_CYCLE = 10;
	localparam LP_X16_BAUD_CYCLE = 90;
        localparam LP_X16_DIV = LP_X16_BAUD_CYCLE/LP_CLK_CYCLE;
        localparam LP_BIT_CYCLE = 16*LP_X16_BAUD_CYCLE;	
        localparam LP_SEED = 8982098;
	// Inputs
	reg serial_in;
	reg x16_BAUD;
	reg reset;
        reg CLK;
	// Outputs
	wire [7:0] Do;
	wire valid;
	wire error;

    integer j = 0;
        reg [7: 0] byte;

        task send;
            input [7:0] byte;
            input error;
            integer i ;
            begin
                // Start bit 
                serial_in = 0;
                #LP_BIT_CYCLE;
                // DATA
                for ( i = 0; i < 8 ; i = i + 1) begin
                         serial_in = byte[i];
                         #LP_BIT_CYCLE;
                end
                // Stop bit
                if (error) begin
                    serial_in = 0;
                end
                else begin
                    serial_in = 1;
                end
                #LP_BIT_CYCLE;
            end
        endtask
	// Instantiate the Unit Under Test (UUT)
	UART_RX #(
		.P_REG_MODE_TH(160)
	) uut (
                .CLK(CLK),
		.serial_in(serial_in), 
		.x16_BAUD(x16_BAUD), 
		.reset(reset), 
		.Do(Do), 
		.valid(valid), 
		.error(error)
	);

	initial begin
		// Initialize Inputs
                $display("Starting testbench");
		serial_in = 0;
		x16_BAUD = 1;
		reset = 0;
                CLK = 0;
		// Wait 100 ns for global reset to finish
		#50;
                // get into regular mode   
                serial_in = 1;
                #(LP_X16_BAUD_CYCLE*200);
                // 
                // error on start bit
                //
                serial_in = 0;
                #LP_X16_BAUD_CYCLE;
                serial_in = 1;
                #LP_BIT_CYCLE;
                if( error ) begin
                    $display("Error on start bit - Pass");
                end
                else begin
                    $display("Error on start bit - Failed");
                    $finish();
                end
                //
                // Check Error reset
                //
                # LP_CLK_CYCLE;
                reset = 1;
                # LP_CLK_CYCLE;
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
                serial_in = 1;
                #(LP_X16_BAUD_CYCLE*200);
                
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
                // send random bytes
                //

                # LP_CLK_CYCLE;
                reset = 1;
                # LP_CLK_CYCLE;
                reset = 0;
                # LP_CLK_CYCLE;
                serial_in = 1;
                #(LP_X16_BAUD_CYCLE*200);

                for( j = 0; j < 15 ; j = j + 1) begin
                    byte = j;
                    send( byte, 1'b0);
                end
                $finish();
	end
        
        integer i = 0;
        always @(posedge CLK) begin
            if ( i == LP_X16_DIV -1) begin
                x16_BAUD = 1;
                i =0;
            end
            else begin
                i = i + 1;
                x16_BAUD = 0;
            end
        end
	always begin
            #(LP_CLK_CYCLE/2) CLK  = ~CLK;
	end
        
endmodule

