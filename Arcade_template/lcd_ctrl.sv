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
wire	[8:0]		count_25;
wire				last_line;
wire				first_line;
wire				last_pixle;
wire				first_pixle;
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



assign lcd_db = rgb_data_1 == 1? { red_in[3:0], 1'b0, green_in[3:1]}: 
					 rgb_data_2 == 1? { green_in[0], 2'b0, blue_in[3:0], 1'b0}:
					 lcd_data;
					 
assign lcd_rd = 1;
assign lcd_wr = rgb_lcd_wr | cmd_lcd_wr;
assign lcd_d_c = cmd_lcd_d_c | rgb_lcd_d_c;
	
// General counter

always_ff @(posedge clk_25) begin
	if (count_start == 1) 
		begin
			count <= 0;
		end
	else
		begin
			count <= count + 1;
		end
end


always_comb begin
	count_25 = count[10:2];
	last_line = pxl_x == 639;
	first_line = pxl_x == 0;
	last_pixle = last_line & (pxl_y == 479);
	first_pixle = (pxl_x == 0) & (pxl_y == 0);
end
	
typedef enum { 
	HOLD,
	CMD_1_d,
	CMD_1_u,
	CMD_2_d,
	CMD_2_u,
	DATA_1_d,
	DATA_1_u,
	DATA_2_d,
	DATA_2_u,
	DELAY_1,
	IDLE,
//	CMD_3_d,
//	CMD_3_u,
//	CMD_4_d,
//	CMD_4_u,
	CMD_5_d,
	CMD_5_u,
	CMD_6_d,
	CMD_6_u,
	DELAY_2,
	RGB_CMD_1_d,
	RGB_CMD_1_u,
	RGB_CMD_2_d,
	RGB_CMD_2_u,
	RGB_wait,
	CMD_e_1_d,
	CMD_e_1_u,
	CMD_e_2_d,
	CMD_e_2_u,
	DATA_e_1_d,
	DATA_e_1_u,
	DATA_e_2_d,
	DATA_e_2_u
} state_t;
logic [state_t.num()-1:0] state, next_state;
	
always_comb 
	begin
		next_state = '0;
		cmd_lcd_wr = 1'b1;
		count_start = 0;
		add_init = 0;
		add_next = 0;
		cmd_lcd_d_c = 0;
		lcd_reset = 1;
		rgb_on = 0;
		case(state)
			
			1<<HOLD: begin
						if (sw_0 == 1) begin
							next_state[IDLE] = 1'b1;
							add_init = 1;
							count_start = 1;
							end
						else begin
							next_state[HOLD] = 1'b1;
							
						end
					end
			
			1<<IDLE: begin
						if (count != 20000000) begin
							next_state[IDLE] = 1'b1;
							add_init = 1;
							end
						else begin
							next_state[CMD_1_d] = 1'b1;
							count_start = 1;
						end
						if (count < 128) begin
							lcd_reset = 0;
						end
					end
			
			1<<CMD_1_d: begin
							//lcd_d_c = 1;
							next_state[CMD_1_u] = 1'b1;
							add_next = 1;
							cmd_lcd_wr = 0;
						end
						
			1<<CMD_1_u: begin
							//lcd_d_c = 1;
							cmd_lcd_wr = 1;
							
							next_state[CMD_2_d] = 1'b1;
						end
			
			1<<CMD_2_d: begin			
							//lcd_d_c = 1;
							next_state[CMD_2_u] = 1'b1;
							add_next = 1;
							cmd_lcd_wr = 0;
						end
			
			1<<CMD_2_u: begin
			
							cmd_lcd_wr = 1;	
							if (address != 11'h60E) begin
								next_state[DATA_1_d] = 1'b1;
							end
							else begin
								next_state[DELAY_1] = 1'b1;
								
								
							end
						 end
						 
			
			1<<DATA_1_d: begin
							cmd_lcd_d_c = 1;
							next_state[DATA_1_u] = 1'b1;
							add_next = 1;
							cmd_lcd_wr = 0;
						end
						
			1<<DATA_1_u: begin
							
							cmd_lcd_d_c = 1;
							cmd_lcd_wr = 1;
							
							next_state[DATA_2_d] = 1'b1;
						end
			
			1<<DATA_2_d: begin
							cmd_lcd_d_c = 1;
							next_state[DATA_2_u] = 1'b1;
							add_next = 1;
							cmd_lcd_wr = 0;
						end
			
			1<<DATA_2_u: begin
							cmd_lcd_d_c = 1;
							cmd_lcd_wr = 1;	
							
							next_state[CMD_1_d] = 1'b1;

						 end
						 
			
			
//			1<<CMD_3_d: begin
//							next_state[CMD_3_u] = 1'b1;
//							add_next = 1;
//							cmd_lcd_wr = 0;
//						 end
						 
//			1<<CMD_3_u: begin
//							cmd_lcd_wr = 1;
//							
//							next_state[CMD_4_d] = 1'b1;
//						 end
//						 
//			1<<CMD_4_d: begin
//							next_state[CMD_4_u] = 1'b1;
//							add_next = 1;
//							cmd_lcd_wr = 0;
//						 end
//						 
//			1<<CMD_4_u: begin
//							cmd_lcd_wr = 1;
//							//add_next = 1;
//							next_state[DELAY_1] = 1'b1;
//							count_start = 1;
//						 end
						 
						 
			
			1<<DELAY_1: begin
							//lcd_d_c = 1;
							if (count != 3000000) begin
								next_state[DELAY_1] = 1'b1;
								cmd_lcd_d_c = 1;
								end
							else begin
								next_state[CMD_5_d] = 1'b1;
								
							end
						end
			1<<CMD_5_d: begin
							next_state[CMD_5_u] = 1'b1;
							add_next = 1;
							cmd_lcd_wr = 0;
						 end
						 
			1<<CMD_5_u: begin
							cmd_lcd_wr = 1;
							
							next_state[CMD_6_d] = 1'b1;
						 end
						 
			1<<CMD_6_d: begin
							next_state[CMD_6_u] = 1'b1;
							add_next = 1;
							cmd_lcd_wr = 0;
						 end
						 
			1<<CMD_6_u: begin
							cmd_lcd_wr = 1;
							//add_next = 1;
							next_state[DELAY_2] = 1'b1;
							count_start = 1;
						 end
			
			1<<DELAY_2: begin
							cmd_lcd_d_c = 1;
							if (count != 3000000) begin
								next_state[DELAY_2] = 1'b1;
								end
							else begin
								next_state[CMD_e_1_d] = 1'b1;
								
							end
						end	
						
			///////
			1<<CMD_e_1_d: begin
							//lcd_d_c = 1;
							next_state[CMD_e_1_u] = 1'b1;
							add_next = 1;
							cmd_lcd_wr = 0;
						end
						
			1<<CMD_e_1_u: begin
							//lcd_d_c = 1;
							cmd_lcd_wr = 1;
							
							next_state[CMD_e_2_d] = 1'b1;
						end
			
			1<<CMD_e_2_d: begin			
							//lcd_d_c = 1;
							next_state[CMD_e_2_u] = 1'b1;
							add_next = 1;
							cmd_lcd_wr = 0;
						end
			
			1<<CMD_e_2_u: begin
			
							cmd_lcd_wr = 1;	
							if (address != 11'h636) begin
								next_state[DATA_e_1_d] = 1'b1;
							end
							else begin
								next_state[RGB_wait] = 1'b1;
								
								
							end
						 end
						 
			
			1<<DATA_e_1_d: begin
							cmd_lcd_d_c = 1;
							next_state[DATA_e_1_u] = 1'b1;
							add_next = 1;
							cmd_lcd_wr = 0;
						end
						
			1<<DATA_e_1_u: begin
							
							cmd_lcd_d_c = 1;
							cmd_lcd_wr = 1;
							
							next_state[DATA_e_2_d] = 1'b1;
						end
			
			1<<DATA_e_2_d: begin
							cmd_lcd_d_c = 1;
							next_state[DATA_e_2_u] = 1'b1;
							add_next = 1;
							cmd_lcd_wr = 0;
						end
			
			1<<DATA_e_2_u: begin
							cmd_lcd_d_c = 1;
							cmd_lcd_wr = 1;	
							
							next_state[CMD_e_1_d] = 1'b1;

						 end
			
			///////
				
			1<<RGB_CMD_1_d: begin
								next_state[RGB_CMD_1_u] = 1'b1;
								add_next = 1;
								cmd_lcd_wr = 0;
							end
						
			1<<RGB_CMD_1_u: begin
								cmd_lcd_wr = 1;
								next_state[RGB_CMD_2_d] = 1'b1;
							end
			
			1<<RGB_CMD_2_d: begin			
								next_state[RGB_CMD_2_u] = 1'b1;
								cmd_lcd_wr = 0;
								//add_next = 1;
							end
			
			1<<RGB_CMD_2_u: begin
			
							cmd_lcd_wr = 1;	
							next_state[RGB_wait] = 1'b1;
						 end		
			
			
			1<<RGB_wait: begin
							next_state[RGB_wait] = 1'b1;
							//count_start = 1;
							rgb_on = 1;
							cmd_lcd_wr = 0;
						 end
						 
			default: 
				begin
					next_state[HOLD] = 1'b1;
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
		if (add_init == 1) begin
			address <= 0;
		end
		if (add_next == 1) begin
		address <= address + 1;
		end
	end
	

// RGB state machine

enum int unsigned { 
	RGB_IDLE 		= 0, 
	RGB_WAIT_START	= 2,
	RGB_DATA_1_d	= 4,
	RGB_DATA_1_u	= 8,
	RGB_DATA_2_d	= 16,
	RGB_DATA_2_u	= 32,
	RGB_WAIT_NEXT_LINE = 64,
	STUCK					= 128,
	RGB_WAIT_NEXT_FRAME = 256
	} rgb_state, rgb_next_state;
	
always_comb 
	begin
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
							end
							else begin
									rgb_next_state = RGB_IDLE;
									rgb_lcd_wr = 0;
								end
							end
					
			RGB_WAIT_START: begin
									
									if (first_pixle == 1) begin
										rgb_lcd_d_c = 1;
										rgb_next_state = RGB_DATA_1_u;
										rgb_data_1 = 1;
										rgb_lcd_wr = 0;
									end
									else begin
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
								
								
							
								if (last_line == 1) begin
									rgb_next_state = RGB_WAIT_NEXT_LINE;
								end
								else begin
									rgb_next_state = RGB_DATA_1_d;
								end
								
								if (last_pixle == 1) begin
									rgb_next_state = RGB_WAIT_NEXT_FRAME;
								end
								
							end
	
			RGB_WAIT_NEXT_LINE: begin
										rgb_lcd_d_c = 1;
										rgb_data_1 = 1;
										if (first_line == 1) begin
												rgb_next_state = RGB_DATA_1_u;
												rgb_lcd_wr = 0;
											end
										else begin
												rgb_next_state = RGB_WAIT_NEXT_LINE;
											end
										end
										
			RGB_WAIT_NEXT_FRAME: begin
										rgb_lcd_d_c = 1;
										rgb_data_1 = 1;
										if (first_pixle == 1) begin
												rgb_next_state = RGB_DATA_1_u;
												rgb_lcd_wr = 0;
											end
										else begin
												rgb_next_state = RGB_WAIT_NEXT_FRAME;
											end
										end
										
			STUCK: rgb_next_state = STUCK;
			
			default: 
				begin
					rgb_next_state = RGB_IDLE;
				end
				
		endcase
	end
	
always_ff @(posedge clk_100) begin
		rgb_state <= rgb_next_state;
	end	


										
										
endmodule
