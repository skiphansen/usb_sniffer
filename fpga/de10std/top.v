module top
(
    input           usb_clk60,
    output          usb_ulpi_stp,
    input           usb_ulpi_dir,
    input           usb_ulpi_nxt,
    inout [7:0]     usb_ulpi_data,
    output          usb_reset
);
//-----------------------------------------------------------------
// Reset
//-----------------------------------------------------------------
reg reset       = 1'b1;
reg rst_next    = 1'b1;

always @(posedge usb_clk60)
if (rst_next == 1'b0)
    reset       <= 1'b0;
else 
    rst_next    <= 1'b0;

assign usb_reset = reset;

//-----------------------------------------------------------------
// IO Primitives
//-----------------------------------------------------------------
wire [7:0] ulpi_out_w;
wire [7:0] ulpi_in_w;

// High level of dir means that PHY transmitting, otherwise it is waiting for data from us.
assign ulpi_in_w = usb_ulpi_data;
assign usb_ulpi_data = usb_ulpi_dir ? 8'bZ : ulpi_out_w;

//-----------------------------------------------------------------
// Core
//-----------------------------------------------------------------
top_core
u_core
(
    // ULPI PHY clock (60MHz)
    .clk_i(usb_clk60),
    .rst_i(reset),

    // ULPI Interface
    .ulpi_data_i(ulpi_in_w),
    .ulpi_data_o(ulpi_out_w),
    .ulpi_dir_i(usb_ulpi_dir),
    .ulpi_nxt_i(usb_ulpi_nxt),
    .ulpi_stp_o(usb_ulpi_stp)
);

endmodule
