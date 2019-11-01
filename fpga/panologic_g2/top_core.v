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
// Params
//-----------------------------------------------------------------
parameter       CLK_KHZ             = 60000;
parameter       UART_BAUD           = 115200;
parameter       SPI_CLK_KHZ         = CLK_KHZ / 5;
parameter       BOOT_VECTOR         = 32'h00000000;
parameter       ISR_VECTOR          = 32'h00000010;

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
wire                    utmi_txvalid = 1'b1;
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
// Wishbone (Master - Write Only)
wire [31:0] sniffer_addr_w;
wire [3:0]  sniffer_sel_w;
wire [31:0] sniffer_data_w;
wire        sniffer_we_w;
wire        sniffer_stb_w;
wire        sniffer_stall_w;
wire        sniffer_ack_w;

usb_sniffer
u_sniffer
(
    .clk_i(clk_i),
    .rst_i(rst_i),
    
    // Peripheral Interface
    .addr_i(8'b0),
    .data_i(32'b0),
    .data_o(),
    .we_i(1'b0),
    .stb_i(1'b0),
    .ack_o(),

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
    .utmi_dmpulldown_o(dmpulldown_w),

    // Wishbone (Slave)
    .mem_addr_o(sniffer_addr_w),
    .mem_sel_o(sniffer_sel_w),
    .mem_data_o(sniffer_data_w),
    .mem_stb_o(sniffer_stb_w),
    .mem_we_o(sniffer_we_w),
    .mem_stall_i(sniffer_stall_w),
    .mem_ack_i(sniffer_ack_w)
);

//-----------------------------------------------------------------
// Sample RAM
//-----------------------------------------------------------------
ram_wb
#(.BLOCK_COUNT(8))
u_ram
(
    // Port A
    .clka_i(clk_i),
    .rsta_i(rst_i),
    .stba_i(sniffer_stb_w),
    .wea_i(sniffer_we_w),
    .sela_i(sniffer_sel_w),
    .addra_i(sniffer_addr_w),
    .dataa_i(sniffer_data_w),
    .dataa_o(),
    .acka_o(sniffer_ack_w),

    // Port B - External Port
    .clkb_i(1'b0),
    .rstb_i(1'b0),
    .stbb_i(1'b0),
    .web_i(1'b0),
    .selb_i(4'b0),
    .addrb_i(32'b0),
    .datab_i(32'b0),
    .datab_o(),
    .ackb_o()    
);

assign sniffer_stall_w = 1'b0;

endmodule
