package asteroids;

// how many torpedos at the same time
localparam T_NUM = 4;

// How many initial asteroids
localparam A_NUM = 1;

localparam XY_FRACTION = 7; // subpixel fraction bits

// Asteroid types
typedef enum {
    AST_XLARGE, // only used at start screen
    AST_LARGE,
    AST_MED,
    AST_SMALL} ast_t;
endpackage
