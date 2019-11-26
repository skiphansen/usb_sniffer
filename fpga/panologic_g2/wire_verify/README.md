This is a bit stream that generates signals on the FTDI module inteface lines
to allow the wiring to be tested before connecting the module.  All signals
should be reasonable looking square waves with the prossible exception of
pin 26 which looks more like a sinwave on my 400 Mhz scope.  

Any opens or shorts should be readily apparent.


| FTDI   | MiniSpartan6+ | Pano      | board to board | CN3  | ribbon | FPGA |  
|--------|---------------|-----------|----------------|------|--------|------|
|        |               |           | connector pin  | pin  | Color  | pin  |
|        |               |           |                |      |        |      |
| BD0    | FTDI_D0       | DVI_D[1]  |  62.5 Mhz      | 26   | green  | A14  |
| BD1    | FTDI_D1       | DVI_D[0]  |  31.25 Mhz     | 25   | blue   | D17  |
| BD2    | FTDI_D2       | DVI_D[3]  |  15.625 Mhz    | 24   | orange | A14  |
| BD3    | FTDI_D3       | DVI_D[2]  |  7.8125 Mhz    | 23   | yellow | A16  |
| BD4    | FTDI_D4       | DVI_D[4]  |  3.90625 Mhz   | 21   | red    | A17  | *
| BD5    | FTDI_D5       | DVI_D[6]  |  1.953125 Mhz  | 20   | white  | D14  |
| BD6    | FTDI_D6       | DVI_D[5]  |  976.5 Khz     | 19   | black  | A18  |
| BD7    | FTDI_D7       | DVI_D[8]  |  488.28 Khz    | 18   | violet | B16  |
|--------|---------------|-----------|----------------|------|--------|------|
| BC0    | FTDI_RXF      | DVI_D[7]  |  244.14 Khz    | 17   | gray   | B14  |
| BC1    | FTDI_TXE      | DVI_D[10] |  122.07 Khz    | 16   | green  | E16  |
| BC2    | FTDI_RD       | DVI_D[9]  |  61.03 Khz     | 15   | blue   | B18  |
| BC3    | FTDI_WR       | DVI_H     |  30.51 Khz     | 14   | orange | F12  |
| BC4    | FTDI_SIWUA    | DVI_D[11] |  15.26 Khz     | 13   | yellow | D15  |
|--------|---------------|-----------|----------------|------|--------|------|
| VCC    |               | +5V       | outside 14     | 3    | yellow |      |
| VIO    |               | +3.3V     | outside 2      | 22   | brown  |      |
| GND    |               | GND       | inside 22      | 2    | brown  |      |
| GND    |               | GND       | outside 22     | 4    | orange |      |
|--------|---------------|-----------|----------------|------|--------|------|
