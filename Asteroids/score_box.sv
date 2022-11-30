//
// Sum "NUM" score updates and accumulate the result into current score
// Everything is BCD encoded, 4 bits/digit
//
// Copyright (C) 2022 Udi Finkelstein
//
module score_box #(
    parameter NUM=1,
    parameter DIGITS=4 // How many digits
) (
    input  clk,
    input  resetN,
    input  [NUM-1:0][DIGITS-1:0][3:0]sum, // digit to display
    output reg [DIGITS-1:0][3:0]score
);

wire [$clog2(A_NUM)-1:0][A_NUM/2-1:0][DIGITS-1:0][3:0]sum_n;
reg  [$clog2(A_NUM)-1:0][A_NUM/2-1:0][DIGITS-1:0][3:0]sum_s;
wire [DIGITS-1:0][3:0]score_n;

// build a triangle/binary tree to first sum all inputs, then accumulate with score.
// Each adder row is buffered by flops, so the output is pipelined by $clog2(NUM)+1 stages
genvar ga, gd;
generate
    // sum all sum inputs
    for (gd = 0; gd < $clog2(A_NUM); gd = gd + 1) begin : bcd
        // one triangle row
        for (ga = 0; ga < A_NUM>>gd ; ga = ga + 2) begin : bcd
            BCD_add #(
                .DIGITS(DIGITS)
            ) score_inst (
                .num1((gd == 0) ? sum[ga] : score_n[gd-1][ga]), // on 1st row take from sum[] otehrwise from prev row
                // same, but also check for odd number of elements and pad with 0
                .num2((ga == (A_NUM>>gd) - 1) ? '0 : (gd == 0) ? sum[ga+1] : sum_s[gd-1][ga]),
                // output index is ga>>1 because next row is half the size
                .result(sum_s[gd][ga>>1])
            );
            // buffer rows
            always_ff @(posedge clk)
                sum_s[gd][ga>>1] <= sum_s[gd][ga>>1];
        end
    end
endgenerate

// add current score to sums
BCD_add #(
    .DIGITS(DIGITS)
) score_inst (
    .num1(score),
    // top triangle element, or we skip it if A_NUM==1
    .num2((A_NUM == 1) ? sum[0] : sum_s[$clog2(A_NUM)-1][0]),
    .result(score_n)
);

always_ff @(posedge clk or negedge resetN)
    if (~resetN)
        score <= '0;
    else
        score <= score_n;

endmodule
