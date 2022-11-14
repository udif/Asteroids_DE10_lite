from tkinter import *
from PIL import ImageTk, Image
from PIL import ImageFilter
import sys

from tkinter import filedialog
import math

#  --onefile BMPConverter.py
# a tool to convert an image to SYSTEM VERILOG bitmap for Lab1 projects
# writen by Noam and DAvid Bar-On  for the elementary lab in the Technion IIT 2021
# (c) Technion IIT 2021

global imgFromFile   # original image as read from file
global imgOriginal   # original size image
global imgBMP # converted and pixelized image
global FileName  # bare file name- without paty and extensions"
global root
global bitsR, bitsG, bitsB, bits
bitsR = 8
bitsG = 8
bitsB = 8
bits = bitsR + bitsG + bitsB

# scales parameters
global bmpScale
global Rlambda, Glambda, Blambda  # color correcting coefficients
global grayThreshold
global Rbits, Gbits, Bbits  # number of bits for each color

# button parameters
global SingleBitBitMap #  select: one or eight bits
global OneBitbutton
SingleBitBitMap = FALSE  # start with 8 bits

global InvertGrayScale
global InvertGrayScalebutton
InvertGrayScale = TRUE

global CropFlag
CropFlag = None

global NoResizeFlag
NoResizeFlag = None

global RotateScale
RotateScale = None

global TL_BMP_Position
TL_BMP_Position = (500,50)
Original_Position = (100,50)

## how to make an exe program
# https://datatofish.com/executable-pyinstaller/
#   CD PYTHON
#   pyinstaller --onefile BMPConverter.py
# take the exe from dist directory

# ______________________________________________________display controls

def selectmouse(v):
    global imgOriginal, imgBMP
    xx = v.x
    yy = v.y  #  get the mousק position in the picture
# get the position in the ROOT array to see the click is only in the BMP window
    abs_coord_x = root.winfo_pointerx() - root.winfo_rootx()
    abs_coord_y = root.winfo_pointery() - root.winfo_rooty()
    mouse = ( root.winfo_pointerx() -  root.winfo_rootx() ,   root.winfo_pointery() -  root.winfo_rooty() )
    cordinate = xx, yy

# if mouse is in BMP screen
    if ( TL_BMP_Position[0] < abs_coord_x ) and ((TL_BMP_Position[0] + imgOriginal.size[0]) > abs_coord_x) and (TL_BMP_Position[1] < abs_coord_y) and ((TL_BMP_Position[1] + imgOriginal.size[1] ) > abs_coord_y):
        print("in Right")

        img256 = imgBMP.resize(imgOriginal.size,Image.Resampling.NEAREST)
        r, g, b = img256.getpixel(cordinate)
        # change pixels on the small imgBMP array
        pixels = imgBMP.load()  # create the pixel map

        for i in range(imgBMP.size[0]):  # for each column
            for j in range(imgBMP.size[1]):  # For each row
                if pixels[i, j][0] == r and pixels[i, j][1] == g and pixels[i, j][2] == b:
                    pixels[i, j] = (0, 0, 0)

        # if mouse is in original screen

    if (Original_Position[0] < abs_coord_x) and ((Original_Position[0] + imgOriginal.size[0]) > abs_coord_x) and ( Original_Position[1] < abs_coord_y) and ((Original_Position[1] + imgOriginal.size[1]) > abs_coord_y):
        print ("in left", cordinate)
        r, g, b = imgOriginal.getpixel(cordinate)
        print (r, g, b)

         # change pixels on the large array
        Opixels = imgOriginal.load()  # create the pixel map
        threshold = 20
        for i in range(imgOriginal.size[0]):  # for each column
            for j in range(imgOriginal.size[1]):  # For each row
                if (math.fabs(Opixels[i, j][0] - r) < threshold ) and (math.fabs(Opixels[i, j][1] - g) < threshold ) and (math.fabs(Opixels[i, j][2] - b) < threshold ):
            #if (math.fabs()Opixels[i, j][0] == r) and (Opixels[i, j][1] == g) and (Opixels[i, j][2] == b):

                    # print("match Left", i,j,Opixels[i, j])
                    Opixels[i, j] = (0,0,0)
        picModify(0)  #  if click on left side
    OriginalpicDisplay()

    BMPpicDisplay()

def picModifyNoArgs():
    picModify(0)

def OpenGUIKeys():
    global bmpScale, ResizeScale
    global Rlambda, Glambda, Blambda  # color correcting coefficients
    global Rbits, Gbits, Bbits  # number of bits for each color
    global OneBitbutton
    global grayThreshold, Threshold_Label
    global InvertGrayScalebutton
    global OriginalImageSize
    global TopCrop, BottomCrop
    global CropFlag, NoResizeFlag, RotateScale

    # sliders
    bmpScale = Scale(root, from_=0, to=6, label="2^scale", variable=IntVar(), command=picModify)
    bmpScale.set(3)
    bmpScale.place(x=0, y=100)

    ResizeScale = Scale(root, from_=0, to=5, label="Mode", variable=IntVar(), command=picModify)
    ResizeScale.set(0)
    ResizeScale.place(x=0, y=250)

    Rotate_Label = Label(root, text="Rotate")
    Rotate_Label.place(x=5, y=380)
    RotateScale = Scale(root, from_=0, to=3, label="Rotate", variable=IntVar(), command=picModify)
    RotateScale.set(0)
    RotateScale.place(x=0, y=400)

    NoResizeFlag = IntVar()
    NoResizeButton = Checkbutton(root, variable=NoResizeFlag, onvalue = 1, offvalue = 0, text="Native Res", command=picModifyNoArgs)
    NoResizeButton.place(x=10, y=60)

    # Crop
    CropFlag = IntVar()
    CropButton = Checkbutton(root, variable=CropFlag, onvalue = 1, offvalue = 0, text="Auto Crop", command=picModifyNoArgs)
    CropButton.place(x=250, y=320)

    #Crop_Label = Label(root, text="Crop")
    #Crop_Label.place(x=410, y=40)

    #TopCrop = Scale(root, from_=0, to=256, variable=IntVar(), command=picModify)
    #TopCrop.set(0)
    #TopCrop.place(x=370, y=60)
    #TopCrop_Label = Label(root, text="Top")
    #TopCrop_Label.place(x=390, y=160)

    #BottomCrop = Scale(root, from_=0, to=256, variable=IntVar(), command=picModify)
    #BottomCrop.set(0)
    #BottomCrop.place(x=430, y=60)
    #BottomCrop_Label = Label(root, text="Bot")
    #BottomCrop_Label.place(x=450, y=160)

    #LeftCrop = Scale(root, from_=0, to=256, variable=IntVar(), command=picModify)
    #LeftCrop.set(0)
    #LeftCrop.place(x=370, y=205)
    #LeftCrop_Label = Label(root, text="Left")
    #LeftCrop_Label.place(x=390, y=185)

    #RightCrop = Scale(root, from_=0, to=256, variable=IntVar(), command=picModify)
    #RightCrop.set(0)
    #RightCrop.place(x=430, y=205)
    #RightCrop_Label = Label(root, text="Right")
    #RightCrop_Label.place(x=445, y=185)

    # gray scale controls
    grayThreshold = Scale(root, from_=0, to=256, variable=IntVar(), command=picModify)
    grayThreshold.set(256)
    grayThreshold.place(x=550, y=350)

    Threshold_Label = Label(root, text="      off")
    Threshold_Label.place(x=550, y=470)

    OriginalImageSize = Label(root, text="")
    OriginalImageSize.place(x=200, y=30)

    InvertGrayScalebutton = Button(root, text="            ", command=InvertSelect)
    InvertGrayScalebutton.place(x=550, y=500)

    # color
    Rlambda = Scale(root, from_=0, to=200, label="            R", orient=HORIZONTAL, variable=IntVar(), command=picModify)
    Rlambda.set(100)
    Rlambda.place(x=400, y=310)

    Glambda = Scale(root, from_=0, to=200, label="            G", orient=HORIZONTAL, variable=IntVar(), command=picModify)
    Glambda.set(100)
    Glambda.place(x=400, y=370)

    Blambda = Scale(root, from_=0, to=200, label="            B", orient=HORIZONTAL, variable=IntVar(), command=picModify)
    Blambda.set(100)
    Blambda.place(x=400, y=430)

    # Number of bits for RGB
    bitsXpos = 650
    Rbits = Scale(root, from_=1, to=8, label="            R", orient=HORIZONTAL, variable=IntVar(), command=RGBpicModify)
    Rbits.set(8)
    Rbits.place(x=bitsXpos, y=310)

    Gbits = Scale(root, from_=1, to=8, label="            G", orient=HORIZONTAL, variable=IntVar(), command=RGBpicModify)
    Gbits.set(8)
    Gbits.place(x=bitsXpos, y=370)

    Bbits = Scale(root, from_=1, to=8, label="            B", orient=HORIZONTAL, variable=IntVar(), command=RGBpicModify)
    Bbits.set(8)
    Bbits.place(x=bitsXpos, y=430)

    #buttons



    Initbutton = Button(root, text="reset To original", command=ResetToOriginal)
    Initbutton.place(x=50, y=320)





    # filters
    BLUR_Button= Button(root, text="BLUR", command=BLURKey)
    BLUR_Button.place(x=100, y=345)

    CONTOUR_Button= Button(root, text="CONTOUR", command=CONTOURKey)
    CONTOUR_Button.place(x=100, y=370)

    DETAIL_Button= Button(root, text="DETAIL", command=DETAILKey)
    DETAIL_Button.place(x=100, y=395)

    EDGE_ENHANCE_Button= Button(root, text="EDGE_ENHANCE", command=EDGE_ENHANCEKey)
    EDGE_ENHANCE_Button.place(x=100, y=420)

    EDGE_ENHANCE_MORE_Button= Button(root, text="EDGE_ENHANCE_1", command=EDGE_ENHANCE_MOREKey)
    EDGE_ENHANCE_MORE_Button.place(x=100, y=445)

    EMBOSS_Button= Button(root, text="EMBOSS", command=EMBOSSKey)
    EMBOSS_Button.place(x=250, y=345)

    FIND_EDGES_Button= Button(root, text="FIND_EDGES", command=FIND_EDGESKey)
    FIND_EDGES_Button.place(x=250, y=370)

    SMOOTH_Button= Button(root, text="SMOOTH", command=SMOOTHKey)
    SMOOTH_Button.place(x=250, y=395)

    SMOOTH_MORE_Button= Button(root, text="SMOOTH_1", command=SMOOTH_MOREKey)
    SMOOTH_MORE_Button.place(x=250, y=420)

    SHARPEN_Button = Button(root, text="SHARPEN", command=SharpenKey)
    SHARPEN_Button.place(x=250, y=445)

    OneBitbutton = Button(root, text="{} bit (press for 1 bit)".format(bits), bg='green', command=SingleBitBitMapSelect)
    OneBitbutton.place(x=50, y=500)

    NewImagebutton = Button(root, text="New image", bg='light blue', command=open_img)
    NewImagebutton.place(x=50, y=550)

    SVFilebutton = Button(root, text="create SV file", bg='light blue', command=writeVerilog)
    SVFilebutton.place(x=300, y=500)

    MIFFilebutton = Button(root, text="create MIF file", bg='light blue', command=writeMif)
    MIFFilebutton.place(x=300, y=550)

    HEXFilebutton = Button(root, text="create readmemh file", bg='light blue', command=writeMem)
    HEXFilebutton.place(x=450, y=550)

    #HEXFilebutton = Button(root, text="create Intel HEX file", bg='light blue', command=writeIHex)
    #HEXFilebutton.place(x=600, y=550)

def RGBpicModify(dummy):
    global bitsR, bitsG, bitsB, bits
    global OneBitbutton

    #if bitsR < Rbits.get() or bitsG < Gbits.get() or bitsB < Bbits.get():
    picModify(0)
    bitsR = Rbits.get()
    bitsG = Gbits.get()
    bitsB = Bbits.get()
    bits = bitsR + bitsG + bitsB
    OneBitbutton.config(text="{} bit (press for 1 bit)".format(bits))

# ____________________________________________________________________________________________________
def InvertSelect():
    # change the flag for inverting single bit BITMAP
    global InvertGrayScale
    global InvertGrayScalebutton

    if SingleBitBitMap :  #  only valid in single bit mode
        InvertGrayScale = not InvertGrayScale
        if InvertGrayScale :
            InvertGrayScalebutton.config(text="invert(off)")
        else :
            InvertGrayScalebutton.config(text="invert(on)")
        picModify(0)


# ____________________________________________________________________________________________________
def SingleBitBitMapSelect():
    # selcet the mode:  8/12 bit or 1 bit
    global SingleBitBitMap
    global OneBitbutton
    global grayThreshold, Threshold_Label
    global  InvertGrayScalebutton

    SingleBitBitMap = not SingleBitBitMap

    if SingleBitBitMap :
        OneBitbutton.config(text="1 bit (press for {} bit)".format(bits),bg='gray')
        Threshold_Label.config(text="gray Threshold")
        InvertGrayScalebutton.config (text="invert(off)")
    else :
        OneBitbutton.config(text="{} bit (press for 1 bit)".format(bits),bg='green')
        Threshold_Label.config(text="      off")
        InvertGrayScalebutton.config(text="            ")
    picModify(0)


# ____________________________________________________________________________________________________

def BMPpicDisplay():
    # print ("BMPicDisplay")
    #  extend the BMP to the original size and display it
    img256 = imgBMP.resize(imgOriginal.size,Image.Resampling.NEAREST)
    img256 = ImageTk.PhotoImage(img256)
    RightImage = Label(root, image=img256)
    RightImage.place (x=TL_BMP_Position[0],y= TL_BMP_Position[1]) # (x=400, y=50)
    RightImage.image = img256

def OriginalpicDisplay():
    #global imgOriginal
   # img255 = imgOriginal.resize(imgOriginal.size,Image.NEAREST)
    IMG255 = ImageTk.PhotoImage(imgOriginal)
    LeftImage = Label(root, image=IMG255)
    LeftImage.place(x=Original_Position[0],y= Original_Position[1])
    LeftImage.image = IMG255


# ____________________________________________________________________________________________________
def writeVerilog():
    pixels = imgBMP.load()
    width, height = imgBMP.size
    OneBitPixelCode = (255, 0, 0)
    file1 = open(FileName + "BitMap.sv", "w")

    if (SingleBitBitMap):
        file1.write("logic[0:{}][0:] object_colors = {{".format(height-1, width-1))
    else:
        file1.write("logic[0:{}][0:][{}:0] object_colors = {{".format(height-1, width-1, bits-1))
    for j in range(height):  # for each column
        if (SingleBitBitMap):
            file1.write("\n\t" + str(width) + "'b")
            for i in range(width):  # For each row
                #BW
                if (pixels[i,j] == OneBitPixelCode) :
                    file1.write('1')
                    pixels[i, j] = (255, 255, 255)
                else:
                    file1.write('0')
                    pixels[i, j] = (0, 0, 0)

            if j < (height - 1):
                file1.write(",")
        else:
            file1.write("\n\t{")
            for i in range(width):  # For each row
                #R...RG...GB...B (determined by bitsR, bitsG, bitsB)
                #   ColorByte=int((pixels[i, j][0]/32)+(pixels[i, j][1]/8)+(pixels[i, j][2])) #  sum the three colors to a BYTE
                red1  =  int(pixels[i,j][0] /(1<<(8-bitsR))) * (1<<(bitsG+bitsB))
                green1 = int(pixels[i,j][1] /(1<<(8-bitsG))) * (1<<bitsB)
                blue1 =  int(pixels[i,j][2] /(1<<(8-bitsB))) * 1

                ColorByte=  red1 + green1 + blue1  # sum the three colors to a BYTE
                file1.write("{}'h".format(bits))
                file1.write(format(ColorByte, '0{}x'.format(math.ceil(bits/4)))) # 4 bits/hex digit, rounded up
                if i < (width -1) :
                    file1.write(",")
            file1.write("}")
            if j < (height - 1):
                file1.write(",")
    file1.write("};\n")
    file1.close()

    # write BMP for additional editing

    outJPGFile = open(FileName + "_piexl.jpg", "w")
    imgBMP.save(outJPGFile)

# ____________________________________________________________________________________________________
def writeMif():
    pixels = imgBMP.load()
    width, height = imgBMP.size
    OneBitPixelCode = (255, 0, 0)
    with open(FileName + "BitMap.mif", "w") as file1:
        file1.write("""
--
-- Generated automatically by BMPConverter.py
--
DEPTH = {};
WIDTH = {};
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT BEGIN
""".format(width*height, bits))
        digits = ((width*height-1).bit_length()+3)//4
        for j in range(height):  # for each column
            for i in range(width):  # For each row
                file1.write("{}: ".format(hex(j*width+i)[2:].upper().zfill(digits)))
                if (SingleBitBitMap):
                    #BW
                    if (pixels[i,j] == OneBitPixelCode) :
                        file1.write('1;\n')
                        pixels[i, j] = (255, 255, 255)
                    else:
                        file1.write('0;\n')
                        pixels[i, j] = (0, 0, 0)
                else:
                    #R...RG...GB...B (determined by bitsR, bitsG, bitsB)
                    #   ColorByte=int((pixels[i, j][0]/32)+(pixels[i, j][1]/8)+(pixels[i, j][2])) #  sum the three colors to a BYTE
                    red1  =  int(pixels[i,j][0] /(1<<(8-bitsR))) * (1<<(bitsG+bitsB))
                    green1 = int(pixels[i,j][1] /(1<<(8-bitsG))) * (1<<bitsB)
                    blue1 =  int(pixels[i,j][2] /(1<<(8-bitsB))) * 1

                    ColorByte=  red1 + green1 + blue1  # sum the three colors to a BYTE
                    file1.write(hex(ColorByte)[2:].upper().zfill((bits+3)//4)+";\n") # 4 bits/hex digit, rounded up
        file1.write("END;\n")

# ____________________________________________________________________________________________________
def writeMem():
    pixels = imgBMP.load()
    width, height = imgBMP.size
    OneBitPixelCode = (255, 0, 0)
    with open(FileName + "BitMap.Mem", "w") as file1:
        digits = ((width*height-1).bit_length()+3)//4
        for j in range(height):  # for each column
            for i in range(width):  # For each row
                if (SingleBitBitMap):
                    #BW
                    if (pixels[i,j] == OneBitPixelCode) :
                        file1.write('1;\n')
                        pixels[i, j] = (255, 255, 255)
                    else:
                        file1.write('0;\n')
                        pixels[i, j] = (0, 0, 0)
                else:
                    #R...RG...GB...B (determined by bitsR, bitsG, bitsB)
                    #   ColorByte=int((pixels[i, j][0]/32)+(pixels[i, j][1]/8)+(pixels[i, j][2])) #  sum the three colors to a BYTE
                    red1  =  int(pixels[i,j][0] /(1<<(8-bitsR))) * (1<<(bitsG+bitsB))
                    green1 = int(pixels[i,j][1] /(1<<(8-bitsG))) * (1<<bitsB)
                    blue1 =  int(pixels[i,j][2] /(1<<(8-bitsB))) * 1

                    ColorByte=  red1 + green1 + blue1  # sum the three colors to a BYTE
                    file1.write(hex(ColorByte)[2:].upper().zfill((bits+3)//4)+"\n") # 4 bits/hex digit, rounded up

    # write BMP for additional editing

    outJPGFile = open(FileName + "_piexl.jpg", "w")
    imgBMP.save(outJPGFile)

def writeIHex():
    pass

# --------------------------------------------

#    - all image filters

def ResetToOriginal():
    global imgOriginal,Rlambda,Glambda,Blambda
    global Rbits, Gbits, Bbits
    imgOriginal = imgFromFile.resize(imgOriginal.size, Image.Resampling.NEAREST)

    Rlambda.set(100)
    Glambda.set(100)
    Blambda.set(100)
    Rbits.set(8)
    Gbits.set(8)
    Bbits.set(8)
    picModify(0)
    OriginalpicDisplay()


def EdgeEnhanceKey():
    global imgOriginal
    imgOriginal = imgOriginal.filter(ImageFilter.EDGE_ENHANCE_MORE)
    picModify(0)


def SharpenKey():
    global imgOriginal
    imgOriginal = imgOriginal.filter(ImageFilter.SHARPEN)
    picModify(0)


def FIND_EDGESKey():
    global imgOriginal
    imgOriginal = imgOriginal.filter(ImageFilter.FIND_EDGES)
    picModify(0)

def SMOOTHKey():
    global imgOriginal
    imgOriginal = imgOriginal.filter(ImageFilter.SMOOTH)
    picModify(0)

def EMBOSSKey():
    global imgOriginal
    imgOriginal = imgOriginal.filter(ImageFilter.EMBOSS)
    picModify(0)

def SMOOTH_MOREKey():
    global imgOriginal
    imgOriginal = imgOriginal.filter(ImageFilter.SMOOTH_MORE)
    picModify(0)

def EDGE_ENHANCE_MOREKey():
    global imgOriginal
    imgOriginal = imgOriginal.filter(ImageFilter.EDGE_ENHANCE_MORE)
    picModify(0)

def EDGE_ENHANCEKey():
    global imgOriginal
    imgOriginal = imgOriginal.filter(ImageFilter.EDGE_ENHANCE)
    picModify(0)

def DETAILKey():
    global imgOriginal
    imgOriginal = imgOriginal.filter(ImageFilter.DETAIL)
    picModify(0)

def CONTOURKey():
    global imgOriginal
    imgOriginal = imgOriginal.filter(ImageFilter.CONTOUR)
    picModify(0)

def BLURKey():
    global imgOriginal
    imgOriginal = imgOriginal.filter(ImageFilter.BLUR)
    picModify(0)


##



##

# ____________________________________________________________________________________________________
def handle_img_size():
    global imgOriginal, imgFromFile
    global img1
    global RotateScale

    imageBox = img1.getbbox()

    if RotateScale and RotateScale.get() > 0:

        rotated = img1.transpose((None, Image.Transpose.ROTATE_270, Image.Transpose.ROTATE_180, Image.Transpose.ROTATE_90)[RotateScale.get()])
    else:
        rotated = img1

    if CropFlag and CropFlag.get():
        cropped = rotated.crop(imageBox)
    else:
        cropped = rotated
    width, height = cropped.size

    #print ( width)
    #print ( height)
    Image_ratio_float = width /  height
    #print ( Image_ratio_float)
    # ratio calculate based on the picture aspect ratio
    Image_ratio_integer= Image_ratio_float * 256

    if Image_ratio_integer > 4900:
        OriginalImageTruncedSize = (256, 8)
    elif Image_ratio_integer > 2500:
        OriginalImageTruncedSize = (256, 16)
    elif Image_ratio_integer > 1200:
        OriginalImageTruncedSize = (256, 32)
    elif Image_ratio_integer > 600:
        OriginalImageTruncedSize = (256,64)
    elif Image_ratio_integer > 300:
        OriginalImageTruncedSize = (256,128)
    elif Image_ratio_integer > 150:
        OriginalImageTruncedSize = (256,256)
    elif Image_ratio_integer > 75:
        OriginalImageTruncedSize = (128, 256)
    elif Image_ratio_integer > 40:
        OriginalImageTruncedSize = (64, 256)
    elif Image_ratio_integer > 20:
        OriginalImageTruncedSize = (32, 256)
    elif Image_ratio_integer > 10:
        OriginalImageTruncedSize = (16, 256)
    else:
        OriginalImageTruncedSize = (8, 256)


     # create the original image,used for all later conversions
    imgFromFile = cropped.resize(OriginalImageTruncedSize,Image.Resampling.NEAREST)
    imgOriginal = imgFromFile.resize(imgFromFile.size, Image.Resampling.NEAREST)
    return (width, height)

def open_img():
    global FileName
    global imgOriginal, imgFromFile
    global imgBMP
    global OriginalImageSize
    global CropFlag
    global img1

    path = "smiley.jpg"
    path = filedialog.askopenfilename( filetypes=[("jpg, bmp, png", '*.jpg *.bmp *.png'),("all files", '*.*')], title="Choose filename")

    img1 = Image.open(path).convert('RGB')

 #  copy
    # get the bare filename for the verilog file
    list = path.split('/')
    pro = list.pop()
    FileName  = pro.split('.')[0]

    # create initial original image and print
    (width, height) = handle_img_size()
    img255 = ImageTk.PhotoImage(imgOriginal)
    LeftImage = Label(root, image=img255)
    LeftImage.place(x=Original_Position[0], y=Original_Position[1])
    LeftImage.image = imgOriginal
    OriginalpicDisplay()

    # create initial BMP image and print
    imgBMP = imgOriginal
    OpenGUIKeys()
    BMPpicDisplay()

    OriginalImageSize.config(text="{}x{}".format(width, height))

    # ____________________________________________________________________________________________________
def picModify(v):
    # Split into 3 channels,  pixilize color t o8 bits, pixelize to imgBMP.size 
    global imgBMP, bmpScale, RotateScale

    (width, height) = handle_img_size()
    global OriginalImageSize
    OriginalImageSize.config(text="{}x{}".format(width, height))

    RotateScale.config(label=RotateScale.get()*90)

    # resize
    BMP_ratio = pow(2, bmpScale.get())
    if not NoResizeFlag or not  NoResizeFlag.get():
        width, height = imgOriginal.size
    BMP_ratio = min(BMP_ratio,width, height)  #  so it is minmal
    imgBMPsize = (int(width / BMP_ratio) ,int ( height / BMP_ratio ))

    # https://pillow.readthedocs.io/en/stable/reference/Image.html   filter types
    #print ("width- ", width,"BMP_ratio- ", BMP_ratio )
    #print ("height- ", height,"BMP_ratio- ", BMP_ratio )
    #print ("imgBMPsize- ", imgBMPsize)
    #imgBMP = imgOriginal.resize(imgBMPsize,Image.NEAREST)
    #imgBMP = imgOriginal.resize(imgBMPsize,Image.BILINEAR)
#    im2 = imgOriginal.filter(ImageFilter.EDGE_ENHANCE_MORE)
 #   im2 = im2.filter(ImageFilter.SHARPEN)
    SizeText = (str(imgBMPsize[0]) + "*" +  str (imgBMPsize[1]))
    bmpScale.config(label=SizeText)
    # Image.NEAREST (0), Image.LANCZOS (1), Image.BILINEAR (2), Image.BICUBIC (3), Image.BOX (4) or Image.HAMMING (5)
    imgBMP = imgOriginal.resize(imgBMPsize,  resample=ResizeScale.get())

    #imgBMP = imgOriginal.resize(imgBMPsize,Image.ANTIALIAS)
    # filters =  https://pillow.readthedocs.io/en/3.0.0/reference/ImageFilter.html#module-PIL.ImageFilter
    # resize = https://pillow.readthedocs.io/en/3.0.0/reference/Image.html

      #  8 bit RGB
    r, g, b = imgBMP.split()

    #r = r.point(lambda i: math.floor(math.floor(i * Rlambda.get() / 100.0 )/ 64 )* 64)
    #g = g.point(lambda i: math.floor(math.floor(i * Glambda.get() / 100.0 )/ 64 )* 64)
    #b = b.point(lambda i: math.floor(math.floor(i * Blambda.get() / 100.0 )/ 128 )* 128)
    r_step = 1 << (8 - Rbits.get())
    g_step = 1 << (8 - Gbits.get())
    b_step = 1 << (8 - Bbits.get())

    r = r.point(lambda i: int(int(i * Rlambda.get() / 100.0 )/ r_step )* r_step)
    g = g.point(lambda i: int(int(i * Glambda.get() / 100.0 )/ g_step )* g_step)
    b = b.point(lambda i: int(int(i * Blambda.get() / 100.0 )/ b_step )* b_step)


    # Recombine back to RGB image
    imgBMP = Image.merge('RGB', (r, g, b))
    #pixels = imgBMP.load()  # create the pixel map
    #for i in range(imgBMP.size[0]):  # for each column
        #for j in range(imgBMP.size[1]):  # For each row
            #print(pixels[i, j])

    # perform only on grayScale image
    if SingleBitBitMap :
        pixels = imgBMP.load()  # create the pixel map
        for i in range(imgBMP.size[0]):  # for each column
            for j in range(imgBMP.size[1]):  # For each row
                gray = int(pixels[i, j][0] * 0.2125 + pixels[i, j][1] * 0.7154 + pixels[i, j][2] * 0.0721)
                if (gray > grayThreshold.get() and InvertGrayScale)  or (gray < grayThreshold.get() and (not InvertGrayScale) ):
                    pixels[i, j] = (255, 0, 0)  # paint in red
                else :
                    pixels[i, j] = (gray, gray, gray)

    BMPpicDisplay()
    OriginalpicDisplay()


# main

# open gui window
root = Tk()  # blank window
theLabel = Label(root, text="Lab 1 Picture to SV bitmap Converter \n (c) Technion IIT July 2021")  # basic text
theLabel.pack()  # display it on the window
root.geometry("800x600+200+0")  # place on screen- size, x,y


open_img()
# print the left Original image

root.bind("<Button-1>", selectmouse)

root.mainloop()


# _______________________________________________________mouse detection_________________________________________________

# ____________________________________________________display original picture____________________________________________
