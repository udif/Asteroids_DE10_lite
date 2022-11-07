// Top level modules
`include "Ghost_unit.sv"
// "Ghost_unit.sv" submodules
    `include "sin_cos.sv"
        `include "sincos_alt_model.v"
    `include "Move_Ghost.sv"
    `include "Draw_Ghost.sv"
        `include "rot_sin_cos.v"
        `include "ghost_alt_model.v"
`include "Drawing_priority.sv"
`include "vga_controller.v"

module Screens_dispaly # (
	parameter WIDTH=640,
	parameter HEIGHT=480,
	parameter RGB_LAT = 0
) (
	
	input					clk_25,
	input		[3:0]		Red_level,
	input		[3:0]		Green_level,
	input		[3:0]		Blue_level,
	output	[$clog2(WIDTH )-1:0]pxl_x,
	output	[$clog2(HEIGHT)-1:0]pxl_y,
	output	[3:0]		Red,
	output	[3:0]		Green,
	output	[3:0]		Blue,
	output				h_sync,
	output				v_sync
);
	
	wire	[3:0]		Red_i;
	wire	[3:0]		Green_i;
	wire	[3:0]		Blue_i;
	wire				disp_ena;
	
	wire h_sync_d;
	wire v_sync_d;

// VGA controller
 vga_controller VGA_interface (
	.pixel_clk  (clk_25),
   .reset_n    (1),
   .h_sync     (h_sync_d),
   .v_sync     (v_sync_d),
   .disp_ena   (disp_ena),
   .column     (pxl_x),
   .row        (pxl_y)
   );
	

// screen out display picker / enable
assign Red_i = (disp_ena == 1'b1) ? Red_level : 4'b0000 ;
assign Green_i = (disp_ena == 1'b1) ? Green_level : 4'b0000 ;
assign Blue_i = (disp_ena == 1'b1) ? Blue_level : 4'b0000 ;

// outputs assigns
assign Red = Red_i;
assign Green = Green_i;
assign Blue = Blue_i;

// delay h/v sync as requested
generate
if (RGB_LAT == 0)
begin
	assign h_sync = h_sync_d;
	assign v_sync = v_sync_d;
end
else
begin
	reg [RGB_LAT-1:0]h_dly;
	reg [RGB_LAT-1:0]v_dly;
	wire [RGB_LAT:0]tmp_h = {h_sync_d, h_dly};
	wire [RGB_LAT:0]tmp_v = {v_sync_d, v_dly};
	always @(posedge clk_25)
	begin
		h_dly <= tmp_h[RGB_LAT:1];
		v_dly <= tmp_v[RGB_LAT:1];
	end
	assign h_sync = h_dly[0];
	assign v_sync = v_dly[0];
end
endgenerate
endmodule

//
// Top_template.v
//

module asteroids_8bitworkshop_top (

  input clk, reset,
  output hsync, vsync,
  output [31:0] rgb,
  input [7:0]keycode,
  output keystrobe
);

localparam WIDTH = 640;
localparam HEIGHT = 480;

//=======================================================
//  REG/WIRE declarations
//=======================================================

// Screens signals
wire	[$clog2(WIDTH )-1:0]pxl_x;
wire	[$clog2(HEIGHT)-1:0]pxl_y;
wire	[3:0]		vga_r_wire;
wire	[3:0]		vga_g_wire;
wire	[3:0]		vga_b_wire;
wire	[3:0]		Red_level;
wire	[3:0]		Green_level;
wire	[3:0]		Blue_level;

// Ghost module move and draw signals
wire	[3:0]		r_ghost;
wire	[3:0]		g_ghost;
wire	[3:0]		b_ghost;
wire				draw_ghost;
wire	[31:0]	topLeft_x_ghost;
wire	[31:0]	topLeft_y_ghost;

// Periphery signals
reg	A;
reg	B;
reg	Select;
reg	Start;
reg	Right;
reg	Left;
reg	Up;
reg	Down;
reg [11:0]	Wheel;

always @(posedge clk)
begin
    keystrobe <= keycode[7];
    A <= 1'b0;
    B <= 1'b0;
    Select <= 1'b0;
    Start <= 1'b0;
    Right <= 1'b0;
    Left <= 1'b0;
    Up <= 1'b0;
    Down <= 1'b0;
    if (reset)
        Wheel <= 12'b0;
    if (keycode[7])
    begin
        if ((keycode & 8'h7f) == "A")
            A <= 1'b1;
        if ((keycode & 8'h7f) == "B")
            B <= 1'b1;
        if ((keycode & 8'h7f) == 45) // INSERT
            Select <= 1'b1;
        if ((keycode & 8'h7f) == 46) // DELETE
            Start <= 1'b1;
        if ((keycode & 8'h7f) == 39)
            Right <= 1'b1;
        if ((keycode & 8'h7f) == 37)
            Left <= 1'b1;
        if ((keycode & 8'h7f) == 38)
            Up <= 1'b1;
        if ((keycode & 8'h7f) == 40)
            Down <= 1'b1;
        if (((keycode & 8'h7f) >= 48) && ((keycode & 8'h7f) <= 57))
            Wheel <= keycode[3:0] * 227;
    end
end

// Screens Assigns
// convert 12 bit rgb to 32 bit rgba
assign rgb = {8'b1, vga_r_wire, 4'b0000, vga_g_wire, 4'b0000, vga_b_wire, 4'b0000};

// VGA controller (LCD removed)

Screens_dispaly #(
	.WIDTH(WIDTH),
	.HEIGHT(HEIGHT),
	.RGB_LAT(2)
) Screen_control(
	.clk_25(clk),
	.Red_level(Red_level),
	.Green_level(Green_level),
	.Blue_level(Blue_level),
	.pxl_x(pxl_x),
	.pxl_y(pxl_y),
	.Red(vga_r_wire),
	.Green(vga_g_wire),
	.Blue(vga_b_wire),
	.h_sync(hsync),
	.v_sync(vsync)
);

// Priority mux for the RGB
Drawing_priority drawing_mux(
	.clk(clk),
	.resetN(~Select),
	.RGB_1(12'h000),
	.draw_1(1'b0),
	.RGB_2({r_ghost,g_ghost,b_ghost}),
	.draw_2(draw_ghost),
	.RGB_bg(12'hFFF),
	.Red_level(Red_level),
	.Green_level(Green_level),
	.Blue_level(Blue_level)
	);
	
// Ghost unit
Ghost_unit #(
	.WIDTH(WIDTH),
	.HEIGHT(HEIGHT)
) Ghost_unit_inst(	
	.clk(clk),
	.resetN(~Select),
	.collision(1'b0 && draw_ghost),
	.B(B),
	.pxl_x(pxl_x),
	.pxl_y(pxl_y),
	.wheel(Wheel),
	.Red(r_ghost),
	.Green(g_ghost),
	.Blue(b_ghost),
	.Draw(draw_ghost)
);	

endmodule
