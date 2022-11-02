module sin_cos #(
    parameter ROM_DEPTH=256,  // number of entries in sine ROM for 0° to 90°
    parameter WIDTH=18,   // width of sine ROM data in bits
    localparam ADDRW=$clog2(4*ROM_DEPTH)  // full circle is 0° to 360°
) (
    input clk,
    input  wire logic [ADDRW-1:0] phase,  // fraction, 0 to 2*PI
    output      logic signed [WIDTH-1:0] sin_val,  // result
    output      logic signed [WIDTH-1:0] cos_val  // result
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

    logic [1:0] quad;  // quadrant we're in: I, II, III, IV
    always_comb begin
        // 2nd and 4th quadrants use mirrored data
        rom_addr = quad[0] ? (ROM_DEPTH - 1) - phase[ADDRW-3:0];
        sin_val = (quad == 2 || quad == 3) ? -sin_data : sin_data;
        cos_val = (quad == 1 || quad == 2) ? -cos_data : cos_data;
    end
endmodule
