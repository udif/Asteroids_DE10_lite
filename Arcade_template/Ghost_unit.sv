// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************



module Ghost_unit (
	
	input		clk,
	input		resetN,
	input		collision,
	input		[31:0]	pxl_x,
	input		[31:0]	pxl_y,
	input    [11:0]    wheel,
	output	[3:0]		Red,
	output	[3:0]		Green,
	output	[3:0]		Blue,
	output	Draw
	);
	
	wire	[31:0]	topLeft_x_ghost;
	wire	[31:0]	topLeft_y_ghost;
	wire	ghost_x_direction;
	
	wire [17:0]wheel_adjusted = wheel * 6'd34;
	
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
	.width(10'd64),
	.height(9'd64),
	.offset_x(10'd32),
	.offset_y(9'd32),
	.theta(wheel_adjusted[16:7]),
	.Red_level(Red),
	.Green_level(Green),
	.Blue_level(Blue),
	.Drawing(Draw)
	);
endmodule