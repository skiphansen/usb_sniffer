//-----------------------------------------------------------------
// TOP
//-----------------------------------------------------------------
module top
(
    // 125 MHz clock
    input           SYSCLK,

    // FTDI
    inout           ftdi_rxf,
    inout           ftdi_txe,
    inout           ftdi_siwua,
    inout           ftdi_wr,
    inout           ftdi_rd,
    inout [7:0]     ftdi_d, // TXD, RXD
    // USB ULPI Interface
    output          usb_clk,
    input           usb_clk60,
    output          ulpi_reset,
    output          usb_ulpi_stp,
    input           usb_ulpi_dir,
    input           usb_ulpi_nxt,
    inout [7:0]     usb_ulpi_data,

 // Ethernet PHY
    output GMII_RST_N,

    output led_blue,
    input pano_button
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

IBUFG clkin1_buf
 (.O (clkin1),
  .I (SYSCLK));

PLL_BASE
#(.BANDWIDTH              ("OPTIMIZED"),
  .CLK_FEEDBACK           ("CLKFBOUT"),
  .COMPENSATION           ("SYSTEM_SYNCHRONOUS"),
  .DIVCLK_DIVIDE          (5),
  .CLKFBOUT_MULT          (24),
  .CLKFBOUT_PHASE         (0.000),
  .CLKOUT0_DIVIDE         (25),
  .CLKOUT0_PHASE          (0.000),
  .CLKOUT0_DUTY_CYCLE     (0.500),
  .CLKIN_PERIOD           (8.000),
  .REF_JITTER             (0.010))
pll_base_inst
  // Output clocks
 (.CLKFBOUT              (clkfbout),
  .CLKOUT0               (clkout0),
  .CLKOUT1               (clkout1_unused),
  .CLKOUT2               (clkout2_unused),
  .CLKOUT3               (clkout3_unused),
  .CLKOUT4               (clkout4_unused),
  .CLKOUT5               (clkout5_unused),
  // Status and control signals
  .LOCKED                (LOCKED),
  .RST                   (RESET),
   // Input clock control
  .CLKFBIN               (clkfbout_buf),
  .CLKIN                 (clkin1));


// Output buffering
//-----------------------------------
BUFG clkf_buf
 (.O (clkfbout_buf),
  .I (clkfbout));

BUFG clk24_buf
  (.O (mhz24_buf),
   .I (clkout0));


ODDR2 clkout1_buf (
    .D0(1'b1),
    .D1(1'b0),
    .C0(mhz24_buf),
    .C1(!mhz24_buf),
    .CE(1'b1),
    .Q(usb_clk)
);

//-----------------------------------------------------------------
// Reset
//-----------------------------------------------------------------
reg reset       = 1'b1;
reg rst_next    = 1'b1;

(* mark_debug = "TRUE" *) wire debug_reset;
assign debug_reset = reset;

always @(posedge USB_CLK60G) 
if (pano_button == 1'b0) begin
    reset       <= 1'b1;
    rst_next    <= 1'b1;
end else if (rst_next == 1'b0)
    reset       <= 1'b0;
else 
    rst_next    <= 1'b0;

assign ulpi_reset = reset;
// assign ulpi_reset = 1'b1;


//-----------------------------------------------------------------
// IO Primitives
//-----------------------------------------------------------------
(* KEEP = "TRUE" *) (* S = "TRUE" *) wire [7:0] ulpi_out_w;
(* mark_debug = "TRUE" *) (* KEEP = "TRUE" *) (* S = "TRUE" *) wire [7:0] ulpi_in_w;
wire       ulpi_stp_w;

(* mark_debug = "TRUE" *) wire [7:0] debug_in_w;
assign debug_in_w = ulpi_in_w;

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
    .ulpi_stp_o(ulpi_stp_w),

    // FTDI (async FIFO interface)
    .ftdi_rxf(ftdi_rxf),
    .ftdi_txe(ftdi_txe),
    .ftdi_siwua(ftdi_siwua),
    .ftdi_wr(ftdi_wr),
    .ftdi_rd(ftdi_rd),
    .ftdi_d(ftdi_d)

);

//-----------------------------------------------------------------
// Tie-offs
//-----------------------------------------------------------------

// Must remove reset from the Ethernet Phy for 125 Mhz input clock.
// See https://github.com/tomverbeure/panologic-g2
assign GMII_RST_N = 1'b1;

ODDR2 test_buf (
    .D0(1'b1),
    .D1(1'b0),
    .C0(USB_CLK60G),
    .C1(!USB_CLK60G),
    .CE(1'b1),
    .Q(led_blue)
);

endmodule
