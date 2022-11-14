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

module Top_template(

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
wire				h_sync_wire;
wire				v_sync_wire;
wire	[3:0]		vga_r_wire;
wire	[3:0]		vga_g_wire;
wire	[3:0]		vga_b_wire;
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


// Screens Assigns
assign ARDUINO_IO[7:0]	= lcd_db;
assign ARDUINO_IO[8] 	= lcd_reset;
assign ARDUINO_IO[9]		= lcd_wr;
assign ARDUINO_IO[10]	= lcd_d_c;
assign ARDUINO_IO[11]	= lcd_rd;
assign ARDUINO_IO[12]	= lcd_buzzer;
assign ARDUINO_IO[13]	= lcd_status_led;
assign VGA_HS = h_sync_wire;
assign VGA_VS = v_sync_wire;
assign VGA_R = vga_r_wire;
assign VGA_G = vga_g_wire;
assign VGA_B = vga_b_wire;

wire resetN = ~Select;


// Screens control (LCD and VGA)
Screens_dispaly #(
	.RGB_LAT(2)
) Screen_control(
	.clk_25(clk_25),
	.clk_100(clk_100),
	.Red_level(Red_level),
	.Green_level(Green_level),
	.Blue_level(Blue_level),
	.pxl_x(pxl_x),
	.pxl_y(pxl_y),
	.Red(vga_r_wire),
	.Green(vga_g_wire),
	.Blue(vga_b_wire),
	.h_sync(h_sync_wire),
	.v_sync(v_sync_wire),
	.lcd_db(lcd_db),
	.lcd_reset(lcd_reset),
	.lcd_wr(lcd_wr),
	.lcd_d_c(lcd_d_c),
	.lcd_rd(lcd_rd)
);


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
reg v_sync_wire_d;
always @(posedge clk_25) begin
    v_sync_wire_d <= v_sync_wire;
    anim_pulse <= 1'b0;
    if (v_sync_wire && !v_sync_wire_d) begin
        if(anim_cnt > 0) 
            anim_cnt <= anim_cnt - {{($bits(anim_cnt)-1){1'b0}}, 1'b1};
        else begin
            anim_cnt <= ANIM_CNT_M1[$bits(anim_cnt)-1:0];
            anim_pulse <= 1'b1;
        end
    end
end

// we have 3 sprite cycles
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
wire [$clog2(ANIM_SIZE_TORPEDO * (ANIM_CYCLE_TORPEDO - 1))-1:0]anim_base =
    (anim_cycle_torpedo == 2) ? (2 * ANIM_SIZE_TORPEDO) :
    (anim_cycle_torpedo == 1) ? (1 * ANIM_SIZE_TORPEDO) :
                                 0;

localparam DEBUG_SIZE=1;

//wire [DEBUG_SIZE-1:0][63:0]debug_out;
localparam SCORE_DIGITS = 6;
reg [SCORE_DIGITS-1:0][3:0]score;
reg [SCORE_DIGITS-1:0][3:0]score_out;

// RGB sources
typedef enum int unsigned {
	RGB_SCORE,
	RGB_SHIP,
	RGB_TORPEDO,
	RGB_STARS // background, must be the last one!
} RGB_SRC ;

// how many torpedos at the same time
localparam T_NUM = 4;

wire [RGB_STARS+T_NUM-1:0][11:0]RGB;
wire [RGB_STARS+T_NUM-2:0]draw;


// Priority mux for the RGB
Drawing_priority #(
	.SIZE($bits(draw))
) drawing_mux(
	.clk(clk_25),
	.resetN(resetN),
	.RGB(RGB),
	.draw(draw),
	.RGB_bg(RGB[RGB_STARS+T_NUM-1]),
	.Red_level(Red_level),
	.Green_level(Green_level),
	.Blue_level(Blue_level)
	);
	
// Starfield
Draw_Stars Draw_Stars_inst(
	.clk(clk_25),
	.resetN(resetN),
	.pxl_x(pxl_x),
	.pxl_y(pxl_y),
	.Red  (RGB[RGB_STARS+T_NUM-1][11:8]),
	.Green(RGB[RGB_STARS+T_NUM-1][7:4]),
	.Blue (RGB[RGB_STARS+T_NUM-1][3:0]),
	.Draw()
	);

wire signed [17:0]sin_val;
wire signed [17:0]cos_val;

wire [$clog2(WIDTH )-1:0]ship_x;
wire [$clog2(HEIGHT)-1:0]ship_y;

// ship unit
Ship_unit #(
	.DEBUG_SIZE(DEBUG_SIZE)
) ship_unit_inst(	
	.clk(clk_25),
	.resetN(resetN),
	.collision(1'b0),
	.B(B),
	.pxl_x(pxl_x),
	.pxl_y(pxl_y),
	.ship_x(ship_x),
	.ship_y(ship_y),
	.wheel(~Wheel), // match rotation direction
	.sin_val(sin_val),
	.cos_val(cos_val),
	.anim_pulse(anim_pulse),
	.Red  (RGB[RGB_SHIP][11:8]),
	.Green(RGB[RGB_SHIP][7:4]),
	.Blue (RGB[RGB_SHIP][3:0]),
	.Draw(draw[RGB_SHIP])
	//,.debug_out(debug_out)
);

score_box #(
	.DIGITS(SCORE_DIGITS)
) score_box_inst (
	.clk(clk_25),
	.resetN(resetN),
	.add(|draw[RGB_TORPEDO +: T_NUM] & draw[RGB_SCORE]),
	.sum(1),
	.result(score)
);

genvar g;
// ship unit
Draw_Score #(
	.DIGITS(SCORE_DIGITS)
) score_inst(	
	.clk(clk_25),
	.pxl_x(pxl_x),
	.pxl_y(pxl_y),
	.offsetX(10'd0),
	.offsetY(g*40),
	.digits(score),
	.Red  (RGB[RGB_SCORE][11:8]),
	.Green(RGB[RGB_SCORE][7:4]),
	.Blue (RGB[RGB_SCORE][3:0]),
	.Draw(draw[RGB_SCORE])
);

// How many torpedos in flight
genvar t;

// We have multiple torpedo instances
// fire trigger is cascaded so that the next torpedo gets a fire sequence
// only if the previous torpedo is still flying
generate
	wire [T_NUM:0]torpedos;
	assign torpedos[0] = A;
	for (t = 0; t < T_NUM ; t = t + 1) begin : tor_insts
		Torpedo_Unit torpedo_inst (
			.clk(clk_25),
			.pxl_x(pxl_x),
			.pxl_y(pxl_y),
			.ship_x(ship_x),
			.ship_y(ship_y),
			.resetN(resetN),
			.vsync(v_sync_wire && !v_sync_wire_d),
			.sin_val(sin_val),
			.cos_val(cos_val),
			.anim_base(anim_base),
			.fire(torpedos[t]),
			.fire_out(torpedos[t+1]),
			.Red  (RGB[RGB_TORPEDO+t][11:8]),
			.Green(RGB[RGB_TORPEDO+t][7:4]),
			.Blue (RGB[RGB_TORPEDO+t][3:0]),
			.Draw(draw[RGB_TORPEDO+t])
		);
	end
endgenerate
endmodule
