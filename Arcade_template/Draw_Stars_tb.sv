// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************


module Draw_Stars_tb;

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

wire [3:0]red_stars;
wire [3:0]green_stars;
wire [3:0]blue_stars;
wire draw_stars;

Draw_Stars Draw_Stars_inst(
	.clk(clk),
	.resetN(resetN),
	.pxl_x(Pxl_x_i),
	.pxl_y(Pxl_y_i),
	.Red(red_stars),
	.Green(green_stars),
	.Blue(blue_stars),
	.Draw(draw_stars)
	);

integer i;
initial
begin
    resetN = 1'b0;
    @(posedge clk);
    resetN = 1'b1;
    for (i = 0; i < 10000; i++) begin
        @(posedge clk);
        $display("%4d %4d : en=%1d init=%1d cnt=%3d Draw=%1d", Pxl_x_i, Pxl_y_i, Draw_Stars_inst.en, Draw_Stars_inst.init, Draw_Stars_inst.cnt, Draw_Stars_inst.Draw);
    end
    $finish(0);
end

endmodule