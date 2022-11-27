// https://stackoverflow.com/questions/40138917/64-bit-lfsr-design
module lfsr64 (
   input clk,
   input rst,
   output reg [63:0] out
);

    wire feedback;
    assign feedback = ~(out[63] ^ out[62] ^ out[60] ^ out[59]);

    always @(posedge clk or negedge rst)
        if (~rst)
            out <= 64'b0;
        else
            out <= {out[62:0],feedback};
endmodule