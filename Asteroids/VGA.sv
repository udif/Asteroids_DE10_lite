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
    typedef struct packed {
        logic hsync;
        logic vsync;
        logic [$clog2(WIDTH )-1:0]pxl_x;
        logic [$clog2(HEIGHT)-1:0]pxl_y;
        logic [3:0]red;
        logic [3:0]green;
        logic [3:0]blue;
        logic en;
    } vga_t;

    // we are wrapping all the interface signals in a typedef so we can access all the signals at once
    // since there are issues with assigning an interface to another
    vga_t t;

    modport in  (input  t);
    modport out (output t);

endinterface: vga

`endif // VGA_VH