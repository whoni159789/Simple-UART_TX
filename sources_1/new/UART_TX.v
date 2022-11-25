`timescale 1ns / 1ps

module UART_TX(
    input i_clk,
    input i_reset,
    input i_start,
    input [7:0] i_data_in,
    output o_data_out
    );
    
    UART_TX_FSM U0(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_start(i_start),
    .i_data_in(i_data_in),
    .o_data_out(o_data_out)
    );


endmodule
