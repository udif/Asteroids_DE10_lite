// Hexadecimal Number Bitmap
// Designed for up to 8 digits

module Draw_Score #(
	parameter WIDTH=640,
	parameter HEIGHT=480,
    parameter DIGITS=4, // How many digits
    parameter  [11:0] digit_color = 12'hfff //set the color of the digit
) (
    input clk,
    vga.in  vga_chain_in,
    vga.out vga_chain_out,
    input [$clog2(WIDTH )-1:0]offsetX,
    input [$clog2(HEIGHT)-1:0]offsetY,
    input  logic [DIGITS*4-1:0] digits, // digit to display
    input draw_mask
);

logic [3:0]red;
logic [3:0]green;
logic [3:0]blue;

wire [12:0]numbers_addr;
wire numbers_data;
wire [3:0]digit;
reg Draw_b2, Draw_b1;
wire [10:0] offset_x_spaced;// offset from top left  position

numbers	numbers_inst (
    .clock(clk),
    .address(numbers_addr),
    .q(numbers_data)
);

//
// Drawing always at (0,0)
// If you want to draw elsewhere, subtract offset outside
//

wire [4:0]digit_x_next;
reg  [4:0]digit_x;
wire [5:0]digit_index_next;
reg [5:0]digit_index; // how many digits
reg Draw;

wire [$clog2(WIDTH )-1:0]loc_x = vga_chain_in.t.pxl_x - offsetX;
wire [$clog2(HEIGHT)-1:0]loc_y = vga_chain_in.t.pxl_y - offsetY;

// we count to 18 due to 2 pixel space between each digit
assign digit_x_next  = (loc_x == 0)     ? 5'd0 : // start of line
                       (digit_x == 5'd17) ? 5'd0 : // end of digit, reset pixel counter
                       (digit_x + 5'd1);           // next pixel on digit
assign digit_index_next = (loc_x == 0)     ? DIGITS[5:0] - 6'd1 :   // start of line
                          (digit_x == 5'd17) ? (digit_index - 6'd1) : // end of current digit, advance to next one
                           digit_index;                               // keep current digit
assign digit = ({1'b0, digit_index_next} >= DIGITS) ? 4'b0 : digits[{digit_index_next[$clog2(DIGITS)-1:0], 2'b0} +: 4];
assign numbers_addr = {digit, loc_y[4:0], digit_x_next[3:0]};


always @(posedge clk) begin
    digit_x     <= digit_x_next;
    digit_index <= digit_index_next;
    // 2 pixel border
    // loc_x[6:4] is digit #
    // digit 0 must not be blanked
    // digit 1 must blank at columns 0,1
    // digit 2 must blank at columns 2,3
    // etc.
    Draw_b2 <= ~digit_x_next[4] && (digit_index_next < DIGITS[5:0]) && draw_mask;
    Draw_b1 <= Draw_b2 && (~|loc_y[$bits(loc_y)-1:5]);
    // Draw is delayed by 2 cycles due to ROM access latency
    Draw    <= (loc_x > 2) && Draw_b1; // mask first two bits here due to pipeline
    {red, green, blue} <= numbers_data ? digit_color : 12'h000;
end

always_comb begin
	vga_chain_out.t = vga_chain_in.t;
	vga_chain_out.t.red   = Draw ? red   : vga_chain_in.t.red;
	vga_chain_out.t.green = Draw ? green : vga_chain_in.t.green;
	vga_chain_out.t.blue  = Draw ? blue  : vga_chain_in.t.blue;
	vga_chain_out.t.en    = Draw;
end

endmodule
