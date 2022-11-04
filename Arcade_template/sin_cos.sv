module sin_cos #(
    parameter ROM_DEPTH=256,  // number of entries in sine ROM for 0° to 90°
    parameter WIDTH=18   // width of sine ROM data in bits
) (
    input clk,
    input  logic        [$clog2(ROM_DEPTH)+2-1:0] phase,  // fraction, 0 to 2*PI
    output logic signed [WIDTH-1:0] sin_val,  // result
    output logic signed [WIDTH-1:0] cos_val  // result
);

    // sine table ROM: 0°-90°
    logic [$clog2(ROM_DEPTH)-1:0] rom_addr;
    // ROM data
    logic signed [WIDTH-1:0] sin_data;
    logic signed [WIDTH-1:0] cos_data;
    sincos sincos_inst (
        .address(rom_addr),
        .clock(clk),
        .q({sin_data, cos_data})
    );

    wire [1:0] quad = phase[$clog2(ROM_DEPTH)+2-1:$clog2(ROM_DEPTH)];  // quadrant we're in: I, II, III, IV
    always_comb begin
        // 2nd and 4th quadrants use mirrored data
        rom_addr = phase[$clog2(ROM_DEPTH)-1:0];
        case(quad)
            2'd0: begin
                sin_val = sin_data;
                cos_val = cos_data;
            end
            2'd1: begin
                sin_val =  cos_data;
                cos_val = -sin_data;
            end
            2'd2: begin
                sin_val = -sin_data;
                cos_val = -cos_data;
            end
            2'd3: begin
                sin_val = -cos_data;
                cos_val =  sin_data;
            end
            default: begin
                sin_val = 18'hx;
                cos_val = 18'hx;
            end
        endcase
    end
endmodule
