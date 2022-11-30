module score_box #(
    parameter DIGITS=4 // How many digits
) (
    input  clk,
    input  resetN,
    input  [DIGITS-1:0][3:0]sum, // digit to display
    output reg [DIGITS-1:0][3:0]score
);



reg [DIGITS:0]carry;
reg [DIGITS-1:0]chain;
wire [DIGITS-1:0][3:0]score_n;

BCD_add #(
	.DIGITS(DIGITS)
) score_inst (
	.clk(clk),
	.digits(score),
    .sum(sum),
	.result(score_n),
);

//
// Do not start a new sum while the previous one is still running
//

always_ff @(posedge clk or negedge resetN)
    if (~resetN) begin
        score <= '0;
    end else begin
        score <= score_n;
    end

endmodule
