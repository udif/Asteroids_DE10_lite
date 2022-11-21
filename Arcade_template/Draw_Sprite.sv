// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************


module Draw_Sprite #(
	// screen size
	parameter WIDTH=640,
	parameter HEIGHT=480,
	parameter TRANSPARENT=12'h000,
	parameter SINCOS_FRACTION=17
) (
	
	input clk,
	input resetN,
	// current pixel being calculated
	input [$clog2(WIDTH )-1:0]pxl_x,
	input [$clog2(HEIGHT)-1:0]pxl_y,
	// sprite top, left
	input [$clog2(WIDTH )-1:0]topLeft_x,
	input [$clog2(HEIGHT)-1:0]topLeft_y,
	// sprite width, height
	input [$clog2(WIDTH )-1:0]width,
	input [$clog2(HEIGHT)-1:0]height,
	// offset of center from top left
	input [$clog2(WIDTH )-1:0]offset_x,
	input [$clog2(HEIGHT)-1:0]offset_y,
	// center of sprite, if needed
	output [$clog2(WIDTH )-1:0]center_x,
	output [$clog2(HEIGHT)-1:0]center_y,
	// rotation angle, already encoded with sin/cos values
	input signed [17:0]sin_val,
	input signed [17:0]cos_val,
	// ROM interface
	output sprite_rd,
	output [$clog2(WIDTH * HEIGHT)-1:0]sprite_addr,
	input [11:0]sprite_data,
	// RGB output and enable
	output reg [3:0]Red_level,
	output reg [3:0]Green_level,
	output reg [3:0]Blue_level,
	output reg      Drawing
	
	);

localparam X_W = $clog2(WIDTH);
localparam Y_W = $clog2(HEIGHT);
localparam XY_W = (WIDTH > HEIGHT) ? X_W : Y_W;

wire in_rectangle;

// All calculations are done with reference to center of figure
// width , height are divided by 2 using logical right shift by 1, as they are unsigned
assign center_x = topLeft_x + offset_x;
assign center_y = topLeft_y + offset_y;

// find offset from **rotation center** of sprite
// by subtracting width/2 and height/2
wire signed [XY_W:0]dx = {1'b0, pxl_x} - {1'b0, center_x};
wire signed [XY_W:0]dy = {1'b0, pxl_y} - {1'b0, center_y};

// rotated x,y offset from sprite rotation center
wire signed [XY_W:0]dxr;
wire signed [XY_W:0]dyr;
wire t;


rot_sin_cos #(
	.DATA_W(XY_W+1)
) rot_sin_cos_inst (
	.x(dx),
	.y(dy),
	.sin_val(sin_val),
	.cos_val(cos_val),
	.rx(dxr),
	.ry(dyr)
);

// rotated point offset from top left
wire signed [XY_W:0]tl_dxr = dxr + {{(XY_W - $clog2(WIDTH ) + 1){offset_x[$clog2(WIDTH )-1]}}, offset_x};
wire signed [XY_W:0]tl_dyr = dyr + {{(XY_W - $clog2(HEIGHT) + 1){offset_y[$clog2(HEIGHT)-1]}}, offset_y};

wire [3:0]sprite_r;
wire [3:0]sprite_g;
wire [3:0]sprite_b;

assign sprite_addr = tl_dyr * width + tl_dxr;
assign {sprite_r, sprite_g, sprite_b} = sprite_data;

assign in_rectangle =
	(tl_dxr >= 0) &&    // not too left
	(tl_dxr < width) && // not too right
	(tl_dyr >= 0) &&    // not too high
	(tl_dyr < height);  // not too low

reg in_rectangle_d, in_rectangle_d2;
assign sprite_rd = in_rectangle;

always @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		Drawing <= 0;
		Red_level <= 4'hF;
		Green_level <= 4'hF;
		Blue_level <= 4'hF;
	end
	else begin
		Drawing <= 0;
		// delay by 2 cycles to match ROM latency
		in_rectangle_d <= in_rectangle;
		in_rectangle_d2 <= in_rectangle_d;
		if (in_rectangle_d2) begin
			if ({sprite_r, sprite_g, sprite_b} != TRANSPARENT) begin
				Drawing <= 1;
				Red_level <= sprite_r;
				Green_level <= sprite_g;
				Blue_level <= sprite_b;
			end
		end
	end
end

endmodule