// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************

module Torpedo_Unit #(
	parameter WIDTH = 640,
	parameter HEIGHT = 480,
    parameter TORPEDOS = 2
) (
	
	input  clk,
	input  resetN,
	input  collision,
	input  [$clog2(WIDTH )-1:0]pxl_x,
	input  [$clog2(HEIGHT)-1:0]pxl_y,
	input  [$clog2(WIDTH )-1:0]ship_x,
	input  [$clog2(HEIGHT)-1:0]ship_y,
    input  vsync,
    input signed [17:0] sin_val,
    input signed [17:0] cos_val,
    input  fire,
    output fire_out,
    output t_dead,
    output reg t_fire,
    output fire_deb_out,
	output [3:0]Red,
	output [3:0]Green,
	output [3:0]Blue,
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

//
// count vsync pulses to generate low frequency counter for sprite flipping
//
localparam X_W = $clog2(WIDTH);
localparam Y_W = $clog2(HEIGHT);
localparam XY_W = (X_W > Y_W) ? X_W : Y_W;

localparam ANIM_CNT = 12;
localparam ANIM_CNT_M1 = ANIM_CNT - 1;
reg [$clog2(ANIM_CNT)-1:0]anim_cnt;
reg anim_pulse;
reg vsync_d;
reg tx, ty; // temporary overflow flags
//reg t_fire;

wire Draw_t;

reg fire_deb, fire_deb_test; // debounce
always @(posedge clk) begin
    vsync_d <= vsync;
    anim_pulse <= 1'b0;
    if (vsync && !vsync_d) begin
        fire_deb <= fire_deb_test; // result of debounce
        fire_deb_test <= 1'b1; // try fire pulse every 1/60s
        if(anim_cnt > 0) 
            anim_cnt <= anim_cnt - {{($bits(anim_cnt)-1){1'b0}}, 1'b1};
        else begin
            anim_cnt <= ANIM_CNT_M1[$bits(anim_cnt)-1:0];
            anim_pulse <= 1'b1;
        end
    end else begin
        // any cycle might reset it
        fire_deb_test <= fire_deb_test && fire;
    end

end

// we have 3 sprite cycles
localparam ANIM_CYCLE = 3;
localparam ANIM_CYCLE_M1 = ANIM_CYCLE - 1;
reg [$clog2(ANIM_CYCLE)-1:0]anim_cycle;
always @(posedge clk)
    if (anim_pulse)
        if (anim_cycle)
            anim_cycle <= anim_cycle - {{($bits(anim_cycle)-1){1'b0}}, 1'b1};
        else 
            anim_cycle <= ANIM_CYCLE_M1[$bits(anim_cycle)-1:0];

// calculate base address in ROM of each anim frame
localparam ANIM_SIZE=90;
wire [$clog2(ANIM_SIZE*(ANIM_CYCLE-1))-1:0]anim_base =
    (anim_cycle == 2) ? (2 * ANIM_SIZE) :
    (anim_cycle == 1) ? (1 * ANIM_SIZE) :
                        0;

localparam XY_FRACTION = 7; // subpixel fraction bits
wire signed [1+XY_W+XY_FRACTION-1:0]t_speed = {1'b0, 10'd5,{XY_FRACTION{1'b0}}}; // sign (always 0), int, fraction
reg	[$clog2(WIDTH )+XY_FRACTION-1:0]torpedo_x;
reg	[$clog2(HEIGHT)+XY_FRACTION-1:0]torpedo_y;
reg	signed [$clog2(WIDTH )+XY_FRACTION:0]torpedo_xd; // 1 extra bit for sign
reg	signed [$clog2(HEIGHT)+XY_FRACTION:0]torpedo_yd; // 1 extra bit for sign
// These have 17 fraction bits from sin/cos plus XY_FRACTION
// we subtract 2 because we have 1 redundant sign bit
// we also move 90 degrees forward: sin=>cos, cos=>-sin (by doing -t_speed)
// we do it because the torpedo is drawn pointing to the right, not upwards
wire [$bits(t_speed)+$bits(sin_val)-2:0]torpedo_xd_t = cos_val *  t_speed;
wire [$bits(t_speed)+$bits(cos_val)-2:0]torpedo_yd_t = sin_val * -t_speed;
assign t_dead = t_fire && (tx || ty || (torpedo_x[($bits(torpedo_x) - 1):XY_FRACTION] > WIDTH) || (torpedo_y[($bits(torpedo_y) - 1):XY_FRACTION] > HEIGHT));

// generate sync signal for reading sin/cos output 2 cycles later
reg fire_deb_d1, fire_deb_d2, fire_deb_d3, t_fire_out;
always @(posedge clk) begin
    fire_deb_d1 <= fire_deb;
    fire_deb_d2 <= fire_deb_d1;
    fire_deb_d3 <= fire_deb_d2;
end
// Draw only if torpedo is flying
assign Draw = Draw_t && t_fire;
// cascade torpedos, shoot next one only if this one is already flying
assign fire_out = fire_deb && t_fire_out;
assign fire_deb_out = fire_deb;

reg signed [17:0] t_sin_val;
reg signed [17:0] t_cos_val;
reg [$clog2(WIDTH )-1:0]t_x;
reg [$clog2(HEIGHT)-1:0]t_y;

always @(posedge clk or negedge resetN) begin
    if (~resetN) begin
        t_fire <= 1'b0;
    end else begin
        if (t_fire && !fire_deb)
            // fire released, we are ready for next press
            t_fire_out <= 1'b1;
        if (t_dead) begin
            t_fire <= 1'b0;
            t_fire_out <= 1'b0; // torpedo dead, block next torpedos
            // truncate top bits so that torpedo_x/y falls
            // within legal range and doesn't constantly inhibit
            // new torpedos
            torpedo_x[($bits(torpedo_x) - 1) -: 3] <= 1'b0;
            torpedo_y[($bits(torpedo_y) - 1) -: 3] <= 1'b0;
            tx <= 1'b0;
            ty <= 1'b0;
        end else if (fire_deb && !fire_deb_d1 && !t_fire) begin
            // 1st cycle, and no existing torpedo
            // set initial position
            torpedo_x <= {ship_x, {XY_FRACTION{1'b0}}};
            torpedo_y <= {ship_y, {XY_FRACTION{1'b0}}};
        end else if (t_fire && vsync && !vsync_d) begin
            // update position every vsync (60Hz)
            // we use fractional positioning for smooth movement
            {tx, torpedo_x} <= {1'b0, torpedo_x} + torpedo_xd;
            {ty, torpedo_y} <= {1'b0, torpedo_y} + torpedo_yd;
        end
        if (fire_deb_d2 && !fire_deb_d3 && !t_fire) begin
            t_fire <= 1'b1;
            // notice we ytake sin/cos val and phase shift 
            t_sin_val <= sin_val;
            t_cos_val <= cos_val;
            // save less fraction bits
            torpedo_xd <= torpedo_xd_t[($bits(sin_val)-1) +: (XY_FRACTION+X_W+1)]; // fraction, int, sign
            torpedo_yd <= torpedo_yd_t[($bits(cos_val)-1) +: (XY_FRACTION+Y_W+1)]; // fraction, int, sign
        end
    end
end
wire [8:0]sprite_addr;
wire [11:0]sprite_data;

Draw_Sprite #(
    .WIDTH(WIDTH),
    .HEIGHT(HEIGHT),
    .TRANSPARENT(12'hfff)
) draw_inst2(
    .clk(clk),
    .resetN(resetN),
    .pxl_x(pxl_x),
    .pxl_y(pxl_y),
    .topLeft_x(torpedo_x[($bits(torpedo_x) - 1):XY_FRACTION] - 10'd9),
    .topLeft_y(torpedo_y[($bits(torpedo_y) - 1):XY_FRACTION] - 9'd2),
    .width(10'd18),
    .height(9'd5),
    .offset_x(10'd9),
    .offset_y(9'd2),
    .sin_val(t_sin_val),
    .cos_val(t_cos_val),
    .sprite_addr(sprite_addr),
    .sprite_data(sprite_data),
    .Red_level(Red),
    .Green_level(Green),
    .Blue_level(Blue),
    .Drawing(Draw_t)
    );

torpedo	torpedo_inst (
    .clock(clk),
    .address(sprite_addr + anim_base),
    .q(sprite_data)
);
endmodule