//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nadav Nave
// 
// Create Date:    08:38:14 01/12/2021 
// Module Name:    Debouncer 
//
// Description: 	This module filters input from a physical button. On each button
//  			press the module output one pulse.
// Inputs:
//              CLK         This is the clock for the module. Operation in
//                          this module happens on the rising edge of CLK
//              in          usually this signal comes from physical
//                          switch/Button
// Output:      out         This bit will be high only one cycle when the
//                          input signal is high for P_MAX_TH
//
//////////////////////////////////////////////////////////////////////////////////
module Debouncer#(
    parameter P_MAX_TH = 10,
    parameter P_MIN_TH = 1
)(
    input CLK,
    input in,
    output reg out
);
	 localparam LP_COUNTER_LEN = clog2(P_MAX_TH);
    reg [LP_COUNTER_LEN  - 1 : 0] counter;
    reg state;
    // initialize the registers
  
	initial begin
        counter = 0;
        state = 0;
    end 

    
   // State machine: next state. 
    always @(posedge CLK) begin
        // counter next state
        if(counter == 0) begin
            if (in) begin
                counter <= counter + in*2-1;
            end 
        end
        else if (counter == {LP_COUNTER_LEN{1'b1}}) begin
            if (~in) begin
                counter <= counter + in*2 -1;
            end
        end
        else begin 
            counter <= counter + in*2 - 1;
        end

        //  next state
        if (~state && (counter == P_MAX_TH)) begin
            state <= 1;
        end
        else if (state && (counter == P_MIN_TH)) begin
            state <= 0;
        end
    end
    
    // State machine: output
    always @(posedge CLK) begin
        if (~state && (counter == P_MAX_TH)) begin
            out <= 1;
        end
        else begin
            out <= 0;
        end
    end

endmodule
