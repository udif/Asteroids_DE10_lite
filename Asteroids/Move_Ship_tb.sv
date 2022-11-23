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

localparam DEBUG_SIZE=4;
wire [DEBUG_SIZE-1:0][63:0]debug_out;

Move_Ship #(
    .CLK_RATE(32),
    .DIVIDER(4),
    .BTN_RATE(4),
    .DEBUG_SIZE(DEBUG_SIZE),
	.WIDTH(WIDTH),
	.HEIGHT(HEIGHT)
) m_i (
	.clk(clk),
	.resetN(resetN),
	.collision(1'b0),
	.B(B),
	.sin_val(sin_val),
	.cos_val(cos_val),
	.topLeft_x(topLeft_x_ship),
	.topLeft_y(topLeft_y_ship)
	,.debug_out(debug_out)
);


wire real F  = $itor((1 << 16)); //m_i.XY_FRACTION
wire real SP = $itor((1 << 12)); //m_i.SPEED_FRAC_BITS
wire real SN = $itor((1 << 17));

integer i;
initial
begin
    theta = 10'd600;
    B = 0;
    @(posedge clk);
    resetN = 1'b0;
    @(posedge clk);
    resetN = 1'b1;
    for (i = 0; i < 10000; i++) begin
        @(posedge clk);
        if (i == 1*4 || i == 5*4 || i == 7*4 || i == 10*4 || i == 13*4 || i == 14*4 || i == 20*4)
            B = 1;
        else
            B = 1;
        if (i == 800*4)
            theta = theta + 512;
        $display("i=%2d c=%2d bc=%2d B=%1d sin=%1.3f x=%3.3f tl_x=%3d, x_speed=%3.3f, x_speed_inc=%3.3f, x_speed_new=%3.3f, x_speed_2=%3.3f", i, m_i.counter, m_i.btn_counter, B, $itor(m_i.sin_val)/SN, $itor(m_i.x)/F, topLeft_x_ship, $itor(m_i.x_speed)/SN/SP, m_i.x_speed_inc/SN/SP, $itor(m_i.x_speed_new)/SN/SP, $itor(m_i.x_speed_2)/F);
    end
    $finish(0);
end
endmodule
