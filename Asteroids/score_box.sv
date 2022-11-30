module score_box #(
    parameter NUM=1,
    parameter DIGITS=4 // How many digits
) (
    input  clk,
    input  resetN,
    input  [NUM-1:0][DIGITS-1:0][3:0]sum, // digit to display
    output [DIGITS-1:0][3:0]score
);



reg [DIGITS:0]carry;
reg [DIGITS-1:0]chain;
wire [A_NUM-1:0][DIGITS-1:0][3:0]score_n;
reg  [A_NUM-1:0][DIGITS-1:0][3:0]score_s;

genvar ga;
generate
    for (ga = 0; ga < A_NUM; ga = ga + 1) begin : bcd
        BCD_add #(
            .DIGITS(DIGITS)
        ) score_inst (
            .num1((ga == 0) ? sum[0] : score_s[ga-1]),
            .num2((ga == (A_NUM - 1)) ? score_s[0] : sum[ga+1]),
            .result(score_n[ga])
        );
        always_ff @(posedge clk)
            score_s[ga] <= score_n[ga];
    end
endgenerate

assign score = score_s[A_NUM-1];

endmodule
