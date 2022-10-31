// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************


module Draw_Ghost (
	
	input					clk,
	input					resetN,
	input		[31:0]	pxl_x,
	input		[31:0]	pxl_y,
	input		[31:0]	topLeft_x,
	input		[31:0]	topLeft_y,
	input		[31:0]	width,
	input		[31:0]	high,
	input					x_direction,
	output	[3:0]		Red_level,
	output	[3:0]		Green_level,
	output	[3:0]		Blue_level,
	output				Drawing
	
	);

wire	[31:0]	in_rectangle; 
wire	[31:0]	offset_x;
wire	[31:0]	offset_y;
wire  [31:0]   mirror_offset_x =  width-offset_x+1;
wire [3:0]ghost_r;
wire [3:0]ghost_g;
wire [3:0]ghost_b;

wire [11:0] ghost_addr = x_direction ? {offset_y[5:0],mirror_offset_x[5:0]} : {offset_y[5:0], offset_x[5:0]};

ghost	ghost_inst (
	.address(ghost_addr),
	.clock(clk),
	.q({ghost_r, ghost_g, ghost_b})
	);

// add to sim later
//initial
//	$readmemh("ghost.mif", ghost_inst);

	
	assign in_rectangle = (pxl_x >= topLeft_x) && (pxl_x <= topLeft_x+width) && (pxl_y >= topLeft_y) && (pxl_y <= topLeft_y+high);
assign offset_x = pxl_x - topLeft_x;
assign offset_y = pxl_y - topLeft_y;

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