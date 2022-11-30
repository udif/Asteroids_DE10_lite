//
// Project-wide definitions
// We should add more here!
//
// Copyright (C) 2022 Udi Finkelstein
//

package asteroids;

// how many torpedos at the same time
localparam T_NUM = 4;

// How many initial asteroids
localparam A_NUM = 4;

localparam XY_FRACTION = 7; // subpixel fraction bits

localparam MEM_XLMS_WIDTH    = 150;
localparam MEM_XLMS_HEIGHT   = 212;
localparam MEM_LMS_WIDTH     = 113;
localparam MEM_LMS_HEIGHT    = 71;

localparam AST_XLARGE_WIDTH  = 150;
localparam AST_XLARGE_HEIGHT = 141;
localparam AST_LARGE_WIDTH   = 75;
localparam AST_LARGE_HEIGHT  = 71;
localparam AST_MED_WIDTH     = 38;
localparam AST_MED_HEIGHT    = 36;
localparam AST_SMALL_WIDTH   = 19;
localparam AST_SMALL_HEIGHT  = 18;

// Asteroid types
typedef enum {
    AST_XLARGE, // only used at start screen
    AST_LARGE,
    AST_MED,
    AST_SMALL} ast_t;
endpackage
