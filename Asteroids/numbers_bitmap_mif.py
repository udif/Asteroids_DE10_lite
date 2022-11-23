#!/usr/bin/env python

with open("numbers_bitmap_mif.txt") as fin:
    with open("numbers_bitmap.mif", "w") as fout:
        with open("numbers_bitmap.mem", "w") as fout2:
            data = False
            addr = 0
            for l in fin.readlines():
                fout.write(l)
                if data:
                    for d in l[3:-1]:
                        print("{:04x}: {};".format(addr, d), file=fout)
                        print(d, file=fout2)
                        addr += 1
                    continue
                if l.find("CONTENT BEGIN") >=0:
                    data = True
                    continue
