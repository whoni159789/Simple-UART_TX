`timescale 1ns / 1ps

module UART_TX_FSM(
    input i_clk,
    input i_reset,
    input i_start,
    input [7:0] i_data_in,
    output o_data_out
    );

    /* Definition of FSM States */
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

    /* Baud Rate constant 
       System Clock : 100MHz
       => Period : 1/100MHz = 10ns
       Baud Rate : 9600bps
       => Period : 1/9600 = 106.16us
       for 9600bps, BAUD_9600 : 100_000_000 / 9600 = 10416
    */
    parameter   BAUD_9600 = 10416;

    reg r_data_out;
    assign o_data_out = r_data_out;

    /* Initialization of variables & states*/
    reg [13:0] r_counter = 0;       // 14bit counter for counting 10416
    reg [3:0] curState = S_IDLE;    // current state for Mealy Machine
    reg [3:0] nextState;            // next state for Mealy Machine

    /* Change of states*/
    always @(posedge i_clk or posedge i_reset) begin
        /* Reset -> Stop UART_TX => Initialize counter & state*/
        if(i_reset) begin
            r_counter <= 0;
            curState <= S_IDLE;
        end
        else begin
            /* 9600bps -> state changes always 106.16us*/
            if(r_counter == BAUD_9600 - 1) begin        // meaning of '-1' : counter starts from '0'
                r_counter <= 0;
                curState <= nextState;
            end
            else begin
                r_counter <= r_counter + 1;
            end
        end
    end

    /* Process of Evenets 
       if you want to know more details,
       visit my naver blog
       and refer to FSM of UART_TX.drawio
    */
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

    /* Output Logic */
    /* UART Transmit Protocol 
       Default : 1
       Start bit : 0
       Data 8bit : 0/1 ([7:0] i_data_in)
       Stop bit : 1
       => Total 10bit : Start bit(1bit) + Data bit(8bit) + Stop bit(1bit)
    */
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
