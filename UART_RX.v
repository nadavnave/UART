`include "clog2.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:00:53 01/12/2021 
// Design Name: 
// Module Name:    UART_RX 
//	
// Description:     This module is a UART receiver. Using UART with IDLE high,
//                  low start bit 8 data bits starting form the LSB, and two
//                  high stop.
// Inputs:      
//      serial in   This is the UART serial input.
//      x16_BAUD    This is the clock for the modle, and is 16 times faster
//                  Then the UART BAUDRATE.
//      reset       This is the reset input which resets the module after
//                  error
// Outputs:
//      Do          This is the ouput byte. When the valid bit is high this
//                  byte contains the received byte form the UART serial port.
//      valid       This bit signlas that Do is a valid byte received from the
//                  uart port.
//      error       This bit signals that the module is in error state. This
//                  can be caused by wrong stop bit. Use reset input to get out of this
//                  state
//////////////////////////////////////////////////////////////////////////////////
module UART_RX #(
    parameter P_REG_MODE_TH = 160
)(
    input serial_in,
    input x16_BAUD,
    input reset,
    input CLK,
    output reg [7:0] Do,
    output reg valid,
    output reg error
);
    localparam LP_COUNTER_WIDTH = clog2(P_REG_MODE_TH);
    localparam LP_STATE_WIDTH   = 4; 
    localparam LP_NUM_DATA_BITS = 8;
    localparam LP_BIT_TIME      = 16;
    localparam LP_HALF_BIT_TIME = 8;
    // FSM states
    localparam S_WAIT       = 0;
    localparam S_REG_MODE   = 1;
    localparam S_START_BIT  = 2;
    localparam S_REC_DATA   = 3;
    localparam S_STOP_BIT   = 4;
    localparam S_COMPLETE   = 5;
    localparam S_ERROR      = 6;
    
    reg [LP_COUNTER_WIDTH - 1 : 0] counter;
    reg [LP_STATE_WIDTH - 1: 0] global_state;
    reg [clog2(LP_NUM_DATA_BITS) - 1: 0] rec_bit;


    // FSM next step
    always @(negedge CLK) begin
        if(reset) begin
            rec_bit <= 0;
            global_state <= S_WAIT;
            counter <= 0;
        end
        else if (x16_BAUD) begin
            case(global_state) 
                S_WAIT:
                begin
                    if(serial_in) begin
                        if(counter == P_REG_MODE_TH) begin
                            global_state <= S_REG_MODE;
                            counter <= 0;
                        end
                        else begin 
                            global_state <= S_WAIT;
                            counter <= counter + 1;
                        end
                    end
                    else begin
                        global_state <= S_WAIT;
                        counter <= 0;
                    end
                end
                S_REG_MODE:
                begin
                    if (~serial_in) begin
                        global_state <= S_START_BIT;
                        counter <= 0;
                    end
                end
                S_START_BIT:
                begin
                    if ( counter == LP_HALF_BIT_TIME - 1) begin
                        if( serial_in) begin
                            global_state <= S_ERROR;
                            counter <= 0;
                        end
                        else begin
                            global_state <= S_REC_DATA;
                            counter <= 0;
                            rec_bit <= 0;
                        end
                    end
                    else begin
                        global_state <= S_START_BIT;
                        counter <= counter + 1;
                    end
                end
                S_REC_DATA:
                begin
                    if( counter == LP_BIT_TIME -1) begin
                        if( rec_bit == 7) begin
                            global_state <= S_STOP_BIT;
                            rec_bit <= 0;
                            counter <= 0;
                        end
                        else begin
                            rec_bit<= rec_bit + 1 ;
                            counter <= 0;
                        end 
                    end
                    else begin
                        global_state <= S_REC_DATA;
                        counter <= counter + 1;
                    end
                end
                S_STOP_BIT:
                begin
                    if( counter == LP_BIT_TIME -1) begin
                        if( serial_in ) begin
                            global_state <= S_COMPLETE;
                            counter <= 0;
                        end
                        else begin
                            global_state <= S_ERROR;
                            counter <= 0;
                        end
                    end
                    else begin
                        global_state <= S_STOP_BIT;
                        counter <= counter + 1;
                    end
                end
                S_COMPLETE:
                begin
                    if(serial_in) begin
                        global_state <= S_REG_MODE;
                        counter <= 0;
                    end
                    else begin
                        global_state <= S_START_BIT;
                        counter <= 0;
                    end
                end
                S_ERROR:
                begin
                    global_state <= S_ERROR;
                    counter <= 0;
                end
                default
                begin
                    rec_bit <= 0;
                    global_state <= S_WAIT;
                    counter <= 0;
                end
            endcase
        end
    end
    // FSM output
    always @(negedge CLK) begin
        case(global_state) 
            S_WAIT:
            begin
                valid <= 0;
                error <= 0;
            end
            S_REG_MODE:
            begin
                valid <= 0;
                error <= 0;
            end
            S_START_BIT:
            begin
                valid <= 0;
                error <= 0;
            end
            S_REC_DATA:
            begin
                valid <= 0;
                error <= 0;
                if ((counter == LP_BIT_TIME - 1) && x16_BAUD) begin
                    Do[rec_bit] <= serial_in;
                end
            end
            S_STOP_BIT:
            begin
                valid <= 0;
                error <= 0;
            end
            S_COMPLETE:
            begin
                
                valid <= 1 & x16_BAUD;
                error <= 0;
            end
            S_ERROR:
            begin
                valid <= 0;
                error <= 1;
            end
            default
            begin
                valid <= 0;
                error <= 0;
            end
        endcase
    end

endmodule
