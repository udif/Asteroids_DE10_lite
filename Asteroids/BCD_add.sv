module BCD_add #(
    parameter DIGITS=4 // How many digits
) (
    input clk,
    input  [DIGITS-1:0][3:0]digits, // digit to display
    input  [DIGITS-1:0][3:0]sum, // digit to display
    output reg [DIGITS-1:0][3:0]result
);


wire [DIGITS:0]carry;
assign carry[0] = 1'b0;
logic [DIGITS-1:0][3:0]result_n;

genvar i;
generate
    for (i = 0; i < DIGITS; i = i + 1) begin: digit
        bcd_digit bd(
            .clk(clk),
            .cin(carry[i]),
            .cout(carry[i+1]),
            .a(digits[i]),
            .b(sum[i]),
            .c(result[i])
        );
    end
endgenerate

endmodule

module bcd_digit (
    input clk,
    input cin,
    input [3:0]a,
    input [3:0]b,
    output reg [3:0]c,
    output reg cout
);

wire [4:0]t = {1'b0, a} + {1'b0, b} + {4'b0, cin};
wire t_cout = (t >= 5'd10);

always_comb begin
    c <= t_cout ? (t[3:0] - 4'd10) : t[3:0];
    cout <= t_cout;
end
endmodule