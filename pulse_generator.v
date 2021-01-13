`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nadav Nave
// 
// Create Date:    16:38:32 01/13/2021 
// Design Name 
// Module Name:    pulse_generator 

//
//////////////////////////////////////////////////////////////////////////////////
module pulse_generator #(
    parameter P_CLK_FREQ,
    parameter P_BAUDRATE
)(
    input CLK,
    output reg out
);
    localparam LP_X16_DIV = P_CLK_FREQ/ P_BAUDRATE;
    reg [ clog2(LP_X16_DIV) -1 : 0] counter;

    always @(posedge CLK) begin
        if( counter == LP_X16_DIV - 1) begin
            counter <= 0;
            out <= 1;
        end
        else begin
            counter <= counter + 1;
            out <= 0;
        end
    end
endmodule
