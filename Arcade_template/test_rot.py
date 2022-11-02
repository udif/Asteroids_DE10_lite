from graphics import *
from math import pi, sin, cos
d2r = pi/180

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

def pixel(x, y, p, win):
    r = Rectangle(Point(x, 479-y), Point(x+1, 479-(y+1)))
    r.setFill(color(p))
    r.setOutline(color(p))
    r.draw(win)

def rot(x, y, th):
    sth = sin(th)
    cth = cos(th)
    return ((x*cth-y*sth), (x*sth+y*cth))

win = GraphWin(width = 1280, height = 960) # create a window
win.setBackground("black")
win.setCoords(0, 0, 639, 479) # set the coordinates of the window; bottom left is (0, 0) and top right is (10, 10)
x=100
y=100
for (i, p) in enumerate(ghost):
    dx = i % 64
    dy = i // 64
    #win.plot(x+dx, 479-(y+dy), color(p))
    pixel(x+dx, y+dy, p, win)

x=200
y=200
for (i, p) in enumerate(ghost):
    dx = i % 64 - 32
    dy = i // 64 - 32
    (dxr, dyr) = rot(dx, dy, 30*d2r)
    #win.plot(x+dx, 479-(y+dy), color(p))
    pixel(x+dxr+32, y+dyr+32, p, win)

x=300
y=300
for (i, p) in enumerate(ghost):
    (_, miny) = map(int, rot(32, -32, 30*d2r))
    (_, maxy) = map(int, rot(-32, 32, 30*d2r))
    (minx, _) = map(int, rot(-32, -32, 30*d2r))
    (maxx, _) = map(int, rot(32, 32, 30*d2r))
    print((minx, miny), (maxx, maxy))
    mySquare = Rectangle(Point(x+minx, y+miny), Point(x+maxx, y+maxy)) # create a rectangle from (1, 1) to (9, 9)
    mySquare.setFill("white")
    mySquare.draw(win) # draw it to the window
    for dx in range(minx, maxx):
        for dy in range(miny, maxy):
            (dxr, dyr) = map(int, rot(dx, dy, -30*d2r))
            if abs(dxr - dx)< 32 and abs(dyr-dy) < 32:
                p = ghost[(dyr-dy+32)*64+(dxr-dx+32)]
                pixel(x+dxr+32, y+dyr+32, p, win)

#mySquare = Rectangle(Point(1, 1), Point(9, 9)) # create a rectangle from (1, 1) to (9, 9)
#mySquare.draw(win) # draw it to the window
win.getMouse() # pause before closing
