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
    input game_over,
    input  new_level,
    input  [T_NUM-1:0]torpedo_en,
    output [T_NUM-1:0]torpedo_hit,
    output [3:0]asteroid_en,
    output [8:0]ast_points,
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

// update points
// we take advantage of the raster scan. only 1 asteroid can be hit on each cycle
always_ff @(posedge clk) begin
    // only 1st asteroid can be large
    if (asteroids_state[0] & ~asteroids_state_n[0])
        ast_points <= ($bits(ast_points))'(9'h20); // 20 points coded in BCD is 20'h20
    // only 1st and 2nd asteroids can be medium
    else if (asteroids_state[1] & ~asteroids_state_n[1] | asteroids_state[3] & ~asteroids_state_n[3])
        ast_points <= ($bits(ast_points))'(9'h50); // 50 points coded in BCD is 20'h50
    else if (asteroids_state[2] & ~asteroids_state_n[2] | |(asteroids_state[6:4] & ~asteroids_state_n[6:4]))
        ast_points <= ($bits(ast_points))'(9'h100); // 50 points coded in BCD is 20'h50
    else
        ast_points <= ($bits(ast_points))'(9'h000); // no hits
end

// intenal new level also occures when all asteroids have been blown up
wire new_level_int = new_level | ~|asteroids_state;

//
// asteroids state machine
// control the lifecycle of a large asteroids that splits into two medium asteroids when hit,
// and each of them split into 2 small asteroids when they are hit
// we use dual states to do all updates only at the end of the frame
//
always_ff @(posedge clk) begin
    if (new_level_int) begin
        asteroids_state[6:0]   <= 7'b0_0_00_001;
        asteroids_state_n[6:0] <= 7'b0_0_00_001;
    end
    if (vsync)
        asteroids_state <= asteroids_state_n;
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

wire [$clog2(WIDTH )-1:0]asteroid_x_init = lfsr64out[50 +: $clog2(WIDTH)];
wire [$clog2(HEIGHT)-1:0]asteroid_y_init = lfsr64out[40 +: $clog2(HEIGHT)]; // reuse bits, but not in same position
logic [3:0][$clog2(WIDTH )-1:0]asteroid_x_out;
logic [3:0][$clog2(HEIGHT)-1:0]asteroid_y_out;

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
generate
    for (gi = 0; gi < 4; gi = gi + 1) begin : asteroids
        Asteroid_unit #(
            .XLARGE((gi >= 2) ? 0 : 1), // only 1st can do XLARGE, but memory is shared with 1
            .WIDTH(WIDTH),
            .HEIGHT(HEIGHT)
        ) asteroid_unit_inst (
            .clk(clk),
            .resetN(resetN),
            // the only random asteroid is the 1st one
            .asteroid_x_init(((gi == 0) && new_level_int) ? asteroid_x_init : asteroid_x_out[gi]),
            .asteroid_y_init(((gi == 0) && new_level_int) ? asteroid_y_init : asteroid_y_out[gi]),
            .asteroid_x_out(asteroid_x_out[gi]),
            .asteroid_y_out(asteroid_y_out[gi]),
            .phase_n(lfsr64out[16+gi*10 +: 10]),
            .phase_inc_n(lfsr64out[gi*4 +: 4]),
            .vga_chain_in(vga_chain_asteroid[gi]),
            .vga_chain_out(vga_chain_asteroid[gi+1]),
            .vsync(vsync),
            .draw_mask(!game_over && asteroid_on[gi] && ((XLARGE == 1) || start_done)), // if XLARGE allow sprite on start
            .start_done(((gi == 0) && XLARGE) ? start_done : 1'b1), // start_done only for 1st asteroid when XLARGE.
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
