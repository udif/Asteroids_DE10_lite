// LCD control
//
// Designer: Avi Salmon,
// 20/8/2022
// ***********************************************
//
// This module Captures the signals going to the VGA screen and translates in
// to the 480x800 LCD module
//
// ************************************************

// Note: The state machine is from Quartus template. ystemVerilog state machine implementation that uses enumerated types.
// Altera recommends using this coding style to describe state machines in SystemVerilog.
// In Quartus Prime integrated synthesis, the enumerated type
// that defines the states for the state machine must be
// of an unsigned integer type. If you do not specify the
// enumerated type as int unsigned, a signed int type is used by default.
// In this case, the Quartus Prime integrated synthesis synthesizes the design, but
// does not infer or optimize the logic as a state machine.


module lcd_ctrl (
	input 				clk_50,
	input 				clk_25,
	input					clk_100,
	input 				resetN,
	input 	[31:0]	pxl_x,
	input 	[31:0]	pxl_y,
	input 				h_sync,
	input 				v_sync,
	input 	[3:0]		red_in,
	input		[3:0]		green_in,
	input		[3:0]		blue_in,
	input					sw_0,

	output	[7:0]		lcd_db,
	output				lcd_reset,
	output				lcd_wr,
	output				lcd_d_c,
	output				lcd_rd
	);

reg	[25:0]	count;
wire				count_start;
wire				last_line;
wire				first_line;
wire				last_pixel;
wire				first_pixel;
wire	[10:0]	address;
wire				add_init;
wire				add_next;
wire	[7:0]		lcd_data;
wire				rgb_data_1;
wire				rgb_data_2;
wire				rgb_on;
wire				rgb_lcd_d_c;
wire				cmd_lcd_d_c;
wire				rgb_lcd_wr;
wire				cmd_lcd_wr;

assign lcd_db =
	rgb_data_1 == 1 ? {red_in[3:0], 1'b0, green_in[3:1]} :
	rgb_data_2 == 1 ? {green_in[0], 2'b0, blue_in[3:0], 1'b0} :
	                  lcd_data;

assign lcd_rd  = 1;
assign lcd_wr  = cmd_lcd_wr  | rgb_lcd_wr;
assign lcd_d_c = cmd_lcd_d_c | rgb_lcd_d_c;

// General counter

always_ff @(posedge clk_25) begin
	if (count_start == 1) begin
		count <= 0;
	end else begin
		count <= count + 1'b1;
	end
end

always_comb begin
	last_line = pxl_x == 639;
	first_line = pxl_x == 0;
	last_pixel = last_line & (pxl_y == 479);
	first_pixel = (pxl_x == 0) & (pxl_y == 0);
end

`define ONE_HOT
`ifdef ONE_HOT
`define P(x) (1 << (x))
`define W(x) (x)
`else
`define P(x) (x)
`define W(x) ($clog2(x))
`endif

typedef enum int unsigned {
	HOLD 		= `P( 0),
	CMD_1_d		= `P( 1),
	CMD_1_u		= `P( 2),
	CMD_2_d		= `P( 3),
	CMD_2_u		= `P( 4),
	DATA_1_d	= `P( 5),
	DATA_1_u	= `P( 6),
	DATA_2_d	= `P( 7),
	DATA_2_u	= `P( 8),
	DELAY_1		= `P( 9),
	IDLE		= `P(10),
//	CMD_3_d		= `P(),
//	CMD_3_u		= `P(),
//	CMD_4_d		= `P(),
//	CMD_4_u		= `P(),
	CMD_5_d		= `P(11),
	CMD_5_u		= `P(12),
	CMD_6_d		= `P(13),
	CMD_6_u		= `P(14),
	DELAY_2		= `P(15),
	RGB_CMD_1_d = `P(16),
	RGB_CMD_1_u = `P(17),
	RGB_CMD_2_d	= `P(18),
	RGB_CMD_2_u	= `P(19),
	RGB_wait	= `P(20),
	CMD_e_1_d	= `P(21),
	CMD_e_1_u	= `P(22),
	CMD_e_2_d	= `P(23),
	CMD_e_2_u	= `P(24),
	DATA_e_1_d	= `P(25),
	DATA_e_1_u	= `P(26),
	DATA_e_2_d	= `P(27),
	DATA_e_2_u	= `P(28)
} state_t;
logic [`W(state_t.num())-1:0] state, next_state;

always_comb begin
	next_state = HOLD;
	cmd_lcd_wr = 1'b1;
	count_start = 0;
	add_init = 0;
	add_next = 0;
	cmd_lcd_d_c = 0;
	lcd_reset = 1;
	rgb_on = 0;
	case(state)

		HOLD: begin
			if (sw_0 == 1) begin
				next_state = IDLE;
				add_init = 1;
				count_start = 1;
			end else begin
				next_state = HOLD;
			end
		end

		IDLE: begin
			if (count != 20000000) begin
				next_state = IDLE;
				add_init = 1;
			end else begin
				next_state = CMD_1_d;
				count_start = 1;
			end
			if (count < 128) begin
				lcd_reset = 0;
			end
		end

		CMD_1_d: begin
			//lcd_d_c = 1;
			next_state = CMD_1_u;
			add_next = 1;
			cmd_lcd_wr = 0;
		end

		CMD_1_u: begin
			//lcd_d_c = 1;
			cmd_lcd_wr = 1;
			next_state = CMD_2_d;
		end

		CMD_2_d: begin
			//lcd_d_c = 1;
			next_state = CMD_2_u;
			add_next = 1;
			cmd_lcd_wr = 0;
		end

		CMD_2_u: begin
			cmd_lcd_wr = 1;
			if (address != 11'h60E) begin
				next_state = DATA_1_d;
			end else begin
				next_state = DELAY_1;
			end
		end

		DATA_1_d: begin
			cmd_lcd_d_c = 1;
			next_state = DATA_1_u;
			add_next = 1;
			cmd_lcd_wr = 0;
		end

		DATA_1_u: begin
			cmd_lcd_d_c = 1;
			cmd_lcd_wr = 1;
			next_state = DATA_2_d;
		end

		DATA_2_d: begin
			cmd_lcd_d_c = 1;
			next_state = DATA_2_u;
			add_next = 1;
			cmd_lcd_wr = 0;
		end

		DATA_2_u: begin
			cmd_lcd_d_c = 1;
			cmd_lcd_wr = 1;
			next_state = CMD_1_d;
		end

//		CMD_3_d: begin
//			next_state = CMD_3_u;
//			add_next = 1;
//			cmd_lcd_wr = 0;
//		end

//		CMD_3_u: begin
//			cmd_lcd_wr = 1;
//			next_state = CMD_4_d;
//		end
//
//		CMD_4_d: begin
//			next_state = CMD_4_u;
//			add_next = 1;
//			cmd_lcd_wr = 0;
//		end

//		CMD_4_u: begin
//			cmd_lcd_wr = 1;
//			//add_next = 1;
//			next_state = DELAY_1;
//			count_start = 1;
//		end

		DELAY_1: begin
			//lcd_d_c = 1;
			if (count != 3000000) begin
				next_state = DELAY_1;
				cmd_lcd_d_c = 1;
				end
			else begin
				next_state = CMD_5_d;
			end
		end

		CMD_5_d: begin
			next_state = CMD_5_u;
			add_next = 1;
			cmd_lcd_wr = 0;
		end

		CMD_5_u: begin
			cmd_lcd_wr = 1;
			next_state = CMD_6_d;
		end

		CMD_6_d: begin
			next_state = CMD_6_u;
			add_next = 1;
			cmd_lcd_wr = 0;
		end

		CMD_6_u: begin
			cmd_lcd_wr = 1;
			//add_next = 1;
			next_state = DELAY_2;
			count_start = 1;
		end

		DELAY_2: begin
			cmd_lcd_d_c = 1;
			if (count != 3000000) begin
				next_state = DELAY_2;
				end
			else begin
				next_state = CMD_e_1_d;
			end
		end

		///////
		CMD_e_1_d: begin
			//lcd_d_c = 1;
			next_state = CMD_e_1_u;
			add_next = 1;
			cmd_lcd_wr = 0;
		end

		CMD_e_1_u: begin
			//lcd_d_c = 1;
			cmd_lcd_wr = 1;
			next_state = CMD_e_2_d;
		end

		CMD_e_2_d: begin
			//lcd_d_c = 1;
			next_state = CMD_e_2_u;
			add_next = 1;
			cmd_lcd_wr = 0;
		end

		CMD_e_2_u: begin
			cmd_lcd_wr = 1;
			if (address != 11'h636) begin
				next_state = DATA_e_1_d;
			end
			else begin
				next_state = RGB_wait;
			end
		end

		DATA_e_1_d: begin
			cmd_lcd_d_c = 1;
			next_state = DATA_e_1_u;
			add_next = 1;
			cmd_lcd_wr = 0;
		end

		DATA_e_1_u: begin
			cmd_lcd_d_c = 1;
			cmd_lcd_wr = 1;
			next_state = DATA_e_2_d;
		end

		DATA_e_2_d: begin
			cmd_lcd_d_c = 1;
			next_state = DATA_e_2_u;
			add_next = 1;
			cmd_lcd_wr = 0;
		end

		DATA_e_2_u: begin
			cmd_lcd_d_c = 1;
			cmd_lcd_wr = 1;
			next_state = CMD_e_1_d;
		end
		///////
		RGB_CMD_1_d: begin
			next_state = RGB_CMD_1_u;
			add_next = 1;
			cmd_lcd_wr = 0;
		end

		RGB_CMD_1_u: begin
			cmd_lcd_wr = 1;
			next_state = RGB_CMD_2_d;
		end

		RGB_CMD_2_d: begin
			next_state = RGB_CMD_2_u;
			cmd_lcd_wr = 0;
			//add_next = 1;
		end

		RGB_CMD_2_u: begin
			cmd_lcd_wr = 1;
			next_state = RGB_wait;
		end

		RGB_wait: begin
			next_state = RGB_wait;
			//count_start = 1;
			rgb_on = 1;
			cmd_lcd_wr = 0;
		end

		default:
			begin
				next_state = HOLD;
			end
	endcase
end

always_ff @(posedge clk_25) begin
	state <= next_state;
end

// Memory with commands to the LCD.

lcd_cmd lcd_cmd_inst(
	.address(address),
	.clock(clk_25),
	.q(lcd_data[7:0])
	);

// address counter
always_ff @(posedge clk_25)
	begin
		if (add_init) begin
			address <= 0;
		end
		if (add_next) begin
		address <= address + 1'b1;
		end
	end

// RGB state machine

typedef enum int unsigned {
	RGB_IDLE            = `P( 0),
	RGB_WAIT_START      = `P( 1),
	RGB_DATA_1_d        = `P( 2),
	RGB_DATA_1_u        = `P( 3),
	RGB_DATA_2_d        = `P( 4),
	RGB_DATA_2_u        = `P( 5),
	RGB_WAIT_NEXT_LINE  = `P( 6),
	STUCK               = `P( 7),
	RGB_WAIT_NEXT_FRAME = `P( 8)
} rgb_states_t;
logic [`W(rgb_states_t.num())-1:0]rgb_state, rgb_next_state;

always_comb begin
	rgb_next_state = RGB_IDLE;
	rgb_data_1 = 0;
	rgb_data_2 = 0;
	rgb_lcd_wr = 1;
	rgb_lcd_d_c = 0;
	case(rgb_state)
		RGB_IDLE: begin
			if (rgb_on == 1) begin
				rgb_next_state = RGB_WAIT_START;
				rgb_lcd_wr = 1;
			end else begin
				rgb_next_state = RGB_IDLE;
				rgb_lcd_wr = 0;
			end
		end

		RGB_WAIT_START: begin
			if (first_pixel) begin
				rgb_lcd_d_c = 1;
				rgb_next_state = RGB_DATA_1_u;
				rgb_data_1 = 1;
				rgb_lcd_wr = 0;
			end else begin
				rgb_next_state = RGB_WAIT_START;
				rgb_lcd_wr = 1;
			end
		end

		RGB_DATA_1_d: begin
			rgb_lcd_d_c = 1;
			rgb_next_state = RGB_DATA_1_u;
			rgb_data_1 = 1;
			rgb_lcd_wr = 0;
			//add_next = 1;
		end

		RGB_DATA_1_u: begin
			rgb_lcd_d_c = 1;
			rgb_lcd_wr = 1;
			rgb_data_1 = 1;
			rgb_next_state = RGB_DATA_2_d;
		end

		RGB_DATA_2_d: begin
			rgb_lcd_d_c = 1;
			rgb_next_state = RGB_DATA_2_u;
			rgb_data_2 = 1;
			rgb_lcd_wr = 0;
			//add_next = 1;
		end

		RGB_DATA_2_u: begin
			rgb_lcd_d_c = 1;
			rgb_lcd_wr = 1;
			rgb_data_2 = 1;
			if (last_pixel) begin
				rgb_next_state = RGB_WAIT_NEXT_FRAME;
			end else if (last_line == 1) begin
				rgb_next_state = RGB_WAIT_NEXT_LINE;
			end else begin
				rgb_next_state = RGB_DATA_1_d;
			end
		end

		RGB_WAIT_NEXT_LINE: begin
			rgb_lcd_d_c = 1;
			rgb_data_1 = 1;
			if (first_line == 1) begin
				rgb_next_state = RGB_DATA_1_u;
				rgb_lcd_wr = 0;
			end else begin
				rgb_next_state = RGB_WAIT_NEXT_LINE;
			end
		end

		RGB_WAIT_NEXT_FRAME: begin
			rgb_lcd_d_c = 1;
			rgb_data_1 = 1;
			if (first_pixel) begin
				rgb_next_state = RGB_DATA_1_u;
				rgb_lcd_wr = 0;
			end else begin
				rgb_next_state = RGB_WAIT_NEXT_FRAME;
			end
		end

		STUCK:
			rgb_next_state = STUCK;

		default:  begin
			rgb_next_state = RGB_IDLE;
		end

	endcase
end

always_ff @(posedge clk_100) begin
	rgb_state <= rgb_next_state;
end
endmodule
