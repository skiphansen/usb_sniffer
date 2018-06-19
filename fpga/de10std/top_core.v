//-----------------------------------------------------------------
// top_core
//-----------------------------------------------------------------
module top_core
(
    // ULPI PHY clock (60MHz)
    input           clk_i,
    input           rst_i,
  
    // ULPI Interface
    input  [7:0]    ulpi_data_i,
    output [7:0]    ulpi_data_o,
    input           ulpi_dir_i,
    input           ulpi_nxt_i,
    output          ulpi_stp_o
);
//-----------------------------------------------------------------
// ULPI
//-----------------------------------------------------------------

wire [1:0]              xcvrselect_w;
wire                    termselect_w;
wire [1:0]              op_mode_w;
wire                    dppulldown_w;
wire                    dmpulldown_w;

wire [7:0]              utmi_data_w = 8'b0;
wire [7:0]              utmi_data_r;
wire                    utmi_txvalid = 1'b0;
wire                    utmi_txready;
wire                    utmi_rxvalid;
wire                    utmi_rxactive;
wire                    utmi_rxerror;
wire [1:0]              utmi_linestate;

ulpi_wrapper
u_ulpi
(
    .ulpi_clk60_i(clk_i),
    .ulpi_rst_i(rst_i),

    // ULPI Interface
    .ulpi_data_out_i(ulpi_data_i),
    .ulpi_data_in_o(ulpi_data_o),
    .ulpi_dir_i(ulpi_dir_i),
    .ulpi_nxt_i(ulpi_nxt_i),
    .ulpi_stp_o(ulpi_stp_o),

    // UTMI Interface
    .utmi_txvalid_i(utmi_txvalid),
    .utmi_txready_o(utmi_txready),
    .utmi_rxvalid_o(utmi_rxvalid),
    .utmi_rxactive_o(utmi_rxactive),
    .utmi_rxerror_o(utmi_rxerror),
    .utmi_data_in_o(utmi_data_r),
    .utmi_data_out_i(utmi_data_w),
    .utmi_xcvrselect_i(xcvrselect_w),
    .utmi_termselect_i(termselect_w),
    .utmi_op_mode_i(op_mode_w),
    .utmi_dppulldown_i(dppulldown_w),
    .utmi_dmpulldown_i(dmpulldown_w),
    .utmi_linestate_o(utmi_linestate)
);

//-----------------------------------------------------------------
// USB Sniffer
//-----------------------------------------------------------------

usb_sniffer
u_sniffer
(
    .clk_i(clk_i),
    .rst_i(rst_i),
    
    // Peripheral Interface
    /*
    .addr_i(ftdi_address_w[7:0]),
    .data_i(ftdi_data_w),
    .data_o(periph_data_r),
    .we_i(ftdi_we_w),
    .stb_i(periph_stb_w),
    .ack_o(periph_ack_w),
    */

    // UTMI Interface
    .utmi_rxvalid_i(utmi_rxvalid),
    .utmi_rxactive_i(utmi_rxactive),
    .utmi_rxerror_i(utmi_rxerror),
    .utmi_data_i(utmi_data_r),
    .utmi_linestate_i(utmi_linestate),

    .utmi_op_mode_o(op_mode_w),
    .utmi_xcvrselect_o(xcvrselect_w),
    .utmi_termselect_o(termselect_w),
    .utmi_dppulldown_o(dppulldown_w),
    .utmi_dmpulldown_o(dmpulldown_w)

    // Wishbone (Slave)
    /*
    .mem_addr_o(sniffer_addr_w),
    .mem_sel_o(sniffer_sel_w),
    .mem_data_o(sniffer_data_w),
    .mem_stb_o(sniffer_stb_w),
    .mem_we_o(sniffer_we_w),
    .mem_stall_i(sniffer_stall_w),
    .mem_ack_i(sniffer_ack_w)
    */
);

endmodule
