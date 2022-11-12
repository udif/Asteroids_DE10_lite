// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************


module Draw_Stars #(
	parameter WIDTH=640,
	parameter HEIGHT=480
) (
	
	input           clk,
	input           resetN,
	input [$clog2(WIDTH )-1:0]pxl_x,
	input [$clog2(HEIGHT)-1:0]pxl_y,
	output reg [3:0]Red,
	output reg [3:0]Green,
	output reg [3:0]Blue,
	output          Draw
	
	);

localparam LFSR = 32'h481;
wire [$clog2(LFSR)-2:0]lfsr;

lfsr #(
    .LFSR(32'h481)
) lfsr_inst (
    .clk(clk),
    .en(en),
    .init(init),
    .din(1'b1),
    .lfsr(lfsr)
);
	
reg [$clog2(LFSR)-2:0]cnt;
reg en, init;

always @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		Red <= 4'h0;
		Green <= 4'h0;
		Blue <= 4'h0;
		Draw <= 0;
        cnt <= 0;
        en <= 1'b0;
        init <= 1'b0;
	end
	else begin
        Red <= 4'hf;
        Green <= 4'hf;
        Blue <= 4'hf;
        en <= (cnt == 1) | init;
        if ((pxl_x == 0) && (pxl_y == 0)) begin
            Draw <= '0;
            en <= '0;
            cnt <= '0;
            init <= 1;
        end else if (cnt > 0) begin
            init <= 0;
            // countdown to next star
            Draw <= '0;
            cnt <= cnt - 1;
        end else begin
            init <= 0;
            cnt <= lfsr;
            Draw <= 1;
		end
	end
end

endmodule