`timescale 1ns / 1ps

module tb_UART_TX();
    reg i_clk;
    reg i_reset;
    reg i_start;
    reg [7:0] i_data_in;
    wire o_data_out;

    UART_TX DUT(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_start(i_start),
    .i_data_in(i_data_in),
    .o_data_out(o_data_out)
    );

    always #5 i_clk = ~i_clk;

    initial begin
        i_clk = 1'b0;
        i_reset = 1'b0;
        
        /* Transmit 'K' to Bluetooth Module */
        i_data_in = 8'h4B;      // 0x4B --> 'K'
        i_start = 1'b1;

        /* Transmit 'J' to Bluetooth Module */
        #1050000
        i_data_in = 8'h4A;      // 0x4A --> 'J'
        i_start = 1'b0;
        #1000000 
        i_start = 1'b1;

        /* Transmit 'H' to Bluetooth Module */
        #1050000
        i_data_in = 8'h48;      // 0x48 --> 'H'
        i_start = 1'b0;
        #1000000 
        i_start = 1'b1;
    end
endmodule
