// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************


module Draw_Ghost #(
	// screen size
	parameter WIDTH=640,
	parameter HEIGHT=480
) (
	
	input					clk,
	input					resetN,
	// current pixel being calculated
	input		[$clog2(WIDTH)-1:0]	pxl_x,
	input		[$clog2(HEIGHT)-1:0]	pxl_y,
	// image top, left
	input		[$clog2(WIDTH)-1:0]	topLeft_x,
	input		[$clog2(HEIGHT)-1:0]	topLeft_y,
	// image width, height
	input		[$clog2(WIDTH)-1:0]	width,
	input		[$clog2(HEIGHT)-1:0]	height,
	// offset of center from top left
	input		[$clog2(WIDTH)-1:0]	offset_x,
	input		[$clog2(HEIGHT)-1:0]	offset_y,
	input		[9:0]		theta,
	output	[3:0]		Red_level,
	output	[3:0]		Green_level,
	output	[3:0]		Blue_level,
	output				Drawing
	
	);

localparam XY_W = (WIDTH > HEIGHT) ? $clog2(WIDTH) : $clog2(HEIGHT);
wire in_rectangle;

// All calculations are done with reference to center of figure
// width , height are divided by 2 using logical right shift by 1, as they are unsigned
wire signed [$clog2(WIDTH )-1:0]center_x = topLeft_x + {1'b0, width [$clog2(WIDTH )-1:1]};
wire signed [$clog2(HEIGHT)-1:0]center_y = topLeft_y + {1'b0, height[$clog2(HEIGHT)-1:1]};

// find offset from **rotation center** of image
// by subtracting width/2 and height/2
wire signed [XY_W:0]dx = {1'b0, pxl_x} - {1'b0, center_x};
wire signed [XY_W:0]dy = {1'b0, pxl_y} - {1'b0, center_y};

// rotated x,y offset from image rotation center
wire signed [XY_W:0]dxr;
wire signed [XY_W:0]dyr;
wire t;


rot #(
	.DATA_W(XY_W+1)
) rot_inst (
	.clk(clk),
	.x(dx),
	.y(dy),
	.theta(theta),
	.rx(dxr),
	.ry(dyr)
);

// rotated point offset from top left
wire	[XY_W:0]	tl_offset_x = dxr + {{(XY_W - $clog2(WIDTH ) + 1){offset_x[$clog2(WIDTH )-1]}}, offset_x};
wire	[XY_W:0]	tl_offset_y = dyr + {{(XY_W - $clog2(HEIGHT) + 1){offset_y[$clog2(HEIGHT)-1]}}, offset_y};

wire [3:0]ghost_r;
wire [3:0]ghost_g;
wire [3:0]ghost_b;

wire [11:0] ghost_addr = {tl_offset_x[5:0], tl_offset_y[5:0]};

ghost	ghost_inst (
	.address(ghost_addr),
	.clock(clk),
	.q({ghost_r, ghost_g, ghost_b})
	);

// add to sim later
//initial
//	$readmemh("ghost.mif", ghost_inst);

	
assign in_rectangle =
	(tl_offset_x >= 0) &&    // not too left
	(tl_offset_x < width) && // not too right
	(tl_offset_y >= 0) &&    // not too high
	(tl_offset_y < height);  // not too low

localparam TANSPERENT = 12'hFFF;

always @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		Drawing <= 0;
		Red_level <= 4'hF;
		Green_level <= 4'hF;
		Blue_level <= 4'hF;
	end
	else begin
		Drawing <= 0;
		if (in_rectangle) begin
			if({ghost_r, ghost_g, ghost_b} != TANSPERENT) begin
				Drawing <= 1;
				Red_level <= ghost_r;
				Green_level <= ghost_g;
				Blue_level <= ghost_b;
			end
		end
	end
end

endmodule