// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************

module Drawing_priority #(
	parameter SIZE=1
)(
	
	input clk,
	input resetN,
	input [SIZE-1:0][11:0]RGB,
	input [SIZE-1:0]draw,
	input [11:0]RGB_bg,
	output [3:0]Red_level,
	output [3:0]Green_level,
	output [3:0]Blue_level
	);
integer i;
always @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		Red_level <= 4'hF;
		Green_level <= 4'hF;
		Blue_level <= 4'hF;
	end
	else begin
		Red_level <= RGB_bg[11:8];
		Green_level <= RGB_bg[7:4];
		Blue_level <= RGB_bg[3:0];
		for (i = SIZE-1; i >= 0; i = i - 1) begin
			if (draw[i]) begin
				Red_level <= RGB[i][11:8];
				Green_level <= RGB[i][7:4];
				Blue_level <= RGB[i][3:0];
			end
		end
	end
end
	
endmodule