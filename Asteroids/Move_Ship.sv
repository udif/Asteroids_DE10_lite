//
// Copyright (C) 2022 Udi Finkelstein
//

`define SIGN_EXTEND(bits, vec) {{(bits - $bits(vec)){vec[$bits(vec)-1]}}, vec}
`define ZERO_PAD(bits, vec) {{(bits - $bits(vec)){1'b0}}, vec}
// same but for constants
`define ZERO_PAD_C(bits, c) {{(bits - $clog2(c)){1'b0}}, c[$clog2(c)-1:0]}
// if we check size by $clog2, it is meaningless for signess, sinec we'll always get 1 at the high bit
//`define SIGN_EXTEND_C(bits, c) {{(bits - $clog2(c)){vec[$clog2(c)-1]}}, c[$clog2(c)-1:0]}

module Move_Ship #(
	// screen size
	parameter WIDTH=640,
	parameter HEIGHT=480,
	parameter BTN_RATE = 10, // 10 button updates/s
	parameter DIVIDER=125_000, // This is not a localparam for DV reasons
	parameter CLK_RATE=25_000_000, // ditto
	parameter DEBUG_SIZE = 1
) (
	
	input clk,
	input resetN,
	input collision,
	input Accelerator,
    // rotation angle, already encoded with sin/cos values
	input signed [17:0] sin_val,
	input signed [17:0] cos_val,

	output [$clog2(WIDTH )-1:0] topLeft_x,
	output [$clog2(HEIGHT)-1:0] topLeft_y
	//,output [DEBUG_SIZE-1:0][63:0]debug_out
);

	//
// X,Y coordinates are sized by WIDTH and HEIGHT, and have XY_FRACTION fraction bits
//
localparam X_W = $clog2(WIDTH);
localparam Y_W = $clog2(HEIGHT);
localparam XY_FRACTION = 16; // subpixel fraction bits
// actual counter limit value
localparam DIVIDER_M_1 = DIVIDER - 1;
// make it fit into the counter's bits
localparam [$clog2(DIVIDER)-1:0]DIV_LIMIT = DIVIDER_M_1[$clog2(DIVIDER)-1:0];

// divide WIDTH, HEIGHT by 2 for initial location (center of screen)
localparam [X_W+XY_FRACTION-1:0]	x_init = {1'b0, WIDTH [X_W-1:1], {XY_FRACTION{1'b0}}};
localparam [Y_W+XY_FRACTION-1:0]	y_init = {1'b0, HEIGHT[Y_W-1:1], {XY_FRACTION{1'b0}}};

//
// All speed variables have 17 fraction bits due to sin/cos val
// We can easily reduce that, but HW multipliers are 18x18 anyhow.
// Fractions are important because we increment position at framerate (at least)
//
// Notice that the speed field width is taken from here automatically even without
// defining a parameter
localparam SPEED_FRAC_BITS = 12;
// Integer part of speed before sin/cos scaling
localparam SPEED = (1 << 14) / BTN_RATE;
// How many bits in speed are fractions
//
// We have a main divider for position update
// but we divide it further for 0.1s for button update rate
// We don't want to read the acceleration button 200 times/s
//
localparam BTN_DIVIDER = (CLK_RATE / DIVIDER / BTN_RATE);
localparam BTN_DIVIDER_M1 = BTN_DIVIDER - 1;

reg [$clog2(BTN_DIVIDER)-1:0]btn_counter;

// When counter wraps around, we update position and speed
reg [$clog2(DIVIDER)-1:0]counter;

//
// All speed variables are 8.17s (8 bits signed int, 17 bits fraction)
// one bit less is due to sin/cos sign bit
localparam SPEED_W = $bits(sin_val)-1+($clog2(SPEED)+2);

wire signed [SPEED_W-1:0]x_speed_inc = $signed({4'b0, SPEED[$clog2(SPEED):3]}) * sin_val;
wire signed [SPEED_W-1:0]y_speed_inc = $signed({4'b0, SPEED[$clog2(SPEED):3]}) * cos_val;
reg  signed [SPEED_W-1:0]x_speed;
reg  signed [SPEED_W-1:0]y_speed;

//
// New speed
//
wire signed [SPEED_W-1:0]x_speed_new = x_speed - x_speed_inc;
wire signed [SPEED_W-1:0]y_speed_new = y_speed + y_speed_inc;

// Temporary position before we take into account wraparound
// We add 2 more bit because these fields can temporarily overflow WIDTH and HEIGHT
// and we also need a sign bit in case x/y_speed_inc are negative and cause us to underflow
reg signed [X_W+XY_FRACTION+1:0]x_temp;
reg signed [Y_W+XY_FRACTION+1:0]y_temp;

// These with be +/- WIDTH/HEIGHT to fix overflow/underflow as necessary
reg signed [X_W+XY_FRACTION+1:0]x_temp_fix;
reg signed [Y_W+XY_FRACTION+1:0]y_temp_fix;

// These are the real flops storing the position
reg [X_W+XY_FRACTION-1:0]x;
reg [Y_W+XY_FRACTION-1:0]y;

// This is x_speed/y_speed with reduced precision to XY_FRACTION
// we don't bother with rounding.
// we start at x/y_speed fraction point position ($bits(sin_val)-1), then mode right XY_FRACTION bits,
// since this is the x/y precision, and we make up for this by addition those XY_FRACTION bits to the width
wire [((SPEED_W-1)-(($bits(sin_val)-1)+SPEED_FRAC_BITS-XY_FRACTION)+1)-1:0]x_speed_2 = x_speed[SPEED_W-1:($bits(sin_val)-1)+SPEED_FRAC_BITS-XY_FRACTION];
wire [((SPEED_W-1)-(($bits(sin_val)-1)+SPEED_FRAC_BITS-XY_FRACTION)+1)-1:0]y_speed_2 = y_speed[SPEED_W-1:($bits(sin_val)-1)+SPEED_FRAC_BITS-XY_FRACTION];

//assign debug_out[0] = {`SIGN_EXTEND(32, x), `SIGN_EXTEND(32, y)};

//assign debug_out[1] = {speed_update_ok, `SIGN_EXTEND(63, x_speed_new)};

//assign debug_out[0] = `SIGN_EXTEND(64, x_speed_2);

//assign debug_out[1] = `SIGN_EXTEND(64, x_temp);

//assign debug_out[2] = `SIGN_EXTEND(64, x_temp_fix);

//assign debug_out[3] = `SIGN_EXTEND(64, x);

always_comb
begin
	// update position with speed. both are signed numbers, although we later drop the x/y sign bit
	// we start with an unsigned x/y pos and end with a new x/y pos that may either underflow (negative)
	// or overflow the allocated WIDTH/HEIGHT bits, and we need to detect both cases
	x_temp = {2'b0, x} + `SIGN_EXTEND($bits(x_temp), x_speed_2);
	// We subtract here because while math axes has Y positive going up,
	// The computer graphics axes has (0,0) at top-left with Y positive going down
	y_temp = {2'b0, y} - `SIGN_EXTEND($bits(y_temp), y_speed_2);

	// We only check integer bits and ignore fraction bits because WIDTH/HEIGHT have no fractions
	x_temp_fix[XY_FRACTION-1:0] = '0;
	if (x_temp < 0)
		x_temp_fix[XY_FRACTION +: (X_W + 2)] = {2'b0, WIDTH[X_W-1:0]};
	else if (x_temp[XY_FRACTION +: (X_W + 2)] >= {2'b0, WIDTH[X_W-1:0]})
		x_temp_fix[XY_FRACTION +: (X_W + 2)] = -$signed({2'b0, WIDTH[X_W-1:0]});
	else
		x_temp_fix[XY_FRACTION +: (X_W + 2)] = '0;

	y_temp_fix[XY_FRACTION-1:0] = '0;
	if (y_temp < 0)
		y_temp_fix[XY_FRACTION +: (Y_W + 2)] = {2'b0, HEIGHT[Y_W-1:0]};
	else if (y_temp[XY_FRACTION +: (Y_W + 2)] >= {2'b0, HEIGHT[Y_W-1:0]})
		y_temp_fix[XY_FRACTION +: (Y_W + 2)] = -$signed({2'b0, HEIGHT[Y_W-1:0]});
	else
		y_temp_fix[XY_FRACTION +: (Y_W + 2)] = '0;
end

// check if both x and y 3 top bits are wither 000 or 111
wire speed_update_ok =
	(( &x_speed_new[SPEED_W-1 -: 2]) ||  // new x speed less than 25% of max neg
	 (~|x_speed_new[SPEED_W-1 -: 2])) && // new x speed less than 25% of max pos
	(( &y_speed_new[SPEED_W-1 -: 2]) ||  // new y speed less than 25% of max neg
	 (~|y_speed_new[SPEED_W-1 -: 2]));   // new y speed less than 25% of max pos

always @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		x <= x_init;
		y <= y_init;
		counter <= '0;
		x_speed <= '0;
		y_speed <= '0;
	end
	else begin
		counter <= counter + 1'b1;
		if(collision) begin
			x <= x_init;
			y <= y_init;
			counter <= '0;
			x_speed <= '0;
			y_speed <= '0;
		end
		if (counter == DIV_LIMIT) begin
			btn_counter <= btn_counter + 1'b1;
			if (btn_counter == BTN_DIVIDER_M1[$clog2(BTN_DIVIDER)-1:0]) begin
				$display("reset");
				btn_counter <= '0;
				if (Accelerator && speed_update_ok) begin
					$display("speed inc");
					x_speed <= x_speed_new;
					y_speed <= y_speed_new;
				end
			end
			counter <= '0;
			x <= x_temp[$bits(x)-1:0] + x_temp_fix[$bits(x)-1:0];
			y <= y_temp[$bits(y)-1:0] + y_temp_fix[$bits(y)-1:0];
		end
	end
end
	
assign topLeft_x = x[XY_FRACTION +: X_W];
assign topLeft_y = y[XY_FRACTION +: Y_W];

endmodule	