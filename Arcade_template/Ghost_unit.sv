// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************



module Ghost_unit (
	
	input		clk,
	input		resetN,
	input		collision,
	input		[31:0]	pxl_x,
	input		[31:0]	pxl_y,
	output	[3:0]		Red,
	output	[3:0]		Green,
	output	[3:0]		Blue,
	output	Draw
	);
	
	wire	[31:0]	topLeft_x_ghost;
	wire	[31:0]	topLeft_y_ghost;
	wire	ghost_x_direction;
	
	
	Move_Ghost move_inst2(
	.clk(clk),
	.resetN(resetN),
	.collision(collision),
	.x_direction(ghost_x_direction),
	.topLeft_x(topLeft_x_ghost),
	.topLeft_y(topLeft_y_ghost)
	);

Draw_Ghost draw_inst2(
	.clk(clk),
	.resetN(resetN),
	.pxl_x(pxl_x),
	.pxl_y(pxl_y),
	.topLeft_x(topLeft_x_ghost),
	.topLeft_y(topLeft_y_ghost),
	.width(32'd64),
	.high(32'd64),
	.x_direction(ghost_x_direction),
	.Red_level(Red),
	.Green_level(Green),
	.Blue_level(Blue),
	.Drawing(Draw)
	);
endmodule