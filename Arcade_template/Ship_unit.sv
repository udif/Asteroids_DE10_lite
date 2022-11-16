// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************



module Ship_unit #(
	parameter WIDTH = 640,
	parameter HEIGHT = 480,
	parameter DEBUG_SIZE = 1
) (
	
	input		clk,
	input		resetN,
	input		collision,
	input		B,
	input		[$clog2(WIDTH )-1:0]pxl_x,
	input		[$clog2(HEIGHT)-1:0]pxl_y,
	output [$clog2(WIDTH )-1:0]ship_x,
	output [$clog2(HEIGHT)-1:0]ship_y,
	input    [11:0]    wheel,
	output signed [17:0] sin_val,
	output signed [17:0] cos_val,
	input anim_pulse,
	output	[3:0]		Red,
	output	[3:0]		Green,
	output	[3:0]		Blue,
	output	Draw
	//,output [DEBUG_SIZE-1:0][63:0]debug_out
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

wire	[$clog2(WIDTH )-1:0]topLeft_x_ship;
wire	[$clog2(HEIGHT)-1:0]topLeft_y_ship;
	
// The analog output seems to be in the range 0x00 - 0xF4
// we need to multiply the 12 bit ADC by 6 bit to get 18 bit adjusted value
// from which we'll take [17:6]
// 256 / 0xf4 * 32 = 33.573 => 6'd34
wire [17:0]wheel_adjusted = wheel * 6'd34;

sin_cos sin_cos_inst (
	.clk(clk),
	.phase(wheel_adjusted[16:7]),
	.sin_val(sin_val),
	.cos_val(cos_val)
);

Move_Ship #(
	.WIDTH(WIDTH),
	.HEIGHT(HEIGHT),
	.DEBUG_SIZE(DEBUG_SIZE)
) move_inst2(
	.clk(clk),
	.resetN(resetN),
	.collision(collision),
	.B(B),
	.sin_val(sin_val),
	.cos_val(cos_val),
	.topLeft_x(topLeft_x_ship),
	.topLeft_y(topLeft_y_ship)
	//,.debug_out(debug_out)
	);

wire [11:0]sprite_addr;
wire [11:0]sprite_data;

// we have 4 sprite cycles
localparam ANIM_CYCLE_SPACESHIP = 4;
localparam ANIM_CYCLE_SPACESHIP_M1 = ANIM_CYCLE_SPACESHIP - 1;
reg [$clog2(ANIM_CYCLE_SPACESHIP)-1:0]anim_cycle_spaceship;
always @(posedge clk)
    if (anim_pulse)
        anim_cycle_spaceship <= anim_cycle_spaceship - {{($bits(anim_cycle_spaceship)-1){1'b0}}, 1'b1};

// calculate base address in ROM of each anim frame
localparam ANIM_SIZE_SPACESHIP=1020;
wire [$clog2(ANIM_SIZE_SPACESHIP * (ANIM_CYCLE_SPACESHIP - 1))-1:0]anim_base =
    ($bits(anim_base))'(!B ? '0: // no engine, no flame animation
                             (anim_cycle_spaceship * ANIM_SIZE_SPACESHIP));

Draw_Sprite #(
	.WIDTH(WIDTH),
	.HEIGHT(HEIGHT),
	.TRANSPARENT(12'h0f0)
) draw_inst2(
	.clk(clk),
	.resetN(resetN),
	.pxl_x(pxl_x),
	.pxl_y(pxl_y),
	.topLeft_x(topLeft_x_ship),
	.topLeft_y(topLeft_y_ship),
	.width(10'd30),
	.height(B ? 9'd34 : 9'd26),
	.offset_x(10'd15),
	.offset_y(9'd13),
	.center_x(ship_x),
	.center_y(ship_y),
	.sin_val(sin_val),
	.cos_val(cos_val),
	.sprite_rd(),
	.sprite_addr(sprite_addr),
	.sprite_data(sprite_data),
	.Red_level(Red),
	.Green_level(Green),
	.Blue_level(Blue),
	.Drawing(Draw)
	);

spaceship	spaceship_inst (
	.clock(clk),
	.address(sprite_addr + anim_base),
	.q(sprite_data)
);


endmodule