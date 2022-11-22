//
// Include file for Asteroids
//
// *MUST* be included inside a module definition

`ifndef VGA_VH
`define VGA_VH

interface vga #(
    parameter WIDTH = 640,
    parameter HEIGHT = 480
);/* (
    input logic clk
);*/
    logic hsync;
    logic vsync;
    logic [$clog2(WIDTH )-1:0]pxl_x;
    logic [$clog2(HEIGHT)-1:0]pxl_y;
    logic [3:0]red;
    logic [3:0]green;
    logic [3:0]blue;

    modport in  (input  hsync, vsync, pxl_x, pxl_y, red, green, blue);
    modport out (output hsync, vsync, pxl_x, pxl_y, red, green, blue);

endinterface: vga

`endif // VGA_VH