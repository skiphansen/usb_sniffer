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
// SoC System
//-----------------------------------------------------------------
wire        periph_ei_bus_enable;
wire [7:0]  periph_ei_address;
wire [31:0] periph_ei_read_data;
wire [31:0] periph_ei_write_data;
wire        periph_ei_rw;
wire        periph_ei_acknowledge;

wire [29:0] ram_ei_address;
wire [3:0]  ram_ei_byte_enable;
wire        ram_ei_write;
wire [31:0] ram_ei_write_data;
wire        ram_ei_acknowledge;

soc_system
u0
(
    .clk_clk                                        (clk_i),                 //                              clk.clk
    .reset_reset_n                                  (~rst_i),                //                            reset.reset_n
    .periph_bridge_0_external_interface_bus_enable  (periph_ei_bus_enable),  // periph_bridge_0_external_interface.bus_enable
    .periph_bridge_0_external_interface_address     (periph_ei_address),     //                                   .address
    .periph_bridge_0_external_interface_read_data   (periph_ei_read_data),   //                                   .read_data
    .periph_bridge_0_external_interface_write_data  (periph_ei_write_data),  //                                   .write_data
    .periph_bridge_0_external_interface_rw          (periph_ei_rw),          //                                   .rw
    .periph_bridge_0_external_interface_acknowledge (periph_ei_acknowledge), //                                   .acknowledge
    .ram_bridge_0_external_interface_address        (ram_ei_address),        //    ram_bridge_0_external_interface.address
    .ram_bridge_0_external_interface_byte_enable    (ram_ei_byte_enable),    //                                   .byte_enable
    .ram_bridge_0_external_interface_write          (ram_ei_write),          //                                   .write
    .ram_bridge_0_external_interface_write_data     (ram_ei_write_data),     //                                   .write_data
    .ram_bridge_0_external_interface_acknowledge    (ram_ei_acknowledge)     //                                   .acknowledge
);

//-----------------------------------------------------------------
// USB Sniffer
//-----------------------------------------------------------------
wire [31:0] sniffer_addr_w = {2'b0, ram_ei_address};
wire sniffer_stb_w;
wire sniffer_we_w;

usb_sniffer
u_sniffer
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Peripheral Interface
    .addr_i(periph_ei_address),
    .data_i(periph_ei_write_data),
    .data_o(periph_ei_read_data),
    .we_i(!periph_ei_rw),
    .stb_i(periph_ei_bus_enable),
    .ack_o(periph_ei_acknowledge),

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
    .mem_sel_o(ram_ei_byte_enable),
    .mem_data_o(ram_ei_write_data),
    .mem_stb_o(sniffer_stb_w),
    .mem_we_o(sniffer_we_w),
    .mem_stall_i(1'b0),
    .mem_ack_i(ram_ei_acknowledge)
);

assign ram_ei_write = sniffer_stb_w && sniffer_we_w;

endmodule
