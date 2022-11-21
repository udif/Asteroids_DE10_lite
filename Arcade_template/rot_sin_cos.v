module rot_sin_cos #(
    parameter SINCOS_FRACTION=17,
    parameter DATA_W = 18
) (
    // input x,y
    input signed [DATA_W-1:0]x,
    input signed [DATA_W-1:0]y,
    // rotation angle, already encoded with sin/cos values
    input signed [17:0] sin_val,
    input signed [17:0] cos_val,
    // rotated X,Y
    //    return ((x*cos(theta)-y*sin(theta)), (x*sin(theta)+y*cos(theta)))
    output signed [DATA_W-1:0]rx,
    output signed [DATA_W-1:0]ry
);

wire signed [DATA_W+18-1:0] xsin_val = x * sin_val;
wire signed [DATA_W+18-1:0] xcos_val = x * cos_val;
wire signed [DATA_W+18-1:0] ysin_val = y * sin_val;
wire signed [DATA_W+18-1:0] ycos_val = y * cos_val;

wire signed [DATA_W+18-1:0] rx_t = xcos_val - ysin_val;
wire signed [DATA_W+18-1:0] ry_t = xsin_val + ycos_val;

// result is 18 bits, the question is what bits we take
// since output is rotated x,y we only need 10 bits
// we add the 9th bit to round to nearest int
assign rx = rx_t[SINCOS_FRACTION +: DATA_W] + {{(DATA_W-1){1'b0}}, rx_t[SINCOS_FRACTION-1]};
assign ry = ry_t[SINCOS_FRACTION +: DATA_W] + {{(DATA_W-1){1'b0}}, ry_t[SINCOS_FRACTION-1]};

endmodule
