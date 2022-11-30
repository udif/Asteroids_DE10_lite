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
The game is design to work with a "VGA chain". the VGA sync generator starts the chain, and each graphic layer is connected to the chain.
The last element on the chain (highest priority) returns it to the screen_display unit where it is both sent to LCD and to the VGA connector.
The use of a VGA chain and the grouped-together vGA signals allows us to buffer any point in the chain according to the timing needs, as well
as making it easier to implement transparencies.

## Background image
The background star image is based on a 10-bit linear feedback shift register that generates a presudo-random sequence. Each number is used to count the number of black pixels (in scan order) until the next white pixel ("star"). The LFSR is reset to a known state when the raster generator is generating pixel (0,0), so that the stars background is stable.  

## Sprites
A generic Sprite model has been written. The module gets the sprite location, size, center axis as inputs, and even it's rotation angle (in the form of sin/cos values). It also gets the (x,y) location of the currently rendered pixel. It then generates ROM addresses to read the pixel data from the sprite ROM and sends it out, with a qualifier 
Each sprite can have a variable number of color bits in memory from 1 bit images to 12-bit RGB (4 bit each).
Sprites may fill the whole screen, and may be precisely rotated (10 bit phase covering 360 degrees).
Since each pixel is  

Resources  
=========
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
Clip:  
Infected Vibes  
by Alejandro Magaña (A. M.)  
https://mixkit.co/free-stock-music/mood/upbeat/  
License:  
https://mixkit.co/license/#musicFree  
