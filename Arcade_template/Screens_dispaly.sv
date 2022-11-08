// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************



module Screens_dispaly # (
	parameter WIDTH=640,
	parameter HEIGHT=480,
	parameter RGB_LAT = 0
) (
	
	input					clk_25,
	input					clk_100,
	input		[3:0]		Red_level,
	input		[3:0]		Green_level,
	input		[3:0]		Blue_level,
	output	[$clog2(WIDTH )-1:0]pxl_x,
	output	[$clog2(HEIGHT)-1:0]pxl_y,
	output	[3:0]		Red,
	output	[3:0]		Green,
	output	[3:0]		Blue,
	output				h_sync,
	output				v_sync,
	output	[7:0]		lcd_db,
	output				lcd_reset,
	output				lcd_wr,
	output				lcd_d_c,
	output				lcd_rd
	);
	
	wire	[3:0]		Red_i;
	wire	[3:0]		Green_i;
	wire	[3:0]		Blue_i;
	wire				disp_ena;
	wire	[$clog2(WIDTH )-1:0]Pxl_x_i;
	wire	[$clog2(HEIGHT)-1:0]Pxl_y_i;
	
	wire h_sync_d;
	wire v_sync_d;

// VGA controller
 vga_controller VGA_interface (
	.pixel_clk  (clk_25),
   .reset_n    (1),
   .h_sync     (h_sync_d),
   .v_sync     (v_sync_d),
   .disp_ena   (disp_ena),
   .column     (Pxl_x_i),
   .row        (Pxl_y_i)
   );
	
// LCD controller
lcd_ctrl LCD_interface(
	.clk_50(0), // not used
	.clk_25(clk_25),
	.clk_100(clk_100),
	.resetN(1),
	.pxl_x(Pxl_x_i),
	.pxl_y(Pxl_y_i),
	.h_sync(0), // not used
	.v_sync(0), // not used
	.red_in(Red_i),
	.green_in(Green_i),
	.blue_in(Blue_i),
	.sw_0(1), // used for reset
	.lcd_db(lcd_db),
	.lcd_reset(lcd_reset),
	.lcd_wr(lcd_wr),
	.lcd_d_c(lcd_d_c),
	.lcd_rd(lcd_rd)
);


// screen out display picker / enable
assign Red_i = (disp_ena == 1'b1) ? Red_level : 4'b0000 ;
assign Green_i = (disp_ena == 1'b1) ? Green_level : 4'b0000 ;
assign Blue_i = (disp_ena == 1'b1) ? Blue_level : 4'b0000 ;

// outputs assigns
assign pxl_x = Pxl_x_i;
assign pxl_y = Pxl_y_i;
assign Red = Red_i;
assign Green = Green_i;
assign Blue = Blue_i;

// delay h/v sync as requested
generate
if (RGB_LAT == 0)
begin
	assign h_sync = h_sync_d;
	assign v_sync = v_sync_d;
end
else
begin
	reg [RGB_LAT-1:0]h_dly;
	reg [RGB_LAT-1:0]v_dly;
	wire [RGB_LAT:0]tmp_h = {h_sync_d, h_dly};
	wire [RGB_LAT:0]tmp_v = {v_sync_d, v_dly};
	always @(posedge clk_25)
	begin
		h_dly <= tmp_h[RGB_LAT:1];
		v_dly <= tmp_v[RGB_LAT:1];
	end
	assign h_sync = h_dly[0];
	assign v_sync = v_dly[0];
end
endgenerate
endmodule