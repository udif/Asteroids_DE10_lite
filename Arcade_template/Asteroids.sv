// Designer: Mor (Mordechai) Dahan, Avi Salmon,
// Sep. 2022
// ***********************************************

`define ENABLE_ADC_CLOCK
`define ENABLE_CLOCK1
`define ENABLE_CLOCK2
`define ENABLE_SDRAM
`define ENABLE_HEX0
`define ENABLE_HEX1
`define ENABLE_HEX2
`define ENABLE_HEX3
`define ENABLE_HEX4
`define ENABLE_HEX5
`define ENABLE_KEY
`define ENABLE_LED
`define ENABLE_SW
`define ENABLE_VGA
`define ENABLE_ACCELEROMETER
`define ENABLE_ARDUINO
`define ENABLE_GPIO

module Asteroids(

	//////////// ADC CLOCK: 3.3-V LVTTL //////////
`ifdef ENABLE_ADC_CLOCK
	input 		          		ADC_CLK_10,
`endif
	//////////// CLOCK 1: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK1
	input 		          		MAX10_CLK1_50,
`endif
	//////////// CLOCK 2: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK2
	input 		          		MAX10_CLK2_50,
`endif

	//////////// SDRAM: 3.3-V LVTTL //////////
`ifdef ENABLE_SDRAM
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,
`endif

	//////////// SEG7: 3.3-V LVTTL //////////
`ifdef ENABLE_HEX0
	output		     [7:0]		HEX0,
`endif
`ifdef ENABLE_HEX1
	output		     [7:0]		HEX1,
`endif
`ifdef ENABLE_HEX2
	output		     [7:0]		HEX2,
`endif
`ifdef ENABLE_HEX3
	output		     [7:0]		HEX3,
`endif
`ifdef ENABLE_HEX4
	output		     [7:0]		HEX4,
`endif
`ifdef ENABLE_HEX5
	output		     [7:0]		HEX5,
`endif

	//////////// KEY: 3.3 V SCHMITT TRIGGER //////////
`ifdef ENABLE_KEY
	input 		     [1:0]		KEY,
`endif

	//////////// LED: 3.3-V LVTTL //////////
`ifdef ENABLE_LED
	output		     [9:0]		LEDR,
`endif

	//////////// SW: 3.3-V LVTTL //////////
`ifdef ENABLE_SW
	input 		     [9:0]		SW,
`endif

	//////////// VGA: 3.3-V LVTTL //////////
`ifdef ENABLE_VGA
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		          		VGA_HS,
	output		     [3:0]		VGA_R,
	output		          		VGA_VS,
`endif

	//////////// Accelerometer: 3.3-V LVTTL //////////
`ifdef ENABLE_ACCELEROMETER
	output		          		GSENSOR_CS_N,
	input 		     [2:1]		GSENSOR_INT,
	output		          		GSENSOR_SCLK,
	inout 		          		GSENSOR_SDI,
	inout 		          		GSENSOR_SDO,
`endif

	//////////// Arduino: 3.3-V LVTTL //////////
`ifdef ENABLE_ARDUINO
	output 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N,
`endif

	//////////// GPIO, GPIO connect to GPIO Default: 3.3-V LVTTL //////////
`ifdef ENABLE_GPIO
	inout 		    [35:0]		GPIO
`endif
);

localparam WIDTH  = 640;
localparam HEIGHT = 480;

//=======================================================
//  REG/WIRE declarations
//=======================================================

// clock signals
wire				clk_25;
wire				clk_50;
wire				clk_100;

// Screens signals
wire	[31:0]	pxl_x;
wire	[31:0]	pxl_y;
wire	[7:0]		lcd_db;
wire				lcd_reset;
wire				lcd_wr;
wire				lcd_d_c;
wire				lcd_rd;
wire				lcd_buzzer;
wire				lcd_status_led;
wire	[3:0]		Red_level;
wire	[3:0]		Green_level;
wire	[3:0]		Blue_level;

// Periphery signals
wire	A;
wire	B;
wire	Select;
wire	Start;
wire	Right;
wire	Left;
wire	Up;
wire	Down;
wire [11:0]	Wheel;

//
// The VGA chain starts with a black screen and ends with a complete picture
//
vga vga_chain_start();
vga vga_chain_end();
vga vga_out();

// Screens Assigns
assign ARDUINO_IO[7:0]	= lcd_db;
assign ARDUINO_IO[8] 	= lcd_reset;
assign ARDUINO_IO[9]		= lcd_wr;
assign ARDUINO_IO[10]	= lcd_d_c;
assign ARDUINO_IO[11]	= lcd_rd;
assign ARDUINO_IO[12]	= lcd_buzzer;
assign ARDUINO_IO[13]	= lcd_status_led;
assign VGA_HS = vga_out.t.hsync;
assign VGA_VS = vga_out.t.vsync;
assign VGA_R  = vga_out.t.red;
assign VGA_G  = vga_out.t.green;
assign VGA_B  = vga_out.t.blue;

wire resetN = ~Start;

localparam DEBUG_SIZE=1;
//wire [DEBUG_SIZE-1:0][63:0]debug_out;

// Screens control (LCD and VGA)
Screens_dispaly #(
	// Extra 2 cycle latency since all Draw_Sprite() modules
	// Use a ROM with 2 cycle latency for RGB data
	.RGB_LAT(2)
) Screens_dispaly_inst (
	.clk_25(clk_25),
	.clk_100(clk_100),
	.Red_level(Red_level),
	.Green_level(Green_level),
	.Blue_level(Blue_level),
	.vga_chain_start(vga_chain_start),
	.vga_chain_end(vga_chain_end),
	.vga_out(vga_out),
	.lcd_db(lcd_db),
	.lcd_reset(lcd_reset),
	.lcd_wr(lcd_wr),
	.lcd_d_c(lcd_d_c),
	.lcd_rd(lcd_rd)
);

assign pxl_x = vga_chain_start.t.pxl_x;
assign pxl_y = vga_chain_start.t.pxl_y;


// Utilities

// 25M clk generation
pll25	pll25_inst (
	.areset ( 1'b0 ),
	.inclk0 ( MAX10_CLK1_50 ),
	.c0 ( clk_25 ),
	.c1 ( clk_50 ),
	.c2 ( clk_100 ),
	.locked ( )
	);


//7-Seg default assign (all leds are off)
assign HEX0 = 8'b11111111;
assign HEX1 = 8'b11111111;
assign HEX2 = 8'b11111111;
assign HEX3 = 8'b11111111;

// periphery_control module for external units: joystick, wheel and buttons (A,B, Select and Start) 
periphery_control periphery_control_inst(
	.clk(clk_25),
	.A(A),
	.B(B),
	.Select(Select),
	.Start(Start),
	.Right(Right),
	.Left(Left),
	.Up(Up),
	.Down(Down),
	.Wheel(Wheel)
	);
	
	// Leds and 7-Seg show periphery_control outputs
	assign LEDR[0] = A; 			// A
	assign LEDR[1] = B; 			// B
	assign LEDR[2] = Select;	// Select
	assign LEDR[3] = Start; 	// Start
	assign LEDR[9] = Left; 		// Left
	assign LEDR[8] = Right; 	// Right
	assign LEDR[7] = Up; 		// UP
	assign LEDR[6] = Down; 		// DOWN

	seven_segment ss5(
	.in_hex(Wheel[11:8]),
	.out_to_ss(HEX5)
);

	seven_segment ss4(
	.in_hex(Wheel[7:4]),
	.out_to_ss(HEX4)
);

//
// Shared animation pulse
// each pulse (1/5sec) increments the next frame in sprite animations
//
localparam ANIM_CNT = 12;
localparam ANIM_CNT_M1 = ANIM_CNT - 1;

reg [$clog2(ANIM_CNT)-1:0]anim_cnt;
reg anim_pulse;
reg v_sync_d;
wire v_sync_pulse = vga_chain_start.t.vsync && !v_sync_d;
always @(posedge clk_25) begin
    v_sync_d <= vga_chain_start.t.vsync;
    anim_pulse <= 1'b0;
    if (v_sync_pulse) begin
        if(anim_cnt > 0) 
            anim_cnt <= anim_cnt - {{($bits(anim_cnt)-1){1'b0}}, 1'b1};
        else begin
            anim_cnt <= ANIM_CNT_M1[$bits(anim_cnt)-1:0];
            anim_pulse <= 1'b1;
        end
    end
end

// how many torpedos at the same time
localparam T_NUM = 4;
// RGB sources
typedef enum int unsigned {
	RGB_SCORE,
	RGB_ASTEROIDS,
	RGB_GAMEOVER,
	RGB_SHIP,
	RGB_LIVES,
	RGB_TORPEDO,
	RGB_STARS = RGB_TORPEDO + T_NUM // background, must be the last one!
} RGB_SRC ;

wire [RGB_STARS:0][11:0]RGB;
wire [RGB_STARS-1:0]draw;


// Priority mux for the RGB
Drawing_priority #(
	.SIZE($bits(draw))
) drawing_mux(
	.clk(clk_25),
	.resetN(resetN),
	.RGB(RGB),
	.draw(draw),
	.RGB_bg(RGB[RGB_STARS]),
	.Red_level(Red_level),
	.Green_level(Green_level),
	.Blue_level(Blue_level)
	);

vga vga_chain_stars ( /* .clk(clk_25) */ ) ;

assign RGB[RGB_STARS][11:8] = vga_chain_stars.t.red;
assign RGB[RGB_STARS][7:4 ] = vga_chain_stars.t.green;
assign RGB[RGB_STARS][3:0]  = vga_chain_stars.t.blue;

// Starfield
Draw_Stars Draw_Stars_inst(
	.clk(clk_25),
	.resetN(resetN),
	.vga_chain_in(vga_chain_start),
	.vga_chain_out(vga_chain_stars),
	.Draw()
);

wire signed [17:0]ship_sin_val;
wire signed [17:0]ship_cos_val;

wire [$clog2(WIDTH )-1:0]ship_x;
wire [$clog2(HEIGHT)-1:0]ship_y;
wire draw_ship;

vga vga_chain_ship ( /* .clk(clk_25) */ ) ;

// ship unit
Ship_unit #(
	.DEBUG_SIZE(DEBUG_SIZE)
) ship_unit_inst(	
	.clk(clk_25),
	.resetN(resetN),
	.game_over(game_over),
	.collision(die),
	.Accelerator(B),
	.vga_chain_in(vga_chain_stars),
	.vga_chain_out(vga_chain_ship),
	.ship_x(ship_x),
	.ship_y(ship_y),
	.wheel(~Wheel), // match rotation direction
	.sin_val(ship_sin_val),
	.cos_val(ship_cos_val),
	.anim_pulse(anim_pulse),
	.Draw(draw_ship)
	//,.debug_out(debug_out)
);
assign draw[RGB_SHIP] = draw_ship & ~game_over;
assign RGB[RGB_SHIP][11:8] = vga_chain_ship.t.red;
assign RGB[RGB_SHIP][7:4]  = vga_chain_ship.t.green;
assign RGB[RGB_SHIP][3:0]  = vga_chain_ship.t.blue;

//
// Score accumulator in BCD
//
localparam SCORE_DIGITS = 6;
reg [SCORE_DIGITS-1:0][3:0]score;

score_box #(
	.DIGITS(SCORE_DIGITS)
) score_box_inst (
	.clk(clk_25),
	.resetN(resetN),
	.add((|draw[RGB_TORPEDO +: T_NUM]) & draw[RGB_SCORE]),
	.sum(1), // How much to add (use BCD!)
	.result(score)
);

//
// Score display
//
vga vga_chain_score ( /* .clk(clk_25) */ ) ;

Draw_Score #(
	.DIGITS(SCORE_DIGITS)
) score_inst(	
	.clk(clk_25),
	.vga_chain_in(vga_chain_ship),
	.vga_chain_out(vga_chain_score),
	.offsetX(10'd0),
	.offsetY(9'd0),
	.digits(score),
	.Draw(draw[RGB_SCORE])
);
//assign draw[RGB_SCORE] = draw_ship & ~game_over;
assign  RGB[RGB_SCORE][11:8] = vga_chain_score.t.red;
assign  RGB[RGB_SCORE][7:4]  = vga_chain_score.t.green;
assign  RGB[RGB_SCORE][3:0]  = vga_chain_score.t.blue;

//
// Torpedo display
//

// For the torpedo we have 3 sprite cycles
localparam ANIM_CYCLE_TORPEDO = 3;
localparam ANIM_CYCLE_TORPEDO_M1 = ANIM_CYCLE_TORPEDO - 1;
reg [$clog2(ANIM_CYCLE_TORPEDO)-1:0]anim_cycle_torpedo;
always @(posedge clk_25)
    if (anim_pulse)
        if (anim_cycle_torpedo)
            anim_cycle_torpedo <= anim_cycle_torpedo - {{($bits(anim_cycle_torpedo)-1){1'b0}}, 1'b1};
        else 
            anim_cycle_torpedo <= ANIM_CYCLE_TORPEDO_M1[$bits(anim_cycle_torpedo)-1:0];
// calculate base address in ROM of each anim frame
localparam ANIM_SIZE_TORPEDO=90;
wire [$clog2(ANIM_SIZE_TORPEDO * (ANIM_CYCLE_TORPEDO - 1))-1:0]torpedo_anim_base = ($bits(torpedo_anim_base))'(anim_cycle_torpedo * ANIM_SIZE_TORPEDO);

// How many torpedos in flight
genvar t; // torpedos

// We have multiple torpedo instances
// fire trigger is cascaded so that the next torpedo gets a fire sequence
// only if the previous torpedo is still flying
vga vga_chain_torpedos[T_NUM+1] ( /* .clk(clk_25) */ ) ;
wire [T_NUM:0]torpedos;
generate
	assign vga_chain_torpedos[0].t = vga_chain_score.t;
	assign torpedos[0] = A;
	for (t = 0; t < T_NUM ; t = t + 1) begin : tor_insts
		Torpedo_Unit torpedo_inst (
			.clk(clk_25),
			.resetN(resetN),
			.vga_chain_in(vga_chain_torpedos[t]),
			.vga_chain_out(vga_chain_torpedos[t+1]),
			.ship_x(ship_x),
			.ship_y(ship_y),
			.vsync(v_sync_pulse),
			.sin_val(ship_sin_val),
			.cos_val(ship_cos_val),
			.anim_base(torpedo_anim_base),
			.fire(torpedos[t]),
			.fire_out(torpedos[t+1]),
			.Draw(draw[RGB_TORPEDO+t])
		);
		//assign draw[RGB_TORPEDO+t] = ;
		assign  RGB[RGB_TORPEDO+t][11:8] = vga_chain_torpedos[t+1].t.red;
		assign  RGB[RGB_TORPEDO+t][7:4]  = vga_chain_torpedos[t+1].t.green;
		assign  RGB[RGB_TORPEDO+t][3:0]  = vga_chain_torpedos[t+1].t.blue;
	end
endgenerate

// How many "lives" do we have
localparam NUM_LIVES = 3;
localparam MAX_NUM_LIVES = 10;

wire bonus = (score[1:0] == (8'b0)) && (score > 0);
wire die = draw[RGB_SHIP] && draw[RGB_SCORE]; // for the time being

// "lives" counter
wire [$clog2(MAX_NUM_LIVES+1)-1:0]lives;
wire game_over;
lives_counter #(
	.NUM_LIVES(NUM_LIVES),
	.MAX_NUM_LIVES(MAX_NUM_LIVES)
) lives_counter_inst (
	.clk(clk_25),
	.resetN(resetN),
	.die(die),
	.bonus(bonus),
	.game_over(game_over),
	.lives(lives)
);

//
// "lives" display
//

// we use a single sprite but replicate it multiple times on the same line
// by dynamically changing topLeft_x
wire  [$clog2(WIDTH * HEIGHT)-1:0]spaceship_lives_addr;
wire [11:0]spaceship_lives_data;
localparam LIVES_X_OFFSET = 18*SCORE_DIGITS+10;

// distance between ship icons for # of lives display (1 << LIVES_X_SPACING_LOG2)
localparam LIVES_X_SPACING_LOG2 = 5;
// This only works because the ship sprites are spaced 32 pixels apart (1<<5)
// we deduce which "live" we plan to display by looking at the X position of the scan
wire [$clog2(MAX_NUM_LIVES+1)+LIVES_X_SPACING_LOG2-1:0]curr_life_t = ($bits(curr_life_t))'(pxl_x - LIVES_X_OFFSET);
wire [$clog2(MAX_NUM_LIVES+1)-1:0]curr_life = curr_life_t[LIVES_X_SPACING_LOG2 +: $clog2(MAX_NUM_LIVES+1)];
wire draw_life;

Draw_Sprite #(
	.WIDTH(WIDTH),
	.HEIGHT(HEIGHT),
	.TRANSPARENT(12'h0f0)
) lives_inst (
	.clk(clk_25),
	.resetN(resetN),
	.pxl_x(pxl_x),
	.pxl_y(pxl_y),
	.topLeft_x(LIVES_X_OFFSET + {curr_life, (LIVES_X_SPACING_LOG2)'(0)}),
	.topLeft_y(2),
	.width(10'd30),
	.height(9'd26),
	.offset_x(10'd15),
	.offset_y(9'd13),
	.center_x(),
	.center_y(),
	.sin_val(18'h0), // straight up, sin(90)
	.cos_val(18'h1ffff), // cos(90)
	.sprite_rd(),
	.sprite_addr(spaceship_lives_addr),
	.sprite_data(spaceship_lives_data),
	.Red_level  (RGB[RGB_LIVES][11:8]),
	.Green_level(RGB[RGB_LIVES][7:4]),
	.Blue_level (RGB[RGB_LIVES][3:0]),
	.Drawing   (draw_life)
	);
assign draw[RGB_LIVES] = draw_life && (curr_life < lives);

spaceship	spaceship_lives_inst (
	.clock(clk_25),
	.address(spaceship_lives_addr),
	.q(spaceship_lives_data)
);

//
// "Game Over" banner display
//

localparam GAMEOVER_WIDTH=277;
localparam GAMEOVER_HEIGHT=48;
localparam GAMEOVER_MASK=12'h000;
wire draw_gameover;
wire  [$clog2(WIDTH * HEIGHT)-1:0]gameover_addr;
wire [1:0]gameover_data;

Draw_Sprite #(
	.WIDTH(WIDTH),
	.HEIGHT(HEIGHT),
	.TRANSPARENT(GAMEOVER_MASK)
) gameover_inst (
	.clk(clk_25),
	.resetN(resetN),
	.pxl_x(pxl_x),
	.pxl_y(pxl_y),
	.topLeft_x((WIDTH-GAMEOVER_WIDTH)/2),
	.topLeft_y((HEIGHT-GAMEOVER_HEIGHT)/2),
	.width(GAMEOVER_WIDTH),
	.height(GAMEOVER_HEIGHT),
	.offset_x(GAMEOVER_WIDTH/2),
	.offset_y(GAMEOVER_HEIGHT/2),
	.center_x(),
	.center_y(),
	.sin_val(18'h0), // straight up, sin(90)
	.cos_val(18'h1ffff), // cos(90)
	.sprite_rd(),
	.sprite_addr(gameover_addr),
	// convert 2 bit grey level data into 12 bit RGB
	.sprite_data({3{gameover_data, 2'b0}}),
	.Red_level  (RGB[RGB_GAMEOVER][11:8]),
	.Green_level(RGB[RGB_GAMEOVER][7:4]),
	.Blue_level (RGB[RGB_GAMEOVER][3:0]),
	.Drawing   (draw_gameover)
);

assign draw[RGB_GAMEOVER] = draw_gameover && game_over;

gameover gameover_rom_inst (
	.clock(clk_25),
	.address(gameover_addr),
	.q(gameover_data)
);

//
// Opening screen
//
reg [7:0]start_cnt;
always @(posedge clk_25 or negedge resetN) begin
	if (~resetN)
		start_cnt <= '0;
    else if (v_sync_pulse) begin
        if (start_cnt != '1)
            start_cnt <= start_cnt + {{($bits(start_cnt)-1){1'b0}}, 1'b1};
    end
end

localparam ASTEROIDS_WIDTH=481;
localparam ASTEROIDS_HEIGHT=80;
localparam ASTEROIDS_MASK=12'h000;
wire draw_asteroids;
wire  [$clog2(WIDTH * HEIGHT)-1:0]asteroids_addr;
wire [8:0]asteroids_data;

Draw_Sprite #(
	.WIDTH(WIDTH),
	.HEIGHT(HEIGHT),
	.TRANSPARENT(ASTEROIDS_MASK)
) asteroids_inst (
	.clk(clk_25),
	.resetN(resetN),
	.pxl_x(pxl_x),
	.pxl_y(pxl_y),
	.topLeft_x((WIDTH-ASTEROIDS_WIDTH)/2),
	.topLeft_y((HEIGHT-ASTEROIDS_HEIGHT)/2),
	.width(ASTEROIDS_WIDTH),
	.height(ASTEROIDS_HEIGHT),
	.offset_x(ASTEROIDS_WIDTH/2),
	.offset_y(ASTEROIDS_HEIGHT/2),
	.center_x(),
	.center_y(),
	.sin_val(18'h0), // straight up, sin(90)
	.cos_val({1'b0, start_cnt, 9'h1ff}), // scaled cos(90)
	.sprite_rd(),
	.sprite_addr(asteroids_addr),
	// convert 2 bit grey level data into 12 bit RGB
	.sprite_data({asteroids_data[8:1], {4{asteroids_data[0]}}}), // RGB 4:4:1
	.Red_level  (RGB[RGB_ASTEROIDS][11:8]),
	.Green_level(RGB[RGB_ASTEROIDS][7:4]),
	.Blue_level (RGB[RGB_ASTEROIDS][3:0]),
	.Drawing   (draw_asteroids)
);

assign draw[RGB_ASTEROIDS] = draw_asteroids && (start_cnt != '1);

asteroids_start asteroids_start_inst (
	.clock(clk_25),
	.address(asteroids_addr),
	.q(asteroids_data)
);

endmodule
