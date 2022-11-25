`timescale 1ns / 1ps

module UART_TX_FSM(
    input i_clk,
    input i_reset,
    input i_start,
    input [7:0] i_data_in,
    output o_data_out
    );

    parameter   S_IDLE  = 4'd0,
                S_START = 4'd1,
                S_D0    = 4'd2,
                S_D1    = 4'd3,
                S_D2    = 4'd4,
                S_D3    = 4'd5,
                S_D4    = 4'd6,
                S_D5    = 4'd7,
                S_D6    = 4'd8,
                S_D7    = 4'd9,
                S_STOP  = 4'd10;

    parameter   BAUD_9600 = 10416;

    reg r_data_out;
    assign o_data_out = r_data_out;

    reg [13:0] r_counter = 0;
    reg [3:0] curState = S_IDLE;
    reg [3:0] nextState;

    always @(posedge i_clk or posedge i_reset) begin
        if(i_reset) begin
            r_counter <= 0;
            curState <= S_IDLE;
        end
        else begin
            if(r_counter == BAUD_9600 - 1) begin
                r_counter <= 0;
                curState <= nextState;
            end
            else begin
                r_counter <= r_counter + 1;
            end
        end
    end

    // STATE REGISTER
    always @(curState or i_start) begin
        case (curState)
            S_IDLE  : begin
                if(i_start)     nextState <= S_START;
                else            nextState <= S_IDLE;
            end
            S_START : nextState <= S_D0;
            S_D0    : nextState <= S_D1;
            S_D1    : nextState <= S_D2;
            S_D2    : nextState <= S_D3;
            S_D3    : nextState <= S_D4;
            S_D4    : nextState <= S_D5;
            S_D5    : nextState <= S_D6;
            S_D6    : nextState <= S_D7;
            S_D7    : nextState <= S_STOP;
            S_STOP  : begin
                if(!i_start)    nextState <= S_IDLE;
                else            nextState <= S_STOP;
            end
            default : nextState <= S_IDLE;
        endcase
    end

    // OUTPUT LOGIC
    always @(*) begin
        case (curState)
            S_IDLE  : r_data_out <= 1;
            S_START : r_data_out <= 0;
            S_D0    : r_data_out <= i_data_in[0];
            S_D1    : r_data_out <= i_data_in[1];
            S_D2    : r_data_out <= i_data_in[2];
            S_D3    : r_data_out <= i_data_in[3];
            S_D4    : r_data_out <= i_data_in[4];
            S_D5    : r_data_out <= i_data_in[5];
            S_D6    : r_data_out <= i_data_in[6];
            S_D7    : r_data_out <= i_data_in[7];
            S_STOP  : r_data_out <= 1;
            default : r_data_out <= 1;
        endcase
    end
endmodule
