Asteroids  
By Udi Finkelstein  

Intel 2nd CPU Garage competition entry

Description:
============

This game is inspired by the original ATARI [Asteroids](http://www.classicgaming.cc/classics/asteroids/play-guide) game.  

Objective
---------
Shoot at the flying asteroids without running into them.  
If hit, a big astroid will be split into 2 medium asteroids, a medium asteroid will be split into 2 small asteroids, and hitting a small asteroid will vaporize it completely.  

Points
------
Hitting an asteroid will gain you points:
* Large asteroid  -  20 points  
* Medium asteroid -  50 points  
* Small asteroid  - 100 points  

Lives
-----
You have initially 3 lives. Each time you collide with an asteroid, you lose a life and start again at the middle of the screen.
You also get an extra life after every 10,000 points.  

Controls
--------
* Knob  
Rotate your spaceship around
* B  
Accelerate
* A  
Fire a missile (up to 4 simultaneously)
* Start  
Start a new game  

Technical details
=================
The game is fully hardwired, and implemented in SystemVerilog. (no CPU core is used).

Graphics
--------
All the objects on the screen (except the score display) are based on a prioritized sprite system, plus one background image.  

## VGA chain
I have used this game to try using some more SystemVerilog advanced concepts such as interfaces for RTL coding.  
I have a "vga" interface containing hsync, vsync, rgb, x+y of current pixel, drawing enable bit.  
The game is designed to work with a "VGA chain". the VGA sync generator starts the chain, and each graphic layer is connected to the chain.
The last element on the chain (highest priority) returns it to the screen_display unit where it is both sent to LCD and to the VGA connector.
The use of a VGA chain and the grouped-together vGA signals allows us to buffer any point in the chain according to the timing needs, as well
as making it easier to implement transparencies.

## Background image
The background star image is based on a 10-bit linear feedback shift register that generates a presudo-random sequence. Each number is used to count the number of black pixels (in scan order) until the next white pixel ("star"). The LFSR is reset to a known state when the raster generator is generating pixel (0,0), so that the stars background is stable.  

## Sprites
A generic Sprite model has been written. The module gets the sprite location, size, center axis as inputs, and even it's rotation angle (in the form of sin/cos values). It also gets the (x,y) location of the currently rendered pixel. It then generates ROM addresses to read the pixel data from the sprite ROM and sends it out, with a qualifier 
Each sprite can have a variable number of color bits in memory from 1 bit images to 12-bit RGB (4 bit each).
Sprites may fill the whole screen, and may be precisely rotated (10 bit phase covering 360 degrees).

## Collision  
The on-the-fly aproach for rendering graphics used here, makes detecting sprite collision very easy. All it takes is to AND the 'en' signal from any two modules on the VGA chain.
If both are enabled on the same (x,y) pixel, they are colliding. If you are comparing two en signals from different nodes on the VGA chain, and you have buffers along the way,
you need to buffer the earlier en signal so you can compare them on the same timing.  

## Memories
All sprites are using the M9K memory modules. A few techniques are used to minimize memory consumption:
1. When multiple instances of the same module are used (e.g. asteroids), we share the same memory between pairs of instances, since 2-port ROMs occuly the same number of M9K blocks as single port ROMs.
2. The sprite logic can render a rectangle that is part of a larger rectangle. We are using this to pack several different asteroids of different sizesmore effectively on the same image.
3. We conserve the number of bits depending on the image :
   * Asteroids are grey level, so we only use 4-bit, and duplicate them on all RGB channels, plus a 5th bit for alpha channel.
   * The starting banner only needs red/yellow colors, and given the strong colors and lack of different shades, only 2 bits are used for red and 2 bits for yellow.
4. We also use memories for sin/cos tables. We store the table between 0 and 90 degrees of both sin and cos (18 bit each) in 256 entries, and calculate the entire 0 to 360 degrees range from there (swapping sin and cos, and swapping sign a needed, e.g. if we get sin 95, we calculate cos 5, and to get cos 95 we use -(sin 5). With 36 bit entries for sin,cos and 256 lines for 0 to 90 degrees, the entire table fits in a single M9K.
## Math
1. Multipliers are free - The chip has close to 300 9x9 bit multipliers (or half the number of 18x18 multipliers). We use them freely and try to make optimal use of the free precision.
2. Precision (see above) - we use binary fractions by taking advantage of the extra bits available from 18x18 multipliers. with 10 bit x,y coordinates, we get 7 more fraction bits. With sin/cos being in the +-1 range, we get 17 bit fractions.


## Score
Our score submodule can take N parallel inputs (coded in BCD) and sum them all in a single cycle. We do this by bulding a binary tree of BCD adders for the number of inputs we need,
with each level fully samples, so we can sustain 1 number/cycle on each input. Once we get only 1 sum term from the tree, we accumulate it with the current score.


TODO
====
## Improve graphics
The graphics (rotated sprites) rotate the current pixel, and gets a new fractional pixel in the sprite coordinate system. We then take the closest pixel to that location.
By averaging the 4 nearest neighbouring pixels, weighting the result by the tractional distance, we could get better, antialiased graphics, and due to the use of VGA chain,
even transparency, if needed.

## Improve resources
Cut the number of M9K's used for sin/cos by using 2-port ROMs and sharing 1 rom between two sin/cos functions.

3rd party Resources and assets used:  
====================================
Some, but not all, of the source resoureces used by this project requires attribution, and some requires describing any modifications done to the original material.
Nevertheless, we list all resources used, even those not requiring attribution, to clear any question that might arise regarding the origin of any asserts in the game.

## Images
* Main ship is based on:  
https://foozlecc.itch.io/void-main-ship  
(License: [CC0](https://creativecommons.org/share-your-work/public-domain/cc0/) )
Some images have been slightly edited.

* Asteroid images were taken from [OpenGameArt.org](https://opengameart.org/content/asteroids), and were created by [phaelax](https://opengameart.org/users/phaelax):  
(Lcense: [CC-BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/)
Only a subset of the asteroids in this collection were used, and those were scaled and their color changed.

* GAMEOVER and ASTEROIDS banners are based on the [SF Atarian System](https://shyfoundry.com/fonts/atarian-system) font, by ShyFoundry:  
(License: [Desktop License - FREE](https://shyfoundry.com/eula/desktop) )

* ASTEROIDS Logo is taken from https://commons.wikimedia.org/wiki/File:Asteroids_arcade_logo.png
(License: Public Domain)

## YouTube Video:  
https://www.youtube.com/watch?v=jljZyp8AxQo  

### Music Clip:  
Infected Vibes  
by Alejandro Magaña (A. M.)  
https://mixkit.co/free-stock-music/mood/upbeat/  
License:  
https://mixkit.co/license/#musicFree  
