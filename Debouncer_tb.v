`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:04:34 01/12/2021
// Design Name:   Debouncer
// Module Name:   /home/ise/Uart/Debouncer_tb.v
// Project Name:  Uart
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Debouncer
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Debouncer_tb;

        localparam LP_MAX_TH = 20;
        localparam LP_MIN_TH = 5;

	// Inputs
	reg CLK;
	reg in;

	// Outputs
	wire out;

	// Instantiate the Unit Under Test (UUT)
	Debouncer #(
            .P_MAX_TH(LP_MAX_TH),
            .P_MIN_TH(LP_MIN_TH)
        ) uut (
            .CLK(CLK), 
            .in(in), 
            .out(out)
	);

	initial begin
            // Initialize Inputs
            CLK = 0;
            in = 0;

            // Wait 100 ns for global reset to finish
            #100;
    
            // Add stimulus here
            in = 1;
            #250;
            in = 0;
	end

        always begin
            #5 CLK = ~CLK;
        end
endmodule

