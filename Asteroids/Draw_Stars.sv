// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************

module Draw_Stars #(
	parameter WIDTH=640,
	parameter HEIGHT=480
) (
	
	input    clk,
	input    resetN,
    vga.in  vga_chain_in,
    vga.out vga_chain_out
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
		vga_chain_out.t <= '0;
		vga_chain_out.t.red <= 4'h0;
		vga_chain_out.t.green <= 4'h0;
		vga_chain_out.t.blue <= 4'h0;
		vga_chain_out.t.en <= 1'b0;
        cnt <= 0;
        en <= 1'b0;
        init <= 1'b0;
	end
	else begin
        vga_chain_out.t <= vga_chain_in.t;
        vga_chain_out.t.red <= 4'hf;
        vga_chain_out.t.green <= 4'hf;
        vga_chain_out.t.blue <= 4'hf;
        en <= (cnt == 1) | init;
        if ((vga_chain_in.t.pxl_x == 0) && (vga_chain_in.t.pxl_y == 0)) begin
            vga_chain_out.t.en <= 1'b0;
            en <= '0;
            cnt <= '0;
            init <= 1;
        end else if (cnt > 0) begin
            init <= 0;
            // countdown to next star
            vga_chain_out.t.red <= 4'h0;
            vga_chain_out.t.green <= 4'h0;
            vga_chain_out.t.blue <= 4'h0;
            vga_chain_out.t.en <= 1'b0;
            cnt <= cnt - {{($bits(cnt)-1){1'b0}}, 1'b1};
        end else begin
            init <= 0;
            cnt <= lfsr;
            vga_chain_out.t.en <= 1'b1;
		end
	end
end

endmodule