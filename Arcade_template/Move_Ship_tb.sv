module test;
reg clk;
initial clk = 1'b0;

always clk = #5 ~clk;

localparam WIDTH = 640;
localparam HEIGHT = 480;

reg [9:0]theta;
wire	[$clog2(WIDTH )-1:0]topLeft_x_ship;
wire	[$clog2(HEIGHT)-1:0]topLeft_y_ship;

wire signed [17:0] sin_val;
wire signed [17:0] cos_val;
reg B;
reg resetN;

sin_cos sin_cos_inst (
	.clk(clk),
	.phase(theta),
	.sin_val(sin_val),
	.cos_val(cos_val)
);

Move_Ship #(
    .CLK_RATE(4),
    .DIVIDER(2),
	.WIDTH(WIDTH),
	.HEIGHT(HEIGHT)
) move_inst2(
	.clk(clk),
	.resetN(resetN),
	.collision(1'b0),
	.B(B),
	.sin_val(sin_val),
	.cos_val(cos_val),
	.topLeft_x(topLeft_x_ship),
	.topLeft_y(topLeft_y_ship)
	);

integer i;
initial
begin
    theta = 10'd100;
    B = 0;
    @(posedge clk);
    resetN = 1'b0;
    @(posedge clk);
    resetN = 1'b1;
    for (i = 0; i < 1000; i++) begin
        @(posedge clk);
        if (i == 1*4 || i == 5*4 || i == 7*4 || i == 10*4 || i == 13*4 || i == 14*4 || i == 20*4)
            B = 1;
        else
            B = 0;
        if (i == 8*4)
            theta = theta + 512;
        $display("i=%2d B=%1d (x=%3d, y=%3d)", i, B, topLeft_x_ship,  topLeft_y_ship);
    end
    $finish(0);
end
endmodule
