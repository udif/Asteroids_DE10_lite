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
	output				h_sync,
	output				v_sync,
	vga.in		vga_chain_end,   // back from all display units
	vga.out		vga_chain_start, // start chain with only sync & pixel x/y signals
	vga.out		vga_out,         // now send to VGA connector
	output	[7:0]		lcd_db,
	output				lcd_reset,
	output				lcd_wr,
	output				lcd_d_c,
	output				lcd_rd
	);
	
// VGA controller
 vga_controller VGA_interface (
	.pixel_clk  (clk_25),
	.reset_n    (1),
    .vga_gen    (vga_chain_start)
);
	
// LCD controller
lcd_ctrl LCD_interface(
	.clk_50(0), // not used
	.clk_25(clk_25),
	.clk_100(clk_100),
	.resetN(1),
	.pxl_x(vga_chain_start.t.pxl_x),
	.pxl_y(vga_chain_start.t.pxl_y),
	.h_sync(0), // not used
	.v_sync(0), // not used
	.red_in(vga_out.t.red),
	.green_in(vga_out.t.green),
	.blue_in(vga_out.t.blue),
	.sw_0(1), // used for reset
	.lcd_db(lcd_db),
	.lcd_reset(lcd_reset),
	.lcd_wr(lcd_wr),
	.lcd_d_c(lcd_d_c),
	.lcd_rd(lcd_rd)
);

// screen out display picker / enable
assign vga_out.t.red   = (vga_chain_start.t.en == 1'b1) ? vga_chain_end.t.red   : 4'b0000 ;
assign vga_out.t.green = (vga_chain_start.t.en == 1'b1) ? vga_chain_end.t.green : 4'b0000 ;
assign vga_out.t.blue  = (vga_chain_start.t.en == 1'b1) ? vga_chain_end.t.blue  : 4'b0000 ;

// delay h/v sync as requested
generate
if (RGB_LAT == 0)
begin
	assign h_sync = vga_chain_start.t.hsync;
	assign v_sync = vga_chain_start.t.vsync;
end
else
begin
	reg [RGB_LAT-1:0]h_dly;
	reg [RGB_LAT-1:0]v_dly;
	wire [RGB_LAT:0]tmp_h = {vga_chain_start.t.hsync, h_dly};
	wire [RGB_LAT:0]tmp_v = {vga_chain_start.t.vsync, v_dly};
	always @(posedge clk_25)
	begin
		h_dly <= tmp_h[RGB_LAT:1];
		v_dly <= tmp_v[RGB_LAT:1];
	end
	assign h_sync = h_dly[0];
	assign v_sync = v_dly[0];
end
endgenerate

assign vga_out.t.hsync = h_sync;
assign vga_out.t.vsync = v_sync;

endmodule