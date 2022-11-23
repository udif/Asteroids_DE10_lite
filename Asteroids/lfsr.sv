module lfsr #(
    parameter LFSR=11'h481
) (
    input clk,
    input init,
    input en,
    input din,
    output reg [$clog2(LFSR)-2:0]lfsr
);

always @(posedge clk)
begin
    if (init)
        lfsr <= {1'b1, {($clog2(LFSR)-2){1'b0}}};
    else if (en)
        lfsr <= {lfsr[$clog2(LFSR)-3:0], ^(LFSR[$clog2(LFSR)-1:0] & {lfsr, din})};
end
endmodule