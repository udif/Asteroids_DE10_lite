// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************



module Intel_unit (
	
	input		clk,
	input		resetN,
	input		[11:0]	Wheel,
	input		Up,
	input		Down,
	input		[31:0]	pxl_x,
	input		[31:0]	pxl_y,
	output	[3:0]		Red,
	output	[3:0]		Green,
	output	[3:0]		Blue,
	output	Draw
	);
	
	wire	[31:0]	topLeft_x_intel;
	wire	[31:0]	topLeft_y_intel;
	
	Move_Intel move_inst1(
	.clk(clk),
	.resetN(resetN),
	.wheel(Wheel),
	.up(Up),
	.down(Down),
	.topLeft_x(topLeft_x_intel),
	.topLeft_y(topLeft_y_intel)
	);
	
	Draw_Intel draw_inst1(
	.clk(clk),
	.resetN(resetN),
	.pxl_x(pxl_x),
	.pxl_y(pxl_y),
	.topLeft_x(topLeft_x_intel),
	.topLeft_y(topLeft_y_intel),
	.width(32'd128),
	.high(32'd64),
	.Red_level(Red),
	.Green_level(Green),
	.Blue_level(Blue),
	.Drawing(Draw)
	);
endmodule