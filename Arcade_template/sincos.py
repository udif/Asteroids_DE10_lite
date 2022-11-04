#!/usr/bin/env python3

from math import ceil, sin, cos, pi
import sys

# math.sin works in radians: 0-90° == π/2 radians

if (len(sys.argv) > 1):
    rows = int(sys.argv[1])
else:
    rows = 256

if (len(sys.argv) > 2):
    width = int(sys.argv[2])
else:
    width = 18
with open("sincos.mif", "w") as f_mif:
    with open("sincos.mem", "w") as f_mem:
        print("""
-- Generated by sincos.py
-- Loosely inspired by Project F
-- https://projectf.io/posts/fpga-sine-table/
-- Learn more at https://github.com/projf/fpgatools
--
-- Heavily modified by Udi Finkelstein
-- Generate MIF table
-- Generate Pi/2 sincos instead of 2*PI sin
-- Upper {} bits are sin(0..Pi/2-eps)
-- Lower {} bits are cos(0..Pi/2-eps)
--
DEPTH = {};
WIDTH = {};
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT BEGIN
""".format(width, width, rows, 2*width), file=f_mif)
        addr_digits = ((rows-1).bit_length()+3)//4

        # actual value bits (1 less than width due to sign)
        val_bits = width - 1
        for i in range(rows):
            val = (pi/2/rows) * i
            sinval = sin(val)
            cosval = cos(val)
            # while we could use all ROM bits for value and infer sign outside,
            # we don't bother because MAX10 ROMS are same size as multiplier inputs,
            # so even if we gain 1 more bit, we can't use it with the multiplier
            sin_scaled = round((2**val_bits) * sinval)
            cos_scaled = round((2**val_bits) * cosval)
            if sin_scaled == 2**val_bits:  # maximum value uses too many bits
                sin_scaled -= 1;           # saturate
            if cos_scaled == 2**val_bits:  # maximum value uses too many bits
                cos_scaled -= 1;           # saturate
            sincos = (sin_scaled << width) + cos_scaled
            print("{}: ".format(hex(i)[2:].upper().zfill(addr_digits)), end="", file=f_mif)
            print(hex(sincos)[2:].upper().zfill((2*width+3)//4)+";", file=f_mif) # 4 bits/hex digit, rounded up
            print(hex(sincos)[2:].upper().zfill((2*width+3)//4), file=f_mem) # 4 bits/hex digit, rounded up
        print("END;", file=f_mif)