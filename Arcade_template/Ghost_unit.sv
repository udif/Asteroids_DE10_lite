// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************



module Ghost_unit #(
	parameter WIDTH = 640,
	parameter HEIGHT = 480
) (
	
	input		clk,
	input		resetN,
	input		collision,
	input		B,
	input		[$clog2(WIDTH )-1:0]pxl_x,
	input		[$clog2(HEIGHT)-1:0]pxl_y,
	input    [11:0]    wheel,
	output	[3:0]		Red,
	output	[3:0]		Green,
	output	[3:0]		Blue,
	output	Draw
	);

// NOte for later:
//   parameter h_pixels   = 640,   // horizontal display
//   parameter h_fp       = 16,    // horizontal Front Porch
//   parameter h_pulse    = 96,    // horizontal sync pulse
//   parameter h_bp       = 48,    // horizontal back porch
//   parameter v_pixels   = 480,   // vertical display
//   parameter v_fp       = 10,    // vertical front porch
//   parameter v_pulse    = 2,     // vertical pulse
//  parameter v_bp       = 33,    // vertical back porch
//
// Horizontal data is sent for 640 cycles:
// then 16 cycles front porch,
// then 96 cycles horizontal pulse,
// then 48 cycles back porch.
// total is 160 free cycles between lines!
// On the vertical side we have:
// each line is 800 cycles (h_pixels + h_fp + h_pulse + h_bp)
// between each frame we have:
// 10 lines v_fp (8000 cycles)
// 2 lines vertical pulse (1600 cycles)
// 33 lines back porch (26400 cycles)



wire	[$clog2(WIDTH )-1:0]topLeft_x_ghost;
wire	[$clog2(HEIGHT)-1:0]topLeft_y_ghost;
	
// The analog output seems to be in the range 0x00 - 0xF4
// we need to multiply the 12 bit ADC by 6 bit to get 18 bit adjusted value
// from which we'll take [17:6]
// 256 / 0xf4 * 32 = 33.573 => 6'd34
wire [17:0]wheel_adjusted = wheel * 6'd34;
	
wire signed [17:0] sin_val;
wire signed [17:0] cos_val;

sin_cos sin_cos_inst (
	.clk(clk),
	.phase(wheel_adjusted[16:7]),
	.sin_val(sin_val),
	.cos_val(cos_val)
);

Move_Ghost #(
	.WIDTH(WIDTH),
	.HEIGHT(HEIGHT)
) move_inst2(
	.clk(clk),
	.resetN(resetN),
	.collision(collision),
	.B(B),
	.sin_val(sin_val),
	.cos_val(cos_val),
	.topLeft_x(topLeft_x_ghost),
	.topLeft_y(topLeft_y_ghost)
	);

Draw_Ghost #(
	.WIDTH(WIDTH),
	.HEIGHT(HEIGHT)
) draw_inst2(
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
	.sin_val(sin_val),
	.cos_val(cos_val),
	.Red_level(Red),
	.Green_level(Green),
	.Blue_level(Blue),
	.Drawing(Draw)
	);
endmodule