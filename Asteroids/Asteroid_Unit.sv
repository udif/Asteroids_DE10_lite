// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************

module Asteroid_unit #(
	parameter WIDTH = 640,
	parameter HEIGHT = 480
) (
	
	input  clk,
	input  resetN,
	vga.in  vga_chain_in,
	vga.out vga_chain_out,
    input  vsync, // already in 1-cycle pulse form
    input draw_mask,
    input start_done,
    input  new_asteroid,
    input  asteroid_hit,
    output [6:0]ast_points,
    output [23:0]Debug_Bus
	//,output [DEBUG_SIZE-1:0][63:0]debug_out
);

// Note for later:
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

wire signed [17:0]sin_val;
wire signed [17:0]cos_val;

localparam XY_FRACTION = 7; // subpixel fraction bits

logic [1:0]tx;
logic [1:0]ty; // temporary overflow flags
wire signed [1+XY_W+XY_FRACTION-1:0]t_speed = {1'b0, 10'd3,{XY_FRACTION{1'b0}}}; // sign (always 0), int, fraction
logic [$clog2(WIDTH )+XY_FRACTION-1:0]asteroid_x;
logic [$clog2(HEIGHT)+XY_FRACTION-1:0]asteroid_y;
logic [$clog2(WIDTH )+XY_FRACTION-1:0]asteroid_x_init;
logic [$clog2(HEIGHT)+XY_FRACTION-1:0]asteroid_y_init;
logic [$clog2(WIDTH )+XY_FRACTION-1:0]asteroid_x_n;
logic [$clog2(HEIGHT)+XY_FRACTION-1:0]asteroid_y_n;
logic [$clog2(WIDTH )+XY_FRACTION-1:0]asteroid_x_mod;
logic [$clog2(HEIGHT)+XY_FRACTION-1:0]asteroid_y_mod;
logic signed [$clog2(WIDTH )+XY_FRACTION:0]asteroid_xd; // 1 extra bit for sign
logic signed [$clog2(HEIGHT)+XY_FRACTION:0]asteroid_yd; // 1 extra bit for sign

logic [9:0]phase;
logic [3:0]phase_inc;
logic [9:0]phase_n;
logic [3:0]phase_inc_n;

wire [63:0]lfsr64out;

lfsr64 lfsr64_inst (
    .clk(clk),
    .rst(resetN),
    .out(lfsr64out)
);

sin_cos sin_cos_inst (
	.clk(clk),
	.phase(phase[9:0]),
	.sin_val(sin_val),
	.cos_val(cos_val)
);

//
// Anim file
// Size:150x212
// XLarge: (0,0)     size (150,142)
// Large:  (0,141)   size (75,71)
// Med:    (75,142)  size (38,36)
// Small:  (113,142) size (19,18)
localparam MEM_WIDTH=150;
localparam MEM_HEIGHT=212;

logic [$clog2(MEM_WIDTH*MEM_HEIGHT)-1:0]anim_base;
logic [$clog2(WIDTH )-1:0]sprite_width;
logic [$clog2(HEIGHT)-1:0]sprite_height;
typedef enum {AST_XLARGE, AST_LARGE, AST_MED, AST_SMALL} ast_t;
ast_t ast_type;
//logic [$clog2(AST_DEAD)-1:0] ast_type;

always_comb
    case(ast_type)
        AST_XLARGE: begin
            anim_base = '0;
            sprite_width = ($clog2(WIDTH ))'(150);
            sprite_height = ($clog2(HEIGHT))'(142);
            ast_points = 'x; // not used for shooting
        end
        AST_LARGE: begin
            anim_base = ($bits(anim_base))'(141*MEM_WIDTH+0);
            sprite_width = ($clog2(WIDTH ))'(75);
            sprite_height = ($clog2(HEIGHT))'(71);
            ast_points = ($bits(ast_points))'(20);
        end
        AST_MED: begin
            anim_base = ($bits(anim_base))'(141*MEM_WIDTH+75);
            sprite_width = ($clog2(WIDTH ))'(38);
            sprite_height = ($clog2(HEIGHT))'(36);
            ast_points = ($bits(ast_points))'(50);
        end
        AST_SMALL: begin
            anim_base = ($bits(anim_base))'(141*MEM_WIDTH+113);
            sprite_width = ($clog2(WIDTH ))'(19);
            sprite_height = ($clog2(HEIGHT))'(18);
            ast_points = ($bits(ast_points))'(100);
        end
        default: begin
            anim_base = 'x;
            sprite_width = 'x;
            sprite_height = 'x;
            ast_points = 'x;
        end
    endcase

assign {asteroid_x_init, asteroid_y_init, phase_n, phase_inc_n} = lfsr64out[0 +: ($bits(asteroid_x_init) + $bits(asteroid_y_init) + $bits(phase_inc) + $bits(phase))];
// pad X,Y by 2 bits, one for overflow for positive increments, and one for detecting negatives
// since _t vars are only signed, sign-extend them by 1 more bit
assign {tx, asteroid_x_n} = {2'b0, asteroid_x} + {asteroid_xd_t[$bits(asteroid_xd_t)-1], asteroid_xd_t[$bits(asteroid_xd_t)-1 : ($bits(sin_val)-1)]}; // fraction, int, sign
assign {ty, asteroid_y_n} = {2'b0, asteroid_y} + {asteroid_yd_t[$bits(asteroid_yd_t)-1], asteroid_yd_t[$bits(asteroid_yd_t)-1 : ($bits(cos_val)-1)]}; // fraction, int, sign
// if outside margins, fix it
assign asteroid_x_mod[XY_FRACTION +: $clog2(WIDTH )] = tx[1] ? (asteroid_x_n[XY_FRACTION +: $clog2(WIDTH )] + WIDTH ) : (asteroid_x_n[XY_FRACTION +: $clog2(WIDTH )] > WIDTH ) ? (asteroid_x_n[XY_FRACTION +: $clog2(WIDTH )] - WIDTH ) : asteroid_x_n[XY_FRACTION +: $clog2(WIDTH )];
assign asteroid_y_mod[XY_FRACTION +: $clog2(HEIGHT)] = ty[1] ? (asteroid_y_n[XY_FRACTION +: $clog2(HEIGHT)] + HEIGHT) : (asteroid_y_n[XY_FRACTION +: $clog2(HEIGHT)] > HEIGHT) ? (asteroid_y_n[XY_FRACTION +: $clog2(HEIGHT)] - HEIGHT) : asteroid_y_n[XY_FRACTION +: $clog2(HEIGHT)];
// fractions are not used for calculations, just copy them
assign asteroid_x_mod[XY_FRACTION-1:0] = asteroid_x_n[XY_FRACTION-1:0];
assign asteroid_y_mod[XY_FRACTION-1:0] = asteroid_y_n[XY_FRACTION-1:0];
// These have 17 fraction bits from sin/cos plus XY_FRACTION
// we subtract 2 because we have 1 redundant sign bit
// we also move 90 degrees forward: sin=>cos, cos=>-sin (by doing -t_speed)
// we do it because the asteroid is drawn pointing to the right, not upwards
logic signed [$bits(t_speed)+$bits(sin_val)-2:0]asteroid_xd_t;
logic signed [$bits(t_speed)+$bits(cos_val)-2:0]asteroid_yd_t;

always @(posedge clk) begin
    if (~start_done) begin
        ast_type <= AST_XLARGE;
        asteroid_x <= {($clog2(WIDTH ))'(WIDTH/2), (XY_FRACTION)'(0)};
        asteroid_y <= {($clog2(HEIGHT))'(HEIGHT-142/2), (XY_FRACTION)'(0)};
    end else if (new_asteroid) begin
        ast_type <= AST_LARGE;
        asteroid_x <= {asteroid_x_init, (XY_FRACTION)'(0)};
        asteroid_y <= {asteroid_y_init, (XY_FRACTION)'(0)};
    end else if (asteroid_hit) begin
//      ast_type <= (ast_type == AST_SMALL) ? AST_LARGE : (ast_type == AST_MED) ? AST_SMALL : AST_MED; //ast_type.next();// ast_t'(ast_type + ($bits(ast_type))'(1));
        ast_type <= (ast_type == AST_SMALL) ? AST_LARGE : ast_type.next();
//      ast_type <= (ast_type == AST_SMALL) ? ($bits(ast_type))'(AST_LARGE) : (ast_type + ($bits(ast_type))'(1));
    end
    if (~start_done & vsync) begin
        phase <= phase + ($bits(phase))'(20);
    end else if (new_asteroid || asteroid_hit) begin
        // generate random angle, rotation speed and location
        phase <= phase_n;
        phase_inc <= phase_inc_n;
        asteroid_xd_t <= sin_val * -t_speed;
        asteroid_yd_t <= cos_val * -t_speed;
    end else if (vsync) begin
        phase <= phase + ($bits(phase))'(phase_inc);
        // update position every vsync (60Hz)
        // we use fractional positioning for smooth movement
        asteroid_x <= asteroid_x_mod;
        asteroid_y <= asteroid_y_mod;
    end
end
assign Debug_Bus =
    {1'b0, anim_base, 6'b0, ast_type[1:0]};
    // {asteroid_xd_t[$bits(asteroid_xd_t)-1 -: 12], asteroid_yd_t[$bits(asteroid_yd_t)-1 -: 12]};
    //{2'b0, sprite_width, 3'b0, sprite_height};
    //{sin_val[17 -: 12], cos_val[17 -: 12]};
    // {asteroid_x, phase, phase_inc_n};

wire [$bits(anim_base)-1:0]sprite_addr;
wire [4:0]sprite_data;

Draw_Sprite #(
    .WIDTH(WIDTH),
    .HEIGHT(HEIGHT),
    .TRANSPARENT(12'h080)
) draw_inst (
    .clk(clk),
    .resetN(resetN),
	.vga_chain_in(vga_chain_in),
	.vga_chain_out(vga_chain_out),
    .topLeft_x(asteroid_x[($bits(asteroid_x) - 1):XY_FRACTION] - sprite_width [$bits(sprite_width )-1:1]),
    .topLeft_y(asteroid_y[($bits(asteroid_y) - 1):XY_FRACTION] - sprite_height[$bits(sprite_height)-1:1]),
    .width(sprite_width),
    .height(sprite_height),
    .offset_x(sprite_width [$bits(sprite_width )-1:1]),
    .offset_y(sprite_height[$bits(sprite_height)-1:1]),
    .sin_val(sin_val),
    .cos_val(cos_val),
    .draw_mask(draw_mask && ~sprite_data[0] /*&& (ast_type <= AST_SMALL)*/), // Draw only if torpedo is flying
	.mem_width(MEM_WIDTH), // same as width in this case
    .sprite_addr(sprite_addr),
    .sprite_data({3{sprite_data[4:1]}})
);

asteroid asteroid_inst (
    .clock(clk),
    .address(sprite_addr + anim_base),
    .q(sprite_data)
);
endmodule