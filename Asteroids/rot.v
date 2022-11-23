module rot #(
    parameter PHASE_W = 10,
    parameter DATA_W = 18
) (
    input clk,
    // input x,y
    input signed [DATA_W-1:0]x,
    input signed [DATA_W-1:0]y,
    // rotation angle, the entire range covers 360 degrees
    input [PHASE_W-1:0]theta,
    // rotated X,Y
    //    return ((x*cos(theta)-y*sin(theta)), (x*sin(theta)+y*cos(theta)))
    output signed [DATA_W-1:0]rx,
    output signed [DATA_W-1:0]ry
);

wire signed [17:0] sin_val;
wire signed [17:0] cos_val;

sin_cos sin_cos_inst (
	.clk(clk),
	.phase(theta),
	.sin_val(sin_val),
	.cos_val(cos_val)
);

rot_sin_cos #(
	.DATA_W(DATA_W)
) rot_inst (
	.x(x),
	.y(y),
    .sin_val(sin_val),
    .cos_val(cos_val),
	.rx(rx),
	.ry(ry)
);

endmodule
