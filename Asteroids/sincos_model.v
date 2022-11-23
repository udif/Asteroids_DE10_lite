module sincos (
    input   [7:0]  address,
    input     clock,
    output reg [35:0]  q
);

reg [35:0]mem[0:255];
reg [7:0]address_q;

initial
    $readmemh("sincos.mem", mem);

always @(posedge clock)
begin
    address_q <= address;
    q <= mem[address_q];
end
endmodule
