usb_sniffer port to Terasic DE-10 Standard board
================================================

This is porting layer of the original http://github.com/ultraembedded/usb_sniffer to Intel FPGA based development kit board DE-10 Standard by Terasic.
Originally usb_sniffer project was developed for the miniSpartan6+ board that contains Xilinx Spartan 6 LX9 FPGA.

This version for DE-10 Standard is far from optimal, in particular it does not use such powerfull components of DE-10 Standard as HPS, SDRAM connected to FPGA, etc.
But the idea of this project is not to develop a production ready USB analyzer. Instead the purpose of this project is:
- provide interesting example for learning FPGA design using Intel FPGA technology,
- do not diverge much from the original usb_sniffer for Xilinx board.

For this project you need USB3300 physics board from Waveshare http://www.waveshare.com/wiki/USB3300_USB_HS_Board. 
It should be connected to the GPIO header of the DE10 board using custom IDC socket soldered on USB3300 board.

In original usb_sniffer project custom ribbon cable was used to connect USB3300 board with FPGA board.
Also it was reported by the developer of the original usb_sniffer project that if ribbon cable is too long than we start getting CRC errors.

It was found that if use jump wires for connection of USB3300 board and FPGA devkit than setup becomes unstable: sometimes it works but sometimes it fails to catch most of the usb transactions.
In our case use of even a short custom ribbon cable was not successfull: 30-80% USB transaction contained CRC errors.

Function block diagram of the original usb_sniffer for Xilinx board
-------------------------------------------------------------------
![Function block diagram of the original usb_sniffer for Xilinx board](https://docs.google.com/drawings/d/e/2PACX-1vTA9QbfQDT7xo1mgNiZTo-LN8nDyIPyQkrnb1Ali1ypNcB0GZ5nslQD02Mu71eKqgAq2gKzIgX3kHln/pub?w=960&h=720)

Of course above diagram is only schematic and actuall connections in the FPGA design are a little bit more involved.

miniSpartan6+ board contains FT2232H USB to UART/FIFO microchip.
Its first channel is reserved for JTAG and second channel can be used in the so-called 245 FIFO mode.
From FPGA side usb_sniffer module communicate via FT2232H using FTDI async bridge OpenCore.
To the PC side a USB connection is provided by FT2232H and libftdi library is used in software to elaborate a high level interface.

Lots of components in this design communicate using Wishbone bus which is standard bus in OpenCores IP cores.
This bus is very similiar to Altera Avalon MM bus making it easy to combine them togather.

usb_sniffer control and status registers and RAM are available on Wishbone bus on different addresses and can be accessed using FTDI bridge.

Such components as `ftdi_async_bridge`, `ulpi_wrapper`, `usb_sniffer` are tracked in the separate repository http://github.com/ultraembedded/cores because they might be reused in the other projects in different combinations. They are also uploaded by their author to the OpenCores site.

Design contains two glue layers:

- `top` module is a top-level design entity and is board related; it manipulates with input/output ports assigned to a FPGA pins and instanciates `top_core` module;
- `top_core` module instantiates most of the modules used in the design and wires them togather.

Function block diagram of usb_sniffer ported to Altera board
------------------------------------------------------------
![Function block diagram of the original usb_sniffer for Altera board](https://docs.google.com/drawings/d/e/2PACX-1vQw8YgYYuHD74eRaG5VcVZRgxSAFIj5FpQxP5dLPr4X7N4V41tm6qu7weWR-61KlRzd7NN26L1YRC7-/pub?w=901&h=345)

Comparing to the Xilinx version we do not use FTDI microchip capabilities for communication of software and hardware parts because it is not available on our board.
Instead of that we use JTAG to Avalon master bridge IP core.
Altera's system_console tool provides tcl commands which using JTAG to Avalong master bridge can read and write to Avalong MM bus.
This way we can read and modify control and status registers of usb_sniffer and read on-chip RAM with sniffing data.

To make this work togather with existing usb_sniffer software written in C we had to write proxy in tcl that passes request from usb_sniffer to the JTAG to Avalong master bridge.

We use External Bus to Avalon Bridge (ram_bridge) and Avalon to External Bus Bridge (periph_bridge) IP cores which simplify creation of Avalon bus masters and slaves in Verilog.
In fact this bridges are connected to the corresponding Wishbone buses.

Connecting USB3300 and FPGA board
---------------------------------
To connect USB3300 and FPGA board we use specialized bridge board whose schematic
is in hw/de10std/usb_sniffer_bridge folder.

![Imgur](https://i.imgur.com/6bgy6VJ.png?1)

This custom board is required because using custom ribbon cable to connect USB3300
board and FPGA board results in unstable connection.
More precisely, if we use ribbon cable then we get USB CRC errors in sniffed data.

When connecting FPGA board with USB sniffer bridge board and with USB3300 board
make sure that first pin marks match:

1. First pin on the FPGA board JP1 connector matches first pin on the bridge board
   JP1 connector.
2. First pin on the bridge board JP2 connector matches first pin on the USB3300
   board CN1 connector.

After that USB3300 board and DE-10 should be connected accroding to table

| USB3300 Board | CN1 pin | JP1 pin | DE-10 2x20 GPIO | FPGA pin |
| ------------- | ------- | ------- | --------------- | -------- |
| RST           |  8      | 19      | GPIO[16]        | PIN_AG8  |
| CLK           | 10      | 21      | GPIO[18]        | PIN_AF5  |
| DIR           | 12      | 23      | GPIO[20]        | PIN_AF8  |
| NXT           | 14      | 25      | GPIO[22]        | PIN_AF10 |
| STP           | 16      | 27      | GPIO[24]        | PIN_AE9  |
| DATA0         |  1      | 14      | GPIO[11]        | PIN_AG2  |
| DATA1         |  3      | 16      | GPIO[13]        | PIN_AG5  |
| DATA2         |  5      | 18      | GPIO[15]        | PIN_AG7  |
| DATA3         |  7      | 20      | GPIO[17]        | PIN_AF4  |
| DATA4         |  9      | 22      | GPIO[19]        | PIN_AF6  |
| DATA5         | 11      | 24      | GPIO[21]        | PIN_AF9  |
| DATA6         | 13      | 26      | GPIO[23]        | PIN_AE7  |
| DATA7         | 15      | 28      | GPIO[25]        | PIN_AE11 |
| 3.3V          | 19      | 29      | VCC3P3          |          |
| GND           | 17      | 30      | GND             |          |

Building and running existing design
------------------------------------
We describe how to build hardware and software part of usb_sniffer project from sources.

1. Open usb_sniffer/fpga/de10std/fpga.qpf project in Quartus.
   Generate HDL for the Qsys part and build Quartus project after that.
2. Build software part using make tool.

For running usb_sniffer you need:

1. Program usb sniffer FPGA design.
2. Enter `usb_sniffer/fpga/de10std/` directory. Run system console proxy from it

       nios2_command_shell.sh system-console --script=system_console.tcl

and wait until System Console welcome message printed.
2. Run software application using command

       ./usb_sniffer -i socket -s -f capture.txt

or use any other valid command line options. Only `-i socket` option is required to use socket based communication channel with hardware part.

iti1480a-display application can be used producing formatted output.

![Imgur](https://imgur.com/GocTLVS.png)

Note that if you connect full speed or low speed device than make sure to add correct speed configuration to usb_sniffer using `-u` flag.

Step by step porting of usb_sniffer
-----------------------------------
Below are described in details a steps how to reproduce porting of the usb_sniffer project to DE-10 board starting from the original version for Xilinx board.
Each step contains a corresponding reference to commit in git repository.

1. Clone the original http://github.com/ultraembedded/usb_sniffer project

       git clone --recursive https://github.com/ultraembedded/usb_sniffer.git

Pay attention that `--recursive` flag is used. It is needed for cloning a cores submodule used in the project.

2. At the time of writting this tutorial `cores` submodule link in the usb_sniffer repository was out of date.
To update it do `git checkout master` in the `cores` submodule and commit updated submodule link in the `usb_sniffer` repository.

Commit: `cores: updated submodules version`.

3. Create `minispartan6plus` subdirectory in the `fpga` directory of the usb_sniffer project and move all existing files from the `fpga` directory to the `fpga\minispartan6plus`.
This is of course done to be able to support multiple platforms in usb_sniffer project.

Commit: `fpga: created platform specific folder for miniSpartan6+`.

4. Run DE10_Standard_SystemBuilder.exe and configure system according to the screenshot

![DE10-Standard SystemBuilder configuration](https://i.imgur.com/3SenD9r.png)

and save generated project in `usb_sniffer/fpga/de10std` folder.

Commits:

- `de10std: generated project using Terasic System Builder`
- `de10std: compiled project and created gitignore file accordingly`
- `de10std: fixed 'Core speed grade' in Device dialog`
- `de10std: fixed sdc case issue`
- `de10std: renamed top level design entity`

5. Based on minispartan6plus version code first version of `top` and `top_core` modules and instantiate `ulpi_wrapper` and `usb_sniffer` modules there.

Commit: `de10std: created minimal version of glue layers that can do PHY reset`.

Configure SignalTap with a Power-On trigger and add ULPI wires there to observe that USB3300 PHY is reseted at start correctly

![USB3300 PHY reset](https://i.imgur.com/bLKrvD9.png)

6. Create soc_system Qsys file in Platform Designer and configure components, connections, exports and base addresses according to figure

![Qsys](https://i.imgur.com/cqrRAo8.png)

When adding corresponding components to Qsys configure the following parameters of that components:

- periph_bridge_0
  - Address Range: 256 bytes
  - Data Width: 32 bit
- onchip_memory2_0
  - Dual-port access
  - Single clock operation
  - Total memory size: 65536
- ram_bridge_0
  - Address range: 1024 Mbytes
  - Data width: 32 bit

Commit: `de10std: added platform design`

7. Last step is implementation of software part.

Commits:

- `de10std: added proxy for system_console`
- `sw: created additional abstraction layer for hw interface`
- `sw: wrapped hardware interface in ops structure`
- `sw: added socket based hardware interface`

Known issues and improvements
-----------------------------
In future this design can be improved in many ways:

- software part dependency on Quartus System Console
- performance improvements:

  - in usb_sniffer.v for storing data FIFO IP core interface can be utilized instead of custom FIFO implementation in usb_sniffer.v
  - more than 64Kb of onchip ram can be allocated
  - FPGA SDRAM can be used
  - HPS can be used

- more filtering conditions can be implemented
