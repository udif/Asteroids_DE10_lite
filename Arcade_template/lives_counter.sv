module lives_counter #(
	parameter NUM_LIVES = 3,
	parameter MAX_NUM_LIVES = 8
) (
    input clk,
	input resetN,
	input die,
	input bonus,
	output game_over,
	output reg [$clog2(MAX_NUM_LIVES+1)-1:0]lives
);

reg bonus_d, die_d;
always @(posedge clk) begin
    bonus_d <= bonus;
    die_d <= die;
end

wire bonus_pulse = bonus & ~bonus_d;
wire die_pulse   = die   & ~die_d;
always @(posedge clk or negedge resetN) begin
    if (~resetN)
        lives <= ($bits(lives))'(NUM_LIVES);
    else if (die_pulse)
        lives <= (lives == 0) ? lives :
                                lives - ($bits(lives))'(1);
    else if (bonus_pulse)
        lives <= (lives == MAX_NUM_LIVES) ? lives :
                                            lives + ($bits(lives))'(1);
end

assign game_over = (lives == 0);

endmodule
