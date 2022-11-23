// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************


module Draw_Intel (
	
	input					clk,
	input					resetN,
	input		[31:0]	pxl_x,
	input		[31:0]	pxl_y,
	input		[31:0]	topLeft_x,
	input		[31:0]	topLeft_y,
	input		[31:0]	width,
	input		[31:0]	high,
	output	[3:0]		Red_level,
	output	[3:0]		Green_level,
	output	[3:0]		Blue_level,
	output				Drawing
	
	);

wire	[31:0]	in_rectangle; 
wire	[31:0]	offset_x;
wire	[31:0]	offset_y;
wire [3:0]intel_r;
wire [3:0]intel_g;
wire [3:0]intel_b;

wire [12:0] intel_addr = {offset_y[5:0], offset_x[6:0]};

intel	intel_inst (
	.address(intel_addr),
	.clock(clk),
	.q({intel_r, intel_g, intel_b})
	);

	
assign in_rectangle = (pxl_x >= topLeft_x) && (pxl_x < topLeft_x+width) && (pxl_y >= topLeft_y) && (pxl_y < topLeft_y+high);
assign offset_x = pxl_x - topLeft_x;
assign offset_y = pxl_y - topLeft_y;

localparam TANSPERENT = 12'hFFF;

always @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		Red_level <= 4'hF;
		Green_level <= 4'hF;
		Blue_level <= 4'hF;
		Drawing <= 0;
	end
	else begin
		Drawing <= 0;
		if (in_rectangle) begin
			if({intel_r, intel_g, intel_b} != TANSPERENT) begin
				Drawing <= 1;
				Red_level <= intel_r;
				Green_level <= intel_g;
				Blue_level <= intel_b;
			end
		end
	end
end

endmodule