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
	localparam LP_X16_BAUD_CYCLE = 20;
        localparam LP_BIT_CYCLE = 16*LP_X16_BAUD_CYCLE;	
	// Inputs
	reg serial_in;
	reg x16_BAUD;
	reg reset;
        reg CLK;
	// Outputs
	wire [7:0] Do;
	wire valid;
	wire error;

        task send;
            input [7:0] byte;
            integer i = 0;
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
                serial_in = 1;
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
		serial_in = 0;
		x16_BAUD = 1;
		reset = 0;
                CLK = 0;
		// Wait 100 ns for global reset to finish
		#50;
                 
		// Add stimulus here
                serial_in = 1;
                #(LP_X16_BAUD_CYCLE*200);
                send(8'b10100110);
                $finish();
	end
        localparam LP_x16_DIV = 2;
        integer i = 0;
        always @(posedge CLK) begin
            if ( i == LP_x16_DIV -1) begin
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

