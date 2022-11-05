module rot_tb;
reg clk;
initial clk = 1'b0;

always clk = #5 ~clk;

reg [9:0]theta;
wire [17:0]sin_val;
wire [17:0]cos_val;

sin_cos sin_cos_inst (
    .clk(clk),
	.phase(theta),
	.sin_val(sin_val),
	.cos_val(cos_val)
);

integer i;
initial
begin
    for (i = 0; i < 1024; i++) begin
        theta = i[9:0];
        @(posedge clk);
        @(posedge clk);
        $display("%d %18x %f %18x %f", i, sin_val, $itor($signed(sin_val)) / 131072.0, cos_val, $itor($signed(cos_val)) / 131072.0);
    end
    $finish(0);
end
endmodule
