#
# Testbed for sprite drawing algorithms
#

from graphics import *
from math import pi, sin, cos, sqrt, floor
import sys
d2r = pi/180
factor = 4

def import_mif(fname):
    with open(fname) as f:
        for l in f.readlines():
            ll = l.strip(';\n')
            if ll.find("DEPTH") >= 0:
                depth = int(ll.split('=')[1])
                rom = [None] * depth
                #print(depth)
            if ll.find("WIDTH") >= 0:
                width = int(ll.split('=')[1])
                #print(width)
            if ll.find(":") >= 0:
                ll = ll.split(':')
                rom[int(ll[0], base=16)] = int(ll[1], base=16)
                #print(ll)
    return (width, rom)


(ghost_width, ghost) = import_mif("ghost.mif")

def color(p):
    return color_rgb(16*(p // 256), 16 * ((p // 16) % 16), 16 * (p % 16))

# Draw a 2x2 pixel
def pixel(x, y, p, win):
    r = Rectangle(Point(x, 239-y), Point(x+1, 239-(y+1)))
    r.setFill(color(p))
    r.setOutline(color(p))
    r.draw(win)

# rotate x,y around (0,0) by theta
def rot(x, y, th):
    sth = sin(th)
    cth = cos(th)
    return ((x*cth-y*sth), (x*sth+y*cth))

# averate 2 integers stored in a bitfield defined by mask and round to nearest
# bitfield mnust have at least 1 free bit on the right for rounding
def avg_bits2(tl, tr, p, mask):
    r = ~mask & (mask >> 1) # set 1 bit to the right of the mask
    t = int((tl & mask) * (1-p) + (tr & mask) * p)
    if t & r:
        t += r
    return t

# average 12 bit RGB pixel with ratio p (0 == left, 1 == right)
# shift mask 1 bit left to leave place for a rounding bit for B
def pixel_avg2(tl, tr, p):
    _tl = tl << 1
    _tr = tr << 1
    # mask is shifted left by 1 to leave room for rounding bit
    return (avg_bits2(_tl, _tr, p, 0x1e00) | avg_bits2(_tl, _tr, p, 0x01e0) | avg_bits2(_tl, _tr, p, 0x001e)) >> 1

# averate 2x2 integers stored in a bitfield defined by mask and round to nearest
# bitfield mnust have at least 1 free bit on the right for rounding
def avg_bits4(tl, tr, bl, br, px, py, mask):
    r = ~mask & (mask >> 1) # set 1 bit to the right of the mask
    t = int(((tl & mask) * (1 - px) + (tr & mask) * px) * (1 - py) +
            ((bl & mask) * (1 - px) + (br & mask) * px) * py)
    if t & r:
        t += r
    return t

# average 12 bit RGB pixel with ratio p (0 == left, 1 == right)
# shift mask 1 bit left to leave place for a rounding bit for B
def pixel_avg4(tl, tr, bl, br, px, py):
    _tl = tl << 1
    _tr = tr << 1
    _bl = bl << 1
    _br = br << 1
    # mask is shifted left by 1 to leave room for rounding bit
    return (avg_bits4(_tl, _tr, _bl, _br, px, py, 0x1e00) |
            avg_bits4(_tl, _tr, _bl, _br, px, py, 0x01e0) |
            avg_bits4(_tl, _tr, _bl, _br, px, py, 0x001e)) >> 1

win = GraphWin(width = 2580, height = 960) # create a window
win.setBackground("black")
win.setCoords(0, 0, 639, 239) # set the coordinates of the window; bottom left is (0, 0) and top right is (10, 10)

#
# First image, straight plot (reference)
#
x=50
y=100
for (i, p) in enumerate(ghost):
    dx = i % 64
    dy = i // 64
    pixel(x+dx, y+dy, p, win)

#
# Second image, rotate image by going over each image pixel (in image coordinates)
# and plotting in the nearest screen coordinate location
#
x=150
y=100
pixels = [[0] * 100 for i in range(100)]
for (i, p) in enumerate(ghost):
    dx = i % 64 - 32
    dy = i // 64 - 32
    (dxr, dyr) = rot(dx, dy, 30*d2r)
    #win.plot(x+dx, 479-(y+dy), color(p))
    pixel(int(x+dxr+32.5), int(y+dyr+32.5), p, win)
    pixels[int(20+dxr+32.5)][20+int(dyr+32.5)] = 1
print(pixels)
for l in pixels:
    for n in l:
        print(n, end="")
    print()

#
# Third image, draw rotated image by doing normal raster scan and getting pixel value from rotated image
# After getting eact pixel location, average 4 nearest pixels
#
x=250
y=100
d = int(32*sqrt(2)) # maximum theoretical range for a 32x32 on any orientation
# loop over maximal square to quickly emulate relevant parts of the raster scan for the test
for dy in range(-d, d):
    for dx in range(-d, d):
        # assume this point is in the rotated object, lets see where it is in the upright original
        # by rotating it back
        (dxr, dyr) = rot(dx, dy, -30*d2r)
        # does it still falls within the object?
        if abs(dxr) < 32 and abs(dyr) < 32:
            # get integer
            dxri = floor(dxr)
            dyri = floor(dyr)
            # get remaining fraction
            dxrp = dxr-dxri
            dyrp = dyr-dyri
            # top left corner
            loc = (dyri + 32) * 64 + (dxri + 32)
            # get values of 4 nearest pixels around float dxr,dyr
            # use 0 if out of range
            tl = ghost[loc]
            if dxri < 31:
                tr = ghost[loc + 1]
            else:
                tr = 0
            if dyri < 31:
                bl = ghost[loc + 64]
                if dxri < 31:
                    br = ghost[loc + 65]
                else:
                    tr = 0
            else:
                bl = 0
                br = 0
            # average 4 pixels based distance from float coordinate
            pt =  pixel_avg2(tl, tr, dxrp)
            pb =  pixel_avg2(bl, br, dxrp)
            p  =  pixel_avg2(pt, pb, dyrp)
            if int(p) < 0 or int(p) > 4095:
                print(p)
                sys.exit(1)
            pixel(x+dx+32, y+dy+32, int(p), win)

#
# Third image, draw rotated image by doing normal raster scan and getting pixel value from rotated image
# After getting eact pixel location, average 4 nearest pixels
#
x=350
y=100
d = int(32*sqrt(2)) # maximum theoretical range for a 32x32 on any orientation
# loop over maximal square to quickly emulate relevant parts of the raster scan for the test
for dy in range(-d, d):
    for dx in range(-d, d):
        # assume this point is in the rotated object, lets see where it is in the upright original
        # by rotating it back
        (dxr, dyr) = rot(dx, dy, -30*d2r)
        # does it still falls within the object?
        if abs(dxr) < 32 and abs(dyr) < 32:
            # get integer
            dxri = floor(dxr)
            dyri = floor(dyr)
            # get remaining fraction
            dxrp = dxr-dxri
            dyrp = dyr-dyri
            # top left corner
            loc = (dyri + 32) * 64 + (dxri + 32)
            # get values of 4 nearest pixels around float dxr,dyr
            # use 0 if out of range
            tl = ghost[loc]
            if dxri < 31:
                tr = ghost[loc + 1]
            else:
                tr = 0
            if dyri < 31:
                bl = ghost[loc + 64]
                if dxri < 31:
                    br = ghost[loc + 65]
                else:
                    tr = 0
            else:
                bl = 0
                br = 0
            # average 4 pixels based distance from float coordinate
            p =  pixel_avg4(tl, tr, bl, br, dxrp, dyrp)
            if int(p) < 0 or int(p) > 4095:
                print(p)
                sys.exit(1)
            pixel(x+dx+32, y+dy+32, int(p), win)

#
# Fifth image, draw rotated image by doing normal raster scan and getting pixel value from rotated image
# After getting eact pixel location, pick nearest pixel
#
x=450
y=100
d = int(32*sqrt(2)) # maximum theoretical range for a 32x32 on any orientation
# loop over maximal square to quickly emulate relevant parts of the raster scan for the test
for dy in range(-d, d):
    for dx in range(-d, d):
        # assume this point is in the rotated object, lets see where it is in the upright original
        # by rotating it back
        (dxr, dyr) = rot(dx, dy, -30*d2r)
        # does it still falls within the object?
        if abs(dxr) < 32 and abs(dyr) < 32:
            # get integer
            dxri = floor(dxr)
            dyri = floor(dyr)
            # get remaining fraction
            dxrp = dxr-dxri
            dyrp = dyr-dyri
            # top left corner
            loc = (dyri + 32) * 64 + (dxri + 32)
            if dxrp >= 0.5 and dxri < 31:
                loc += 1
            if dyrp >= 0.5 and dyri < 31:
                loc += 64
            p = ghost[loc]
            if int(p) < 0 or int(p) > 4095:
                print(p)
                sys.exit(1)
            pixel(x+dx+32, y+dy+32, int(p), win)

#mySquare = Rectangle(Point(1, 1), Point(9, 9)) # create a rectangle from (1, 1) to (9, 9)
#mySquare.draw(win) # draw it to the window
win.getMouse() # pause before closing
