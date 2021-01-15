`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:08:12 01/14/2021 
// Design Name: 
// Module Name:    UART_RX_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module UART_RX_top (
    input CLK,
    input data_in,
    input reset,
    input display_next,
    output [3 : 0] data_out_msd,
    output [3 : 0] data_out_lsd,
    output error,
    output fifo_empty,
    output fifo_full
);

    localparam LP_DEBOUNCER_MIN_TH = 1;
    localparam LP_DEBOUNCER_MAX_TH = 10;
    localparam LP_CLK_FREQ = 100000000; 
    localparam LP_BAUDRATE = 1000000;
    
    wire debounced_reset;
    wire debounced_display_next;
    wire x16_baud;
    wire[7:0]  uart_out;
    wire uart_valid;
    wire [7: 0] fifo_out;
    
    assign data_out_msd = fifo_out[7:4];
    assign data_out_lsd = fifo_out[3:0];
    // ---------------------------------------------------------------------------
    //  instances
    // ---------------------------------------------------------------------------
    Debouncer #(
        .P_MIN_TH(LP_DEBOUNCER_MIN_TH),
        .P_MAX_TH(LP_DEBOUNCER_MAX_TH)
    ) Reset_Debouncer(
        .in(reset),
        .CLK(CLK),
        .out(debounced_reset)
    );

    Debouncer #(
        .P_MIN_TH(LP_DEBOUNCER_MIN_TH),
        .P_MAX_TH(LP_DEBOUNCER_MAX_TH)
    ) Display_Next_Debouncer (
        .in(display_next),
        .CLK(CLK),
        .out(debounced_display_next)
    );
   
    pulse_generator #(
        .P_CLK_FREQ(LP_CLK_FREQ),
        .P_BAUDRATE(LP_BAUDRATE)
    )pulse_generator(
        .CLK(CLK),
        .out(x16_baud)
    );

    UART_RX #(
            .P_REG_MODE_TH(160)
    ) UART_RX (
            .CLK(CLK),
            .serial_in(data_in), 
            .x16_BAUD(x16_baud), 
            .reset(debounced_reset), 
            .Do(uart_out), 
            .valid(uart_valid), 
            .error(error)
    );
    
    fifo_16 FIFO (
      .clk(CLK), 
      .srst(debounced_reset),
      .din(uart_out), 
      .wr_en(uart_valid),
      .rd_en(debounced_display_next), 
      .dout(fifo_out), 
      .full(fifo_full), 
      .empty(fifo_empty) 
    );
endmodule
