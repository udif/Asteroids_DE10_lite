module test;
reg clk;
initial clk = 1'b0;

always clk = #5 ~clk;

localparam DATA_W = 10;
localparam SCALE = 2**(DATA_W-1);

reg [9:0]theta;
reg  [DATA_W-1:0]x;
reg  [DATA_W-1:0]y;
wire [DATA_W-1:0]rx;
wire [DATA_W-1:0]ry;

rot #(
    .DATA_W(DATA_W)
) rot_inst (
    .clk(clk),
	.x(x),
	.y(y),
	.theta(theta),
	.rx(rx),
	.ry(ry)
);

integer i;
initial
begin
    for (i = 0; i < 1024; i += 4) begin
        theta = i[9:0];
        x = 10;
        y = 0;
        @(posedge clk);
        @(posedge clk);
        $display("%3d (x=%3d, y=%3d) => (rx=%3d, ry=%3d)", i, x,  y, rx, ry);
        //$display("%d sin = %5x %f cos = %5x %f", i, rot_inst.sin_val, $itor($signed(rot_inst.sin_val)) / SCALE, rot_inst.cos_val, $itor($signed(rot_inst.cos_val)) / SCALE);
        //$display("%d xsin_val = %9x %f xcos_val = %9x %f", i, rot_inst.xsin_val, $itor($signed(rot_inst.xsin_val)) / SCALE, rot_inst.xcos_val, $itor($signed(rot_inst.xcos_val)) / SCALE);
        //$display("%d ysin_val = %9x %f ycos_val = %9x %f", i, rot_inst.ysin_val, $itor($signed(rot_inst.ysin_val)) / SCALE, rot_inst.ycos_val, $itor($signed(rot_inst.ycos_val)) / SCALE);
        //$display("%d rx_t = %9x %f ry_t = %9x %f", i, rot_inst.rx_t, $itor($signed(rot_inst.rx_t)) / SCALE, rot_inst.ry_t, $itor($signed(rot_inst.ry_t)) / SCALE);
        //$display("%d rx = %9x %f ry = %9x %f", i, rot_inst.rx, $itor($signed(rot_inst.rx)) / SCALE, rot_inst.ry, $itor($signed(rot_inst.ry)) / SCALE);
    end
    $finish(0);
end
endmodule
