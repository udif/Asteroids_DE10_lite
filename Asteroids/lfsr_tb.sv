module lfsr_tb;

reg clk;
initial clk = 1'b0;

always clk = #5 ~clk;

reg [9:0]lfsr;
reg init;

lfsr #(
    .LFSR(32'h481)
) lfsr_inst (
    .clk(clk),
    .init(init),
    .en(1'b1),
    .din(1'b1),
    .lfsr(lfsr)
);

integer i;
initial
begin
    init = 1'b1;
    @(posedge clk);
    init = 1'b0;
    @(posedge clk);
    for (i = 0; i < 1024; i++) begin
        @(posedge clk);
        $display("%04x", lfsr);
    end
    $finish(0);
end

endmodule