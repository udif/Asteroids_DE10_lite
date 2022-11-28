module score_box #(
    parameter DIGITS=4 // How many digits
) (
    input  clk,
    input  resetN,
    input  add,
    input  [DIGITS-1:0][3:0]sum, // digit to display
    output [DIGITS-1:0][3:0]result
);



reg [DIGITS:0]carry;
reg [DIGITS-1:0]chain;
reg [DIGITS-1:0][3:0]score;
wire [DIGITS-1:0][3:0]score_out;
wire done;
reg busy;
logic add_d;

assign result = score_out;

BCD_add #(
	.DIGITS(DIGITS)
) score_inst (
	.clk(clk),
	.digits(score),
    .sum(sum),
	.result(score_out),
	.start(add & ~add_d & (~busy | done)),
	.done(done)
);

//
// Do not start a new sum while the previous one is still running
//

always @(posedge clk or negedge resetN)
    if (~resetN) begin
        score <= '0;
        busy <= 1'b0;
    end else begin
        busy <= add | busy & ~done;
        score <= done ? score_out : score;
    end

always @(posedge clk) begin
    add_d <= add;
end

endmodule
