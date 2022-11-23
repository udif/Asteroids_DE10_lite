// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************



module periphery_control (
	
	input		clk,
	output	A,
	output	B,
	output	Select,
	output	Start,
	output	Right,
	output	Left,
	output	Up,
	output	Down,
	output	[11:0] Wheel
	);
	
	wire	[11:0]	a0;
	wire	[11:0]	a1;
	wire	[11:0]	a2;
	wire	[11:0]	a3;
	wire	[11:0]	a4;
	
	// Analog Read Module
analog_input analog_input_inst(
	.clk(clk),
	.a0(a0), // LEFT/RIGHT Left = High, Right = middle, 0 = nothing
	.a1(a1), // UP/DOWN - Hihg up, midle down. 0 nothing
	.a2(a2), // Select button HIGH is pressed
	.a3(a3), // Button A 0 is pressed
	.a4(a4),	// Button B 0 is pressed
	.a5(Wheel) // Wheel input
	);
	
	assign A =      (a3 < 12'd2048);                  // A
	assign B =      (a4 < 12'd2048);                  // B
	assign Select = (a2 > 12'hCFF);                   // Select
	assign Start =  (a2 < 12'hCFF) && (a2 > 12'h5FF); // Start
	assign Left =   (a0 > 12'hCFF);                   // Left
	assign Right =  (a0 < 12'hCFF) && (a0 > 12'h5FF); // Right
	assign Up =     (a1 > 12'hCFF);                   // UP
	assign Down =   (a1 < 12'hCFF) && (a1 > 12'h5FF); // DOWN

endmodule
