module top(
    input SYSCLK,
    output LED_RED,
    output LED_BLUE,
    output LED_GREEN,
    output GMII_RST_N,
    output FTDI_RXF,
    output FTDI_TXE,
    output FTDI_SIWUA,
    output FTDI_WR,
    output FTDI_RD,

    output FTDI_D0,
    output FTDI_D1,
    output FTDI_D2,
    output FTDI_D3,
    output FTDI_D4,
    output FTDI_D5,
    output FTDI_D6,
    output FTDI_D7
    );

    reg [2:0] led_reg;
    reg [32:0] counter;

    assign LED_RED = led_reg[0];
    assign LED_BLUE = led_reg[1];
    assign LED_GREEN = led_reg[2];
    assign GMII_RST_N = 1'b1;

    assign FTDI_D0 = counter[0];
    assign FTDI_D1 = counter[1];
    assign FTDI_D2 = counter[2];
    assign FTDI_D3 = counter[3];
    assign FTDI_D4 = counter[4];
    assign FTDI_D5 = counter[5];
    assign FTDI_D6 = counter[6];
    assign FTDI_D7 = counter[7];
    assign FTDI_RXF = counter[8];
    assign FTDI_TXE = counter[9];
    assign FTDI_RD = counter[10];
    assign FTDI_WR = counter[11];
    assign FTDI_SIWUA = counter[12];

    always @(posedge SYSCLK) begin
        if (counter < 25000000)
            counter <= counter + 1;
        else begin
            counter <= 0;
            led_reg <= led_reg + 1;
        end
    end
endmodule
