// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************


module Draw_Ghost (
	
	input					clk,
	input					resetN,
	
	input		[31:0]	pxl_x,
	input		[31:0]	pxl_y,
	
	input		[31:0]	topLeft_x,
	input		[31:0]	topLeft_y,
	
	input		[31:0]	width,
	input		[31:0]	high,
	
	output	[3:0]		Red_level,
	output	[3:0]		Green_level,
	output	[3:0]		Blue_level,
	output				Drawing
	
	);

wire	[31:0]	in_rectangle; 
wire	[31:0]	offset_x;
wire	[31:0]	offset_y;

logic[0:63][0:63][11:0] Bitmap = {
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hE22,12'hE22,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hE22,12'hE22,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hE22,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hE22,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hE22,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hE22,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hCCC,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'h01C,12'h01C,12'h01C,12'h01C,12'h01C,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'h01C,12'h01C,12'h01C,12'h01C,12'h01C,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'h01C,12'h01C,12'h00C,12'h00C,12'h00C,12'h01C,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'h01C,12'h00C,12'h00C,12'h00C,12'h01C,12'h01C,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'h01C,12'h00C,12'h00C,12'h00C,12'h00C,12'h01C,12'h01C,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'h01C,12'h01C,12'h00C,12'h00C,12'h00C,12'h00C,12'h01C,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'h01C,12'h00C,12'h00C,12'h00C,12'h00C,12'h01C,12'h01C,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'h01C,12'h01C,12'h00C,12'h00C,12'h00C,12'h00C,12'h01C,12'hFFF,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'h01C,12'h01C,12'h00C,12'h00C,12'h01C,12'h01C,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'h01C,12'h01C,12'h00C,12'h00C,12'h01C,12'h01C,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'h01C,12'h01C,12'h01C,12'h01C,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'h01C,12'h01C,12'h01C,12'h01C,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hE22,12'hCCC,12'hCCC,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hCCC,12'hCCC,12'hE22,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hE22,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hE22,12'hE22,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hE22,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hCCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hE22,12'hCCC,12'hE22,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF},
	{12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF}};


	
	assign in_rectangle = (pxl_x >= topLeft_x) && (pxl_x <= topLeft_x+width) && (pxl_y >= topLeft_y) && (pxl_y <= topLeft_y+high);
assign offset_x = pxl_x - topLeft_x;
assign offset_y = pxl_y - topLeft_y;
assign Red_level = Bitmap[offset_y][offset_x] [11:8];
assign Green_level = Bitmap[offset_y][offset_x] [7:4];
assign Blue_level = Bitmap[offset_y][offset_x] [3:0];

localparam TANSPERENT = 12'hFFF;

always @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		Drawing <= 0;
	end
	else begin
		Drawing <= 0;
		if (in_rectangle) begin
			if(Bitmap[offset_y][offset_x] != TANSPERENT) begin
				Drawing <= 1;
			end
		end
	end
end

endmodule