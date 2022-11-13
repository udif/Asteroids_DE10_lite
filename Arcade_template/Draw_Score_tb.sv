// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************


module Draw_Score_tb;

localparam WIDTH = 640;
localparam HEIGHT = 480;

reg clk;
initial clk = 1'b0;
always clk = #5 ~clk;
reg resetN;

wire [$clog2(WIDTH )-1:0]Pxl_x_i;
wire [$clog2(HEIGHT)-1:0]Pxl_y_i;
wire disp_ena;
wire h_sync_d;
wire v_sync_d;

// VGA controller
 vga_controller VGA_interface (
	.pixel_clk  (clk),
   .reset_n    (resetN),
   .h_sync     (h_sync_d),
   .v_sync     (v_sync_d),
   .disp_ena   (disp_ena),
   .column     (Pxl_x_i),
   .row        (Pxl_y_i)
   );

wire [3:0]red_score;
wire [3:0]green_score;
wire [3:0]blue_score;
wire draw_score;

localparam DIGITS = 10;

Draw_Score #(
	.DIGITS(DIGITS)
) score_inst(	
	.clk(clk),
	.offsetX(Pxl_x_i),
	.offsetY(Pxl_y_i),
	.digits(40'h123456789a),
	.Red(red_score),
	.Green(green_score),
	.Blue(blue_score),
	.Draw(draw_score)
);	

reg [$clog2(HEIGHT)-1:0]Pxl_y_i_d;

reg pixel;
integer i;
initial
begin
    resetN = 1'b0;
    @(posedge clk);
    resetN = 1'b1;
    Pxl_y_i_d = '1;
    while (Pxl_y_i <= 31) begin
        @(posedge clk);
        if (Pxl_x_i > 18*DIGITS)
            continue;
        if (Pxl_y_i != Pxl_y_i_d)
            $write("\n(%03d,%03d):", Pxl_y_i, Pxl_x_i);
        pixel = red_score[0] && // you can easily comment this part to get drawing mask
                draw_score;
        if (Pxl_x_i % 18 == 0) $write(" ");
            $write("%1d", pixel);
        //$display("%03x %1x %1x", score_inst.offset_x_spaced, red_score[0] && draw_score, draw_score);
        Pxl_y_i_d = Pxl_y_i;
    end
    $write("\n");
    $finish(0);
end

endmodule