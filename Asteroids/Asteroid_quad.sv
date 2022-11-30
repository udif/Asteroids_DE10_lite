//
// Display up to 4 independent asteroids using 2 x 2-port ROMs
//
// When XLARGE flag is 1, sprite 0 has a special mode with an XLARGE asteroid
// used for the game opening sequence.
// If multiple Asteroid_quad are instanciated, only one will have XLARGE set.
//
import asteroids::*;
module Asteroid_quad #(
    parameter XLARGE = 0, // do we support XLARGE
	parameter WIDTH = 640,
	parameter HEIGHT = 480
) (
	
	input  clk,
	input  resetN,
    input [63:0]lfsr64out, // random data source
	vga.in  vga_chain_in,
	vga.out vga_chain_out,
    input  vsync, // already in 1-cycle pulse form
    input draw_mask,
    input start_done,
    input game_begin,
    input game_continue,
    input game_over,
    input  new_level,
    input  [T_NUM-1:0]torpedo_en,
    output [T_NUM-1:0]torpedo_hit,
    output [3:0]asteroid_en,
    output [10:0]ast_points,
    output [23:0]Debug_Bus
	//,output [DEBUG_SIZE-1:0][63:0]debug_out
);

// we get 64 random bits each cycle, and we mix them in 4 different ways,
// which should be enough as a pseudo random source for 4 different asteroids
// we would love to use the streaming operator but quartus doesn't support it
wire [3:0][63:0]lfsr64out_mixed = {
    lfsr64out,
    {lfsr64out[15:0], lfsr64out[63:16]},
    {lfsr64out[31:0], lfsr64out[63:32]},
    {lfsr64out[47:0], lfsr64out[63:48]}
}; // each asteroid has its own set of bits

logic [3:0][$bits(150*221)-1:0]sprite_addr;
logic [3:0][4:0]sprite_data;
// asteroids state:
// 2:0 are 1st asteroid, one-hot:
// 0 - large asteroid
// 1 - medium asteroid
// 2 - small asteroid
// 4:3 are 2nd asteroid, one-hot:
// 3 - medium asteroid
// 4 - small asteroid
// 5 is 3rd asteroid (small)
// 6 is 4th asteroid (small)
logic [6:0]asteroids_state, asteroids_state_n;

// accumulate hits until vsync, then start a new frame
logic [3:0]asteroid_hit, asteroid_hit_n;
always_ff @(posedge clk) begin
    if (vsync)
        asteroid_hit <= '0;
    else
        asteroid_hit <= asteroid_hit | asteroid_hit_n;
end

logic [3:0][4:0]points; // for 4 asteroids, 6'h2, 5'h5 or 5'h10 (20,50,100 points respectively)
logic [6:0]ast_points_hex;
// update points
// This happens once every vsync
always_ff @(posedge clk) begin
    // only 1st asteroid can be large
    points <= '0;
    if (game_continue && vsync) begin
        if (asteroids_state[0] & ~asteroids_state_n[0])
            points[0] <= ($bits(points[0]))'(5'h2);
        else if (asteroids_state[1] & ~asteroids_state_n[1])
            points[0] <= ($bits(points[0]))'(5'h5);
        else if (asteroids_state[2] & ~asteroids_state_n[2])
            points[0] <= ($bits(points[0]))'(5'h10);
        if (asteroids_state[3] & ~asteroids_state_n[3])
            points[1] <= ($bits(points[1]))'(5'h5);
        else if (asteroids_state[4] & ~asteroids_state_n[4])
            points[1] <= ($bits(points[1]))'(5'h10);
        if (asteroids_state[5] & ~asteroids_state_n[5])
            points[2] <= ($bits(points[2]))'(5'h10);
        if (asteroids_state[6] & ~asteroids_state_n[6])
            points[3] <= ($bits(points[3]))'(5'h10);
    end
end
assign ast_points_hex = {1'b0, {1'b0, points[0]} + {1'b0, points[1]}} + {1'b0, {1'b0, points[2]} + {1'b0, points[3]}};
// BCD adjust
assign ast_points = {({ast_points_hex[3:0] >= 4'd10} ? 7'h06 : 7'h0) + ast_points_hex, 4'b0};

// intenal new level also occures when all asteroids have been blown up
wire new_level_int = new_level | ~|asteroids_state;

//
// asteroids state machine
// control the lifecycle of a large asteroids that splits into two medium asteroids when hit,
// and each of them split into 2 small asteroids when they are hit
// we use dual states to do all updates only at the end of the frame
//
assign Debug_Bus[6:0] = ast_points[10:4];
assign Debug_Bus[15:9] = asteroids_state;
assign Debug_Bus[16] = game_begin & ~game_over;
assign Debug_Bus[23:17] = asteroids_state_n;
always_ff @(posedge clk or negedge resetN) begin
    if (~resetN) begin
        asteroids_state[6:0]   <= 7'b0_0_00_001;
        asteroids_state_n[6:0] <= 7'b0_0_00_001;
    end else begin
        if (vsync) begin
            if (new_level_int) begin
                asteroids_state[6:0]   <= 7'b0_0_00_001;
                asteroids_state_n[6:0] <= 7'b0_0_00_001;
            end else
                asteroids_state <= asteroids_state_n;
        end
        if (asteroid_hit[0]) begin
            if (asteroids_state[0]) begin
                asteroids_state_n[1:0] <= 2'b10; // turn off large 1st asteroid, turn on medium
                asteroids_state_n[3] <= 1'b1; // turn on medium 2nd asteroid
            end else if (asteroids_state[1]) begin
                asteroids_state_n[2:1] <= 2'b10; // turn off medium 1st asteroid, turn on small
                asteroids_state_n[5] <= 1'b1; // turn on small 3rd asteroid
            end else if (asteroids_state[2]) begin
                asteroids_state_n[2] <= 1'b0; // turn off small 1st asteroid
            end
        end
        if (asteroid_hit[1]) begin
            if (asteroids_state[3]) begin
                asteroids_state_n[4:3] <= 2'b10; // turn off medium 2nd asteroid, turn on small
                asteroids_state_n[6] <= 1'b1; // turn on small 4th asteroid
            end else if (asteroids_state[4]) begin
                asteroids_state_n[4] <= 1'b0; // turn off small 2nd asteroid
            end
        end
        if (asteroid_hit[2])
            asteroids_state_n[5] <= 1'b0; // turn off small 3rd asteroid
        if (asteroid_hit[3])
            asteroids_state_n[6] <= 1'b0; // turn off small 4th asteroid
    end
end
//
// New asteroid init
// For the 1st asteroid (large), we want initial (x,y) to be on the edges,
// and we want it to be moving inwards
// For medium and small asteroids that break off a larger one,
// we want the initial location to be the same, and the direction to be random,
// up to +/-45 degrees off the original one
//
wire      x_y_init = lfsr64out[50]; // 1 if stuck to x asis, 0 if stuck to y
wire      l_h_init = lfsr64out[51]; // 1 if stuck on low side (0 coord)
wire [8:0]low_bits_init   = lfsr64out[52 +: $bits(low_bits_init)];

// Asteroids always comes from the edge
wire [$clog2(WIDTH )-1:0]asteroid_x_init = x_y_init  ? (l_h_init ? '0 : ($clog2(WIDTH ))'(WIDTH-1))  : ($clog2(WIDTH ))'(low_bits_init);
wire [$clog2(HEIGHT)-1:0]asteroid_y_init = !x_y_init ? (l_h_init ? '0 : ($clog2(HEIGHT))'(HEIGHT-1)) : ($clog2(HEIGHT))'(low_bits_init);
wire [9:0]phase_n_init;
//  initialize phase regions
// 2'b00 is top right
// 2'b01 is top left
// 2'b10 is bottom left
// 2'b11 is bottom right
assign phase_n_init[9:8] =
    // bottom side, must be going up
    ({x_y_init, l_h_init} == 2'd0) ? ({1'b0, lfsr64out[40]}) : // 00 or 01
    // top side, must be going down
    ({x_y_init, l_h_init} == 2'd1) ? ({1'b1, lfsr64out[40]}) : // 10 or 11
    // right side, must be going left
    ({x_y_init, l_h_init} == 2'd2) ? ({lfsr64out[40], ~lfsr64out[40]}) : // 01 or 10
    // left side, must be going right
                                     ({2{lfsr64out[40]}}); // 00 or 11
logic [3:0][$clog2(WIDTH )-1:0]asteroid_x_out;
logic [3:0][$clog2(HEIGHT)-1:0]asteroid_y_out;
logic [3:0][9:0]asteroid_phase_out;

assign phase_n_init[7:0] = lfsr64out[41 +: 8];
// initial asteroid position
// we randomize it, unless it is an asteroid that broke off an existing one.

wire [3:0]asteroid_on = {asteroids_state[6:5], |asteroids_state[4:3], |asteroids_state[2:0]};

// use large memory only if necessary
generate
    if (XLARGE) begin
        asteroid_2p asteroid_inst_01 (
            .clock(clk),
            .address_a(sprite_addr[0]),
            .address_b(sprite_addr[1]),
            .q_a(sprite_data[0]),
            .q_b(sprite_data[1])
        );
    end else begin
        asteroid_l_m_s_2p asteroid_inst_23 (
            .clock(clk),
            .address_a(sprite_addr[0]),
            .address_b(sprite_addr[1]),
            .q_a(sprite_data[0]),
            .q_b(sprite_data[1])
        );
    end
endgenerate
// asteroids 2,3 can always use the small memory
asteroid_l_m_s_2p asteroid_inst_23 (
    .clock(clk),
    .address_a(sprite_addr[2]),
    .address_b(sprite_addr[3]),
    .q_a(sprite_data[2]),
    .q_b(sprite_data[3])
);

vga vga_chain_asteroid[0:4] ( /* .clk(clk_25) */ ) ;
assign vga_chain_asteroid[0].t = vga_chain_in.t;
assign vga_chain_out.t = vga_chain_asteroid[4].t;
genvar gi, gj;

// the only random asteroid is the 1st one
// large  0 is split to 0,1, so medium 0 and medium 1 takes location and approximage phase from 0
// medium 0 is split to 0,2, so 2 (small implied) and small 0 takes location and approximage phase from 0
// medium 1 is split to 1,3, so 3 (small implied) and small 1 takes location and approximage phase from 1
wire [3:0]parent_asteroid; // always 0 or 1
generate
    for (gi = 0; gi < 4; gi = gi + 1) begin : asteroids
        // see comment above for the only case asteroid 1 is parent
        assign parent_asteroid[gi] = ((gi == 1) && asteroids_state[3] || (gi == 3)) ? 1'b1 : 1'b0;
        Asteroid_unit #(
            .XLARGE((gi >= 2) ? 0 : 1), // only 1st can do XLARGE, but memory is shared with 1
            .WIDTH(WIDTH),
            .HEIGHT(HEIGHT)
        ) asteroid_unit_inst (
            .clk(clk),
            .resetN(resetN),
            .asteroid_x_init(((gi == 0) && new_level_int) ? asteroid_x_init : asteroid_x_out[{1'b0, parent_asteroid[gi]}]),
            .asteroid_y_init(((gi == 0) && new_level_int) ? asteroid_y_init : asteroid_y_out[{1'b0, parent_asteroid[gi]}]),
            .asteroid_x_out(asteroid_x_out[gi]),
            .asteroid_y_out(asteroid_y_out[gi]),
            .asteroid_phase_out(asteroid_phase_out[gi]),
            // split the 2 asteroids 90 degrees apart
            .phase_n(((gi == 0) && new_level_int) ? phase_n_init : // new large asteroid
                                                    // give 2 new med/small asteroids new phase based on original one wth up to +-45 degrees off
                                                    // the pairs that split are (0,1), (0,2) and (1,3) => gi[0]^gi[1] will give unique ID in both cases
                                                    (asteroid_phase_out[{1'b0, parent_asteroid[gi]}] + {{3{phase_n_init[7]}}, (gi[0]^gi[1]), phase_n_init[5:0]})),
            .phase_inc_n(lfsr64out[gi*4 +: 4]),
            .vga_chain_in(vga_chain_asteroid[gi]),
            .vga_chain_out(vga_chain_asteroid[gi+1]),
            .vsync(vsync),
            .draw_mask(!game_over && asteroid_on[gi] && ((XLARGE == 1) || game_begin)), // if XLARGE allow sprite on start
            .start_done(((gi == 0) && XLARGE) ? start_done : 1'b1), // game_begin only for 1st asteroid when XLARGE.
            .game_continue(game_continue),
            .ast_type(
                // 1st asteroid can be any of 3 sizes, or XLARGE at the opening screen, if enabled
                (gi == 0) ? ((XLARGE & ~start_done) ? AST_XLARGE : asteroids_state[0] ? AST_LARGE : asteroids_state[1] ? AST_MED : AST_SMALL) :
                // 2nd one can be only medium or small
                (gi == 1) ? (asteroids_state[3] ? AST_MED : AST_SMALL) :
                // the rest can only be small
                            AST_SMALL),
            .new_asteroid(vsync &
                // asteroid 0 is created on new level and on any hit on it, until the small is hit
                (gi == 0) ? (new_level_int | asteroid_hit[0] & ~asteroids_state[2]) :
                // asteroid 1 is created on large asteroid 0 split, and on any hit on it, until the small is hit
                (gi == 1) ? (asteroid_hit[0] & asteroids_state[0] | asteroid_hit[1] & ~asteroids_state[4]) :
                // asteroid 2 is created on medium asteroid 0 split
                (gi == 2) ? (asteroid_hit[0] & asteroids_state[1]) :
                // asteroid 3 is created on medium asteroid 1 split
                            (asteroid_hit[1] & asteroids_state[4])),
            .asteroid_hit(vsync & asteroid_hit[gi]),
            //.Debug_Bus(Debug_Bus),
            .sprite_addr(sprite_addr[gi]),
            .sprite_data(sprite_data[gi])
        );
		assign asteroid_en[gi] = vga_chain_asteroid[gi+1].t.en;
        // asteroid hit by any torpedo
        assign asteroid_hit_n[gi] = asteroid_en[gi] & |torpedo_en;
    end
    // torpedo hits any of the asteroids
    for (gj = 0; gj < T_NUM; gj = gj + 1) begin : t_hit
        assign torpedo_hit[gj] = torpedo_en[gj] & |asteroid_en;
    end
endgenerate

endmodule
