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
    parameter P_REG_MODE_TH
)(
    input serial_in,
    input x16_BAUD,
    input reset,
    output reg [7:0] Do,
    output reg valid,
    output reg error
);
    localparam LP_COUNTER_WIDTH = clog(P_REG_MODE_TH);
    localparam LP_STATE_WIDTH   = 4; 
    // FSM states
    localparam S_WAIT       = 0;
    localparam S_REG_MODE   = 1;
    localparam S_START_BIT  = 2;
    localparam S_DO         = 3;
    localparam S_D1         = 4;
    localparam S_D2         = 5;
    localparam S_D3         = 6;
    localparam S_D4         = 7;
    localparam S_D5         = 8;
    localparam S_D6         = 9;
    localparam S_D7         = 10;
    localparam S_STOP_BIT   = 11;
    localparam S_COMPLETE   = 12;
    localparam S_ERROR      = 13;
    
    reg [LP_COUNTER_WIDTH -1 : 0] counter;
    reg [LP_STATE_WIDTH - 1: 0] global_state;

    // FSM next step
    always @(posedge x16_BAUD) begin
        case(global_state) begin
            S_WAIT:
            begin
                
            end
            S_REG_MOD:
            begin
            end
            S_START_BI:
            begin
            end
            S_DO:
            begin
            end
            S_D1:
            begin
            end
            S_D2:
            begin
            end
            S_D3:
            begin
            end
            S_D4:
            begin
            end
            S_D5:
            begin
            end
            S_D6:
            begin
            end
            S_D7:
            begin
            end
            S_STOP_BI:
            begin
            end
            S_COMPLET:
            begin
            end
            S_ERROR:
            begin
            end
        endcase
    end

endmodule
