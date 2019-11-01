//-----------------------------------------------------------------
// TOP
//-----------------------------------------------------------------
module top
(
    // 50MHz clock
    input           clk,

    // USB ULPI Interface
    input           usb_clk60,
    output          usb_ulpi_stp,
    input           usb_ulpi_dir,
    input           usb_ulpi_nxt,
    inout [7:0]     usb_ulpi_data

);

//-----------------------------------------------------------------
// Clocking
//-----------------------------------------------------------------
wire USB_CLK60G;

clkgen_pll
u_pll
(
    .CLKREF_IN(usb_clk60),
    .CLKOUT0G(USB_CLK60G)
);

//-----------------------------------------------------------------
// Reset
//-----------------------------------------------------------------
reg reset       = 1'b1;
reg rst_next    = 1'b1;

always @(posedge USB_CLK60G) 
if (rst_next == 1'b0)
    reset       <= 1'b0;
else 
    rst_next    <= 1'b0;

//-----------------------------------------------------------------
// IO Primitives
//-----------------------------------------------------------------
wire [7:0] ulpi_out_w;
wire [7:0] ulpi_in_w;
wire       ulpi_stp_w;

genvar i;
generate  
for (i=0; i < 8; i=i+1)  
begin: gen_buf
    IOBUF 
    #(
        .DRIVE(12),
        .IOSTANDARD("DEFAULT"),
        .SLEW("FAST")
    )
    IOBUF_inst
    (
        .T(usb_ulpi_dir),
        .I(ulpi_out_w[i]),
        .O(ulpi_in_w[i]),
        .IO(usb_ulpi_data[i])
    );
end  
endgenerate  

OBUF 
#(
    .DRIVE(12),
    .IOSTANDARD("DEFAULT"),
    .SLEW("FAST")
)
OBUF_stp
(
    .I(ulpi_stp_w),
    .O(usb_ulpi_stp)
);

//-----------------------------------------------------------------
// Core
//-----------------------------------------------------------------
top_core
u_core
(
    // ULPI PHY clock (60MHz)
    .clk_i(USB_CLK60G),
    .rst_i(reset),

    // ULPI Interface
    .ulpi_data_i(ulpi_in_w),
    .ulpi_data_o(ulpi_out_w),
    .ulpi_dir_i(usb_ulpi_dir),
    .ulpi_nxt_i(usb_ulpi_nxt),
    .ulpi_stp_o(ulpi_stp_w)

);

//-----------------------------------------------------------------
// Tie-offs
//-----------------------------------------------------------------
// SPI Flash
assign flash_cs   = 1'b0;
assign flash_cclk = 1'b0;
assign flash_mosi = 1'b0;

// ADC
assign ad_cs = 1'b0;
assign ad_sclk = 1'b0;
assign ad_din = 1'b0;

// SD card
assign sd_clk = 1'b0;
assign sd_cmd = 1'b0;
assign sd_cd_dat3 = 1'b0;

// Audio
assign audio1 = 1'b0;
assign audio2 = 1'b0;

endmodule
