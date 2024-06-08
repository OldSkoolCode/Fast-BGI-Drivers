;{----------------------------------------------------------------------}
;{	FILE: TSENG.ASM							}
;{									}
;{	COPYRIGHT 1993 FUTURESCAPE PRODUCTIONS				}
;{									}
;{	PURPOSE: Device Driver Overlay (DDO) for the TSENG SVGA driver	}
;{          This file defines the vector table at the beginning.	}
;{	    								}
;{	This file support EGA/VGA planar graphics modes			}
;{									}
;{	Current Date: 08/27/93						}
;{									}
;{	Updates:      None.						}
;{----------------------------------------------------------------------}

		locals

        	include	bgidev.inc	; File defines vector table format
;
; -----	Equates section
;
MODE_640x350x256	equ	2dh
MODE_640x200x16		equ	0eh
MODE_640x350x2		equ	0fh
MODE_640x350x16		equ	10h
MODE_640x480x2		equ	11h
MODE_640x480x16		equ	12h

VIDEOIO		equ	10h
MAXCOLORS	equ	16
MAXVREZ		EQU	768
;
;
;
VIDEOSTATE	equ	0fh
;
;  Read vga DAC palette function
;
VGAPAL		equ	10h
;
;  Sub-functions for VGAPAL function
;
SETPALREG	equ	0
SETOVERSCAN	equ	1
SETREGBLOCK	equ	2
READREGBLOCK	equ	9
SETDACBLOCK	equ	12H
SETDACREG	equ	10h
READDACBLOCK	equ	17h
TSENGPAGEREG	equ	3cdh
;
; -----	Character Generator Functions
;
CHARGENFUNC	equ	11H
;
; ----- Sub-functions for character generator functions
;
CHARINFO	equ	30h

;
; ----- modes for writes
;
REPLACE_MODE	equ	0
XOR_MODE	equ	1
OR_MODE		equ	2
AND_MODE	equ	3
XPARENT_MODE	equ	4
;
;

FALSE		equ	0
TRUE		equ	1
;
;
;
CR		equ	13
LF		equ	10
;
;
;
MAXMODES	equ	6
;
; -----	VGA register equates
;
MAX_SCAN_LINE	equ	9
UNDERLINEREG	equ	14h

;
; -----	Some EGA/VGA register locations
;
EGAATTR		equ	3c0h
EGAGRAPH	equ	3ceh
EGASEQ		equ	3c4h
CRTCSTAT 	equ	3dah
CRTC		equ	3d4h
CRTPROPAGE	equ	3dfh
VGADACREAD	equ	3c7h
VGADACWRITE	equ	3c8h
;
; ----- Some EGA/VGA register #'s
;
MAPMASKREG	equ	2
DATAROTATE	equ	3
READMAPREG	equ	4
MODEREG		equ	5
BITMASKREG	equ	8


;
; -----	Code section
;
;

_TEXT   	SEGMENT PARA PUBLIC 'CODE'

        	ASSUME  DS:_TEXT, CS:_TEXT

        	BGI     TSENGSVGA

DDOVEC  	label	word

		dw      install	; Driver initialization and installation
				; Input:    AX=Command #   CX = Parameter
				; Output:   Varies according to command

		dw      init	; Initialize device for output
				; Input:    ES:BX points to information table
				; Output:   None

        	dw      clear	; Clear graphics device and ready it for new
				; output. (Clear Screen, Load Paper, ... )
				; Input:    None
				; Output:   None

		dw      post	; Post - Make picture visible. Enable screen,
				; print paper, eject current sheet, ...
				; Input:    None
				; Output:   None

		dw      move	; Set Current Drawing Pointer to value.
				; Input:    AX = X coord,  BX = Y Coord
				; Output:   None

		dw      draw	; Draw a line from the Current Pointer to
				; the given coordinate.
				; Input:    AX = X coord,  BX = Y Coord
				; Output:   None

		dw      vect	; Draw a vect between the given coordinate
				; pairs.
				; Input:    AX = X Start,  BX = Y Start
				;           CX = X End,    DX = Y End
				; Output:   None

		dw      EMULATE	; Emulated polygon

		dw      bar	; Draw a filled rectangle with the CP as the
				; Lower Left corner, and the given coordinate
				; as the upper right.
				; Input:    AX = X Corner  BX = Y Corner
				;           CX = Depth for #D bars
				;           DX = Draw Top Flag (DX<>0 Draw Top)
				; Output:   None

	        dw      patbar	; Draw a patterned rectangle with the given
				; coorinate pair. The pattern is provided by
				; the set fill pattern entry.
				; Input:    AX = X Corner  BX = Y Corner
				;           CX = X Corner  DX = Y Corner
				; Output:   None

		dw      arc	; Draw an elliptical arc from the given start
				; angle to the given end angle, using the CP
				; as the Center Point, and the given X and Y
				; Radii. Angles are 0-360 degrees.
				; Input:    AX = Start Angle  BX = End Angle
				;           CX = X radius of arc
				;           DX = Y radius of arc
				; Output:   None

		dw      pieslice 	; Draw an elliptical sector from the given start
				; angle to the given end angle, using the CP
				; as the Center Point, and the given X and Y
				; Radii. Angles are 0-360 degrees.
				; Input:    AX = Start Angle  BX = End Angle
				;           CX = X radius of arc
				;           DX = Y radius of arc
				; Output:   None

		dw      filled_ellipse	; Draw an ellipse using the CP as the Center
				; Point, and the given X and Y radii.
				; Input:    AX = X Radius of ellipse
				;           BX = Y Radius of ellipse
				; Output:   None

	        dw      palette	; Set a palette entry to a given color.
				; Input:    AX = Index and Command Code
				;           BX, CX, DX as needed
				; Output:   None

		dw      allpalette	; Load the palette with a table of colors.
				; Input:    ES:BX = Palette Table to load
				; Output:   None

		dw      color	; Set the palette indexs for the current
				; drawing color and the current fill color.
				; Input:    AL = Drawing Color
				;           AH = Fill color
				; 	    BL = Transparent Color
				; Output:   None

		dw      fillstyle	; Set current fill pattern. The fill pattern is
				; set to the pattern specified. If the pattern
				; number is -1 then the pattern is define in
				; a user supplied array.
				; Input:    AL = Pattern # (-1 for user def)
				;           ES:BX = User pattern data if needed
				; Output:   None

	        dw      vectstyle	; Set current vect style. The vect style is
				; set to the style specified. If the style
				; number is -1 then the style is define in
				; a user supplied pattern.
				; Input:    AL = Style # (-1 for user def)
				;           BX = User vect Pattern
				;           CX = vect Width (1 or 3)
				; Output:   None

		dw      textstyle	; Set the text attributes for font rendering
				; Input:    AL = Font Number
				;           AH = Font Path and Direction
				;           BX = Desired X Character Size
				;           CX = Desired Y Character Size
				; Output:   BX = Actual X Character Size
				;           CX = Actual Y Character Size

		dw      text	; Draw a string in the current font with the
				; justification point at the CP.
				; Input:    ES:BX = Pointer to string
				;           CX    = String Length

		dw      textsize ; Calculate the dimensions (in pixels) of an
				; input text string.
				; Input:    ES:BX = Pointer to string
				;           CX    = String Length
				; Output:   BX    = Width of string
				;           CX    = Height of string

		dw      RESERVED	; RESERVED

		dw      floodfill	; Do a floodfill in the current color using
				; the given (X,Y) address as the seed.
				; Input:    AX = X Coord  BX = Y Coord
				; Output:   None.

		dw      getpixel	; Read a pixel from the given coord.
				; Input:    AX = X Coord  BX = Y Coord
				; Output:   DL = Pixel value read

		dw      setpixel	; Write a pixel to the given coord.
				; Input:    AX = X Coord  BX = Y Coord
				;           DL = Pixel value read
				; Output:   None.


		dw      bitmaputil	; Return a pointer to a table of misc driver
				; utilities. The following describes the table.
				; Input:    None.
				; Output:   ES:BX = Base of table
				;
				;       dw GOTOGRAPHIC
				;       dw EXITGRAPHIC
				;       dw PUTPIX
				;       dw GETPIX
				;       dw (BITS PER PIXEL)
				;       dw SETPAGE
				;       dw SETVISUAL
				;       dw SETWRITEMODE

		dw      savebitmap	; Save a portion of the screen to CPU memory.
				; Input:    ES:BX = Pointer to CPU buffer
				;           SI    = Start X coord of save block
				;           DI    = Start Y coord of save block
				;           CX    = End X coord of save block
				;           DX    = End Y coord of save block
				; Output:   (In Save Block)

		dw      restorebitmap	; Restore a portion of the screen from CPU memory.
				; Input:    ES:BX = Pointer to CPU buffer
				;           SI    = Start X coord of save block
				;           DI    = Start Y coord of save block
				;           CX    = End X coord of save block
				;           DX    = End Y coord of save block
				;           AL    = Write mode for block writing
				;		Modes
				;		    0	= replace mode
				;		    1	= xor mode
				;		    2	= or mode
				;		    3	= and mode
				;		    4	= transparent mode
				; Output:   None.

		dw      setclip	; Set the clipping window to the rectangle
				; defined by the two (X,Y) pairs
				; Input:    AX = Upper Left X coord
				;           BX = Upper Left Y coord
				;           CX = Lower Right X coord
				;           DX = Lower Right Y coord
				; Output:   None.

		dw      color_query	; Return the parameters of the device color
				; table (Size, Default Palette, etc)
				; Input:    AL = Command for query
				; Output:   As required per command.

		dw     35 DUP (NONE)    ; Reserved Entry Points

uservectors	label	word
		dw	copyraster
				;
				;
				;
		dw	getpageaddress
				;
				;
				;
		dw	setpageaddress
				;
				;
				;
		dw	getpixelshift
				;
				;
				;

bitmaputilvecs	label word
		dw	gotographic
		dw	exitgraphic
		dw	farputpixel
		dw	fargetpixel
		dw	bitsperpixel
		dw	setpage
		dw	setvisual
		dw	setwritemode

screen_adr	dd	0a0000000h
screen2_adr	dd	?
DCTable		db	?
DCTableEntries	db	MAXCOLORS dup (?)
YTable		dw	MAXVREZ dup (?)
PageTable	db	MAXVREZ dup (?)

transparent	db	255
fillcolor	db	0
drawcolor	db	0
backcolor	db	0
oldVideoMode	db	0
deldAdd		dw	?
delsAdd		dw	?

writemode	dw	REPLACE_MODE		; current writing mode

LMaskTable	db	0ffh,07fh,03fh,01fh,0fh,07h,03h,01h
RMaskTable	db	0ffh,80h,0c0h,0e0h,0f0h,0f8h,0fch,0feh

xMin		dw	?
yMin		dw	?
xMax		dw	?
yMax		dw	?
xCp		dw	?
yCp		dw	?
topAdjust	dw	?
leftAdjust	dw	?
rightAdjust	dw	?
;
; ----- Vector data
;
vectWidth	dw	1
vectPattern	dw	1111111111111111b
vectStdPatterns	dw	1111111111111111b
		dw	1100110011001100b
		dw	1111110001111000b
		dw	1111100011111000b

;
; -----	Pattern Bar fill data
;
PatternStdFill 	db	8 dup(0),8 dup(0FFh),2 dup(0,0FFh,0FFh,0)  ; Empty, Solid, vect
         	db	080h,040h,020h,010h,008h,004h,002h,001h    ; LtSlash
         	db	0C1h,0E0h,070h,038h,01Ch,00Eh,007h,083h    ; Slash
         	db	083h,007h,00Eh,01Ch,038h,070h,0E0h,0C1h    ; BkSlash
         	db	001h,002h,004h,008h,010h,020h,040h,080h    ; LtBkSlash
         	db	4 dup(8),0FFh,3 dup(8)                     ; Hatch
         	db	2 dup(081h,042h,024h,018h)                 ; XHatch
         	db	4 dup(055h,0AAh)                           ; Interleave
         	db	4 dup(0),080h,3 dup(0)                     ; WideDot
         	db	2 dup(088h,0,044h,0)                       ; CloseDot

PatternFill	db	20h,20h,0FFh,20h,20h,20h,20h,20h
EndPatternFill	equ	$

;
; ----- Text font data 
;
textPointer	dd	?
textWidth	dw	?
textHeight	dw	?
EscapeUnderLine	db	'~'
underLineOn	db	FALSE

;
; ----- Initialization data
;

descText1	db    19,"640 x 350 256 Color",0
descText2	db    25,"640 x 200 16 Color Planar",0
descText3	db    20,"640 x 350 Monochrome",0
descText4	db    25,"640 x 350 16 Color Planar",0
descText5	db    17,"640 x 480 2 Color",0
descText6	db    26,"640 x 480 16 Color Planar",0


descTable1	$status	<0, 0, 639, 349, 639, 349, 7000, 8750, 8333, 808h, 9090h>
descTable2	$status	<0, 0, 639, 199, 639, 199, 7000, 8750, 8333, 808h, 9090h>
descTable3	$status	<0, 0, 639, 349, 639, 349, 7000, 8750, 8333, 808h, 9090h>
descTable4	$status	<0, 0, 639, 349, 639, 349, 7000, 8750, 8333, 808h, 9090h>
descTable5	$status	<0, 0, 639, 479, 639, 479, 7000, 8750, 8333, 808h, 9090h>
descTable6	$status	<0, 0, 639, 479, 639, 479, 7000, 8750, 8333, 808h, 9090h>

ByteWidths	dw	640
		dw	320
		dw	80
		dw	320
		dw	80
		dw	320

InstalledTable	dw	?
VideoMode	dw	?

descTabPtrs	dw	descTable1, descTable2, descTable3
		dw	descTable4, descTable5, descTable6
descTextPtrs	dw	descText1, descText2, descText3
		dw	descText4, descText5, descText6

;
; -----	Video Mode switching routines
;
VidModes	dw	MODE_640x350x256
		dw	MODE_640x200x16
		dw	MODE_640x350x2
		dw	MODE_640x350x16
		dw	MODE_640x480x2
		dw	MODE_640x480x16

;
; -----	Raster operations for restore bitmap
;
;
rasterOp	dw	rastMove
         	dw	rastXor
		dw	rastOr
		dw	rastAnd
		dw	rastXParent

;
; -----	Horizontal line draw routines
;
HLineRtns	dw	HLineReplace
		dw	HLineXor
		dw	HLineOr
		dw	HlineAnd
		dw	HLineXParent

;
; -----	Horizontal line draw routines
;
VLineRtns	dw	VLineReplace
		dw	VLineXor
		dw	VLineOr
		dw	VlineAnd
		dw	VLineXParent
;
; ----- Line draw routines
;
LineRtns	dw	LineReplace
		dw	LineXor
		dw	LineOr
		dw	LineAnd
		dw	LineXParent

;
; ----- Text draw routines
;
TextRtns	dw	TextReplace
		dw	TextXor
		dw	TextOr
		dw	TextAnd
		dw	TextXParent

;
; ----- Text underline routines
;
UnderLineRtns	dw	ULReplace
		dw	ULXor
		dw	ULOr
		dw	ULAnd
		dw	ULXParent

;
; ----- Text draw routines
;
PatBarRtns	dw	PatBarReplace
		dw	PatBarXor
		dw	PatBarOr
		dw	PatBarAnd
		dw	PatBarXParent

;
; ----- Text draw routines
;
PixelRtns	dw	PixelReplace
		dw	PixelXor
		dw	PixelOr
		dw	PixelAnd
		dw	PixelXParent

;{----------------------------------------------------------------------}
;{	install:							}
;{	  install the driver						}
;{									}
;{	parameters:							}
;{	  al = 0 cx = mode number					}
;{	       command return Device Status Table in es:bx 		}
;{	  al = 1 cx = number of modes supported by this driver		}
;{	  al = 2 es:bx = Pascal string for name of Driver		}
;{----------------------------------------------------------------------}
install		proc	near

		cmp	al,1			; return # video modes support
		jne	try2
		mov	cx,6
		ret
try2:
		push	cs
		pop	es			; setup es = cs
		cmp	al,2
		jne	misc
		mov	bx,cx
		and	ax,0ffh
		cmp	bx,MAXMODES
		jl	@@modeOK1
		xor	bx,bx
@@modeOK1:
		shl	bx,1
		mov	bx,[bx+descTextPtrs]	; text description of driver
		ret
misc:
		mov	bx,cx
		and	bx,0ffh
		cmp	bx,MAXMODES
		jl	@@modeOK2
		xor	bx,bx
@@modeOK2:
		mov	VideoMode,bx
		shl	bx,1
		mov	bx,[bx+descTabPtrs]
		mov	InstalledTable,bx
		ret

install		endp

;{----------------------------------------------------------------------}
;{	init:								}
;{	  initialize the video card to graphics mode			}
;{									}
;{	parameters:							}
;{	  es:bx = Device Information Table pointer			}
;{----------------------------------------------------------------------}
init		proc	near

		push	si
		push	di
		push	ds
		push	es
		mov	al,es:[bx].$backcolor
		mov	backcolor,al
		cmp	es:[bx].$initflag,0a5h
		jne	@@DoInit
		jmp	@@initAllDone
@@DoInit:
		mov	ah,VIDEOSTATE
		int	VIDEOIO
		mov	oldVideoMode,al
		mov	bx,videoMode
		shl	bx,1
		mov	ax,[bx+VidModes]	; get into video mode
		mov	di,[bx+ByteWidths]
		int	VIDEOIO			; through bios
		mov	ax,(CHARGENFUNC SHL 8) or CHARINFO
		mov	bh,1			; ask BIOS for character set
		int	VIDEOIO
		mov	textWidth,8
		mov	textHeight,cx 		; save width & height
		mov	word ptr textPointer,bp	; save pointer to character set
		mov	word ptr textPointer+2,es
		xor	bx,bx
		mov	dx,offset DCTableEntries ; get EGA color table?
		push	cs
		pop	es
		mov	ax,((VGAPAL SHL 8) OR READREGBLOCK)
		int	VIDEOIO			; thru video bios
		mov	ax,80ffh
		mov	bx,-1
		mov	cx,-1
		mov	dx,-1
		call	palette			; set default palette
		mov	si,InstalledTable
		xor	ax,ax
		xor	bx,bx
		mov	cx,cs:[si].$xres
		mov	dx,cs:[si].$yres	; set clip to default
		call	near ptr setclip
		mov	cx,cs:[si].$yres	; get y resolution
		inc	cx
		mov	bx,di
		mov	di,offset YTable
		mov	si,offset PageTable
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		xor	ax,ax			; build y table lookup
		mov	dx,40h			; initial page setting
@@BuildYtab:
		stosw
		mov	[si],dl
		inc	si
		add	ax,bx
		jnc	@@NotNextPage
		add	dx,39h
@@NotNextPage:
		loop	@@BuildYtab
@@initAllDone:
		pop	es
		pop	ds
		pop	di
		pop	si
		ret

init		endp

;{----------------------------------------------------------------------}
;{	clear:								}
;{	  clear the screen						}
;{----------------------------------------------------------------------}
clear		proc	near

		push	si
		push	di
		push	es

		mov	si,InstalledTable

		mov	di,word ptr screen_adr	; get to screen address
		mov	es,word ptr screen_adr+2

		mov	al,backcolor
		mov	ah,al
		mov	dx,cs:[si].$yres	; height of screen
@@cHeightLoop:
		mov	cx,cs:[si].$xres	; width of screen
		shr	cx,1
		rep	stosw			; clear rectangle
		dec	dx
		jne	@@cHeightLoop
		pop	es
		pop	di
		pop	si
		ret

clear		endp


;{----------------------------------------------------------------------}
;{	move:								}
;{	  move current Pointer to x,y					}
;{									}
;{	parameters:							}
;{	  ax = x position						}
;{	  bx = y position						}
;{----------------------------------------------------------------------}
move		proc	near

		mov	xCp,ax			; set x & y current position
		mov	yCp,bx
		ret

move		endp


;{----------------------------------------------------------------------}
;{	HorizontalLine:							}
;{	  draw quick horizontal lines					}
;{									}
;{	parameters:							}
;{	  ax = x1							}
;{	  bx = y1							}
;{	  cx = x2							}
;{	  vectPattern = 16 bit line pattern				}
;{	  drawcolor = color for line					}
;{----------------------------------------------------------------------}
HorizontalLine	Proc	Near

		call	near ptr ClipRect	; clip the line
		jnc	@@NotFullyClipped
		ret
@@NotFullyClipped:
		push	di
		push	es
		cmp	ax,cx			; see if x1 < x2
		jle	@@LeftToRight
		xchg	ax,cx			; else exchange
@@LeftToRight:
		les	di,screen_adr		; get screen address
		add	di,ax			; and in x offset
		sub	cx,ax			; get width in pixels
		inc	cx
		mov	al,[bx+PageTable]
		mov	dx,TSENGPAGEREG
		out	dx,al
		shl	bx,1
		add	di,cs:[bx+YTable]	; add in y offset
		mov	ah,drawcolor
		mov	al,ah
		mov	dx,vectPattern		; and pattern
		cmp	dx,-1
		jne	@@HNotSolidLoop		; if solid use faster method
		cmp	writemode,REPLACE_MODE	; and replace mode
		je	HSolidLoop
@@HNotSolidLoop:
		mov	bp,writemode
		shl	bp,1
		jmp	cs:[bp+HLineRtns]	; else jump to correct routine

HorizontalLine	Endp

;{----------------------------------------------------------------------}
;{	Draw horizontal line with replace				}
;{	dx = pattern to write						}
;{	bx = first bit mask						}
;{	si = last bit mask						}
;{----------------------------------------------------------------------}
HLineReplace	Proc	near

		xor	al,al			; assume color 0 pixel
		rol	dx,1
		jnc	@@HSkipPix		; use it if no mask
		mov	al,ah			; load in color
@@HSkipPix:
		stosb
		loop	HLineReplace
		pop	di
		pop	es
		ret

HLineReplace	Endp

;{----------------------------------------------------------------------}
;{	Draw horizontal line with xor					}
;{----------------------------------------------------------------------}
HLineXor	Proc	near

		xor	al,al			; assume color 0 pixel
		rol	dx,1
		jnc	@@HSkipPix		; use it if no mask
		mov	al,ah			; load in color
@@HSkipPix:
		xor	es:[di],al
		inc	di
		loop	HLineXor
		pop	di
		pop	es
		ret

HLineXor	Endp

;{----------------------------------------------------------------------}
;{	Draw horizontal line with or					}
;{----------------------------------------------------------------------}
HLineOr		Proc	near

		xor	al,al			; assume color 0 pixel
		rol	dx,1
		jnc	@@HSkipPix		; use it if no mask
		mov	al,ah			; load in color
@@HSkipPix:
		or	es:[di],al
		inc	di
		loop	HLineOr
		pop	di
		pop	es
		ret

HLineOr		Endp

;{----------------------------------------------------------------------}
;{	Draw horizontal line with and					}
;{----------------------------------------------------------------------}
HLineAnd	Proc	Near

		xor	al,al			; assume color 0 pixel
		rol	dx,1
		jnc	@@HSkipPix		; use it if no mask
		mov	al,ah			; load in color
@@HSkipPix:
		and	es:[di],al
		inc	di
		loop	HLineAnd
		pop	di
		pop	es
		ret

HLineAnd	Endp

;{----------------------------------------------------------------------}
;{	Draw horizontal line with transparency				}
;{----------------------------------------------------------------------}
HLineXParent	Proc	Near

		rol	dx,1
		jnc	@@HSkipPix		; use it if no mask
		mov	es:[di],al
@@HSkipPix:
		inc	di
		loop	HLineXParent
		pop	di
		pop	es
		ret

HLineXParent	Endp

;{----------------------------------------------------------------------}
;{	Draw horizontal line with replace really, really fast		}
;{----------------------------------------------------------------------}
HSolidLoop	Proc	Near

		shr	cx,1			; do quick horizontal line
		rep	stosw
		adc	cx,cx
		rep	stosb

		pop	di
		pop	es
		ret

HSolidLoop	Endp

;{----------------------------------------------------------------------}
;{	VerticalLine:							}
;{	  draw quick horizontal lines					}
;{									}
;{	parameters:							}
;{	  ax = x1							}
;{	  bx = y1							}
;{	  dx = y2							}
;{	  vectPattern = 16 bit line pattern				}
;{	  drawcolor = color for line					}
;{----------------------------------------------------------------------}
VerticalLine	Proc	Near

		call	near ptr ClipRect	; clip the rectangle
		jnc	@@NotFullyClipped
		ret
@@NotFullyClipped:
		push	di
		push	es
		cmp	bx,dx
		jle	@@TopToBottom
		xchg	bx,dx
@@TopToBottom:
		les	di,screen_adr		; get screen address
		add	di,ax			; and in x offset
		mov	cx,dx
		sub	cx,bx			; get height in pixels
		inc	cx
		mov	al,[bx+PageTable]
		mov	dx,TSENGPAGEREG
		out	dx,al
		shl	bx,1
		add	di,cs:[bx+YTable]	; add in y offset
		mov	bx,cs:Ytable+2		; next y offset
		mov	ah,drawcolor
		mov	al,ah
		mov	dx,vectPattern		; and pattern
		cmp	dx,-1
		jne	@@VNotSolidLoop		; if solid user faster method
		cmp	writemode,REPLACE_MODE
		jne	@@VNotSolidLoop
		jmp	VSolidLoop
@@VNotSolidLoop:
		mov	bp,writemode
		shl	bp,1
		jmp	cs:[bp+VLineRtns]

VerticalLine	Endp

;{----------------------------------------------------------------------}
;{	Draw vertical line with replace					}
;{----------------------------------------------------------------------}
VLineReplace	Proc	near

		dec	bx
@@VRLoop:
		xor	al,al			; assume color 0
		rol	dx,1
		jnc	@@VSkipPix		; see if pixel wanted
		mov	al,ah			; yep
@@VSkipPix:
		stosb
		add	di,bx			; next line vertical
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		loop	@@VRLoop
		pop	di
		pop	es
		ret

VLineReplace	Endp

;{----------------------------------------------------------------------}
;{	Draw vertical line with xor					}
;{----------------------------------------------------------------------}
VLineXor	Proc	near

		xor	al,al			; assume color 0
		rol	dx,1
		jnc	@@VSkipPix		; see if pixel wanted
		mov	al,ah			; yep
@@VSkipPix:
		xor	es:[di],al
		add	di,bx			; next line vertical
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		loop	VlineXor
		pop	di
		pop	es
		ret

VLineXor	Endp

;{----------------------------------------------------------------------}
;{	Draw vertical line with or					}
;{----------------------------------------------------------------------}
VLineOr		Proc	Near

		xor	al,al			; assume color 0
		rol	dx,1
		jnc	@@VSkipPix		; see if pixel wanted
		mov	al,ah			; yep
@@VSkipPix:
		or	es:[di],al
		add	di,bx			; next line vertical
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		loop	VlineOr
		pop	di
		pop	es
		ret

VLineOr		Endp

;{----------------------------------------------------------------------}
;{	Draw vertical line with and					}
;{----------------------------------------------------------------------}
VLineAnd	Proc	Near

		xor	al,al			; assume color 0
		rol	dx,1
		jnc	@@VSkipPix		; see if pixel wanted
		mov	al,ah			; yep
@@VSkipPix:
		and	es:[di],al
		add	di,bx			; next line vertical
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		loop	VlineAnd
		pop	di
		pop	es
		ret

VLineAnd	Endp

;{----------------------------------------------------------------------}
;{	Draw vertical line with transparency				}
;{----------------------------------------------------------------------}
VLineXParent	Proc	Near

		rol	dx,1
		jnc	@@VSkipPix		; see if pixel wanted
		mov	es:[di],al
@@VSkipPix:
		add	di,bx			; next line vertical
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		loop	VlineXParent
		pop	di
		pop	es
		ret

VLineXParent	Endp

;{----------------------------------------------------------------------}
;{	Draw vertical line with replace really, really fast		}
;{----------------------------------------------------------------------}
VSolidLoop	Proc	Near

		dec	bx
@@VSLoop:
		stosb
		add	di,bx			; quicker loop vertical
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		loop	@@VSLoop

		pop	di
		pop	es
		ret

VSolidLoop	Endp

;{----------------------------------------------------------------------}
;{	draw:								}
;{	  draw line from current pointer (x,y) to x2,y2			}
;{									}
;{	parameters:							}
;{	  ax = x2							}
;{	  bx = y2							}
;{----------------------------------------------------------------------}
draw		proc	near

		mov	cx,ax
		mov	dx,bx
		xchg	ax,xCp			; set up x1, y1, x2, y2
		xchg	bx,yCp

draw		endp

;{----------------------------------------------------------------------}
;{	vect: 								}
;{	  draw vector line						}
;{	  ax = x1 start position					}
;{	  bx = y1							}
;{	  cx = x2 destination position					}
;{	  dx = y2							}
;{----------------------------------------------------------------------}
vect		proc	near

		cmp	ax,cx			; can we do fast vertical
		jne	@@NotVerticalLine
		jmp	VerticalLine
@@NotVerticalLine:
		cmp	bx,dx
		jne	BresenhamLine		; what about fast horizontal
		jmp	HorizontalLine

vect		Endp

;{----------------------------------------------------------------------}
;{	BresenhamLine:							}
;{	  ax = x1 start position					}
;{	  bx = y1							}
;{	  cx = x2 destination position					}
;{	  dx = y2							}
;{----------------------------------------------------------------------}

BresenhamLine	Proc	Near

		push	di
		push	es

		mov	es,word ptr screen_adr+2 ; get screen base address
		mov	si,cs:[YTable+2]	; initial y direction
		mov	di,1			; and x direction
		sub	dx,bx			; subtract y1 from y2
		jge	storey			; skip if y2-y1 is nonnegative
		neg	si			; negative y direction
		neg	dx			; absolute value of y2-y1
storey:
		mov	deldAdd,si
		sub	cx,ax			; subtrack x1
		jge	storex			; skip if x2-x1 is postive
		neg	di			; make negative x direction
		neg	cx			; absolute value of cx
storex:
		add	deldAdd,di
		cmp	cx,dx			; compare dels with delp
		jge	setdiag			; skip if straight move in x direction
		xor	di,di			; zap x update
		xchg	cx,dx			; exchange differences
		jmp	storedelsxy
setdiag:
		xor	si,si			; zap y update
storedelsxy:
		mov	delsAdd,di
		add	delsAdd,si
		mov	di,writemode
		shl	di,1
		mov	si,[di+LineRtns]	; routine to jump to

		shl	dx,1			; get delp and * 2
		mov	bp,dx			; change if straight move
		sub	dx,cx			; 2*delp-dels
		mov	di,dx			; initial value
		sub	dx,cx
		xchg	si,dx
		inc	cx			; increment count

		push	dx
		mov	al,[bx+PageTable]
		mov	dx,TSENGPAGEREG
		out	dx,al
		pop	dx

		shl	bx,1			; for word table
		mov	bx,[YTable+bx]
		add	bx,word ptr screen_adr
		mov	ax,dx			; save routine address
		mov	dx,vectPattern		; get line style to draw
		jmp	ax

BresenhamLine	Endp

;{----------------------------------------------------------------------}
;{	LineReplace:							}
;{	  Draw line in replace mode					}
;{----------------------------------------------------------------------}
LineReplace	Proc	Near

		mov	ah,drawcolor
@@LineLoop:
		xor	al,al
		rol	dx,1			; check line mask
		jnc	@@SkipPix
		mov	al,ah
@@SkipPix:
		mov	es:[bx],al
		cmp	di,0			; determine straight or diagonal
		jge	@@diagonal
@@straight:
		add	bx,delsAdd		;update delta striaght
		jnc	@@NotNextPage1
		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx
@@NotNextPage1:
		add	di,bp			;update error term
		loop	@@LineLoop
		pop	di
		pop	es
		ret
@@diagonal:
		add	bx,deldAdd		;update delta diagonal
		jnc	@@NotNextPage2
		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx
@@NotNextPage2:
		add	di,si			;update error term
@@2:
		loop	@@LineLoop
		pop	di
		pop	es
		ret

LineReplace	Endp

;{----------------------------------------------------------------------}
;{	LineXor:							}
;{	  Draw line in exclusive or mode				}
;{----------------------------------------------------------------------}
LineXor		Proc	Near

		mov	ah,drawcolor
@@LineLoop:
		xor	al,al
		rol	dx,1			; check line mask
		jnc	@@SkipPix
		mov	al,ah
@@SkipPix:
		xor	es:[bx],al
		cmp	di,0			; determine straight or diagonal
		jge	@@diagonal
@@straight:
		add	bx,delsAdd		;update delta striaght
		jnc	@@NotNextPage1
		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx
@@NotNextPage1:
		add	di,bp			;update error term
		loop	@@LineLoop
		pop	di
		pop	es
		ret
@@diagonal:
		add	bx,deldAdd		;update delta diagonal
		jnc	@@NotNextPage2
		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx
@@NotNextPage2:
		add	di,si			;update error term
@@2:
		loop	@@LineLoop
		pop	di
		pop	es
		ret

LineXor		Endp

;{----------------------------------------------------------------------}
;{	LineOr:								}
;{	  Draw line in or mode						}
;{----------------------------------------------------------------------}
LineOr		Proc	Near

		mov	ah,drawcolor
@@LineLoop:
		xor	al,al
		rol	dx,1
		jnc	@@SkipPix
		mov	al,ah
@@SkipPix:
		or	es:[bx],al
		cmp	di,0			; determine straight or diagonal
		jge	@@diagonal
@@straight:
		add	bx,delsAdd		;update delta striaght
		jnc	@@NotNextPage1
		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx
@@NotNextPage1:
		add	di,bp			;update error term
		loop	@@LineLoop
		pop	di
		pop	es
		ret
@@diagonal:
		add	bx,deldAdd		;update delta diagonal
		jnc	@@NotNextPage2
		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx
@@NotNextPage2:
		add	di,si			;update error term
		loop	@@LineLoop
		pop	di
		pop	es
		ret

LineOr		Endp

;{----------------------------------------------------------------------}
;{	LineAnd:							}
;{	  Draw line in replace mode					}
;{----------------------------------------------------------------------}
LineAnd		Proc	Near

		mov	ah,drawcolor
@@LineLoop:
		xor	al,al
		rol	dx,1
		jnc	@@SkipPix
		mov	al,ah
@@SkipPix:
		and	es:[bx],al
		cmp	di,0			; determine straight or diagonal
		jge	@@diagonal
@@straight:
		add	bx,delsAdd		;update delta striaght
		jnc	@@NotNextPage1
		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx
@@NotNextPage1:
		add	di,bp			;update error term
		loop	@@LineLoop
		pop	di
		pop	es
		ret
@@diagonal:
		add	bx,deldAdd		;update delta diagonal
		jnc	@@NotNextPage2
		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx
@@NotNextPage2:
		add	di,si			;update error term
@@2:
		loop	@@LineLoop
		pop	di
		pop	es
		ret

LineAnd		Endp

;{----------------------------------------------------------------------}
;{	LineXParent:							}
;{	  Draw line in replace mode					}
;{----------------------------------------------------------------------}
LineXParent	Proc	Near

		mov	al,drawcolor
@@LineLoop:
		rol	dx,1
		jnc	@@SkipPix
		mov	es:[bx],al
@@SkipPix:
		cmp	di,0			; determine straight or diagonal
		jge	@@diagonal
@@straight:
		add	bx,delsAdd		;update delta striaght
		jnc	@@NotNextPage1
		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx
@@NotNextPage1:
		add	di,bp			;update error term
		loop	@@LineLoop
		pop	di
		pop	es
		ret
@@diagonal:
		add	bx,deldAdd		;update delta diagonal
		jnc	@@NotNextPage2
		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx
@@NotNextPage2:
		add	di,si			;update error term
@@2:
		loop	@@LineLoop
		pop	di
		pop	es
		ret

LineXParent	Endp

;{----------------------------------------------------------------------}
;{	post:								}
;{	  exit from graphics mode					}
;{----------------------------------------------------------------------}
post		proc	near

		mov	al,oldVideoMode		; get old video mode
		xor	ah,ah
		int	VIDEOIO			; and restore it
		ret

post		endp

;{----------------------------------------------------------------------}
;{	text:								}
;{	  output text from character rom to screen			}
;{									}
;{	parameters:							}
;{	  cx = size of string						}
;{	  es:bx = pointer to string					}
;{----------------------------------------------------------------------}
text		proc	near

		push	di
		push	es
		mov	ax,es
		mov	ds,ax
		mov	si,bx			; put in lodsb addressing
TextStringLoop:
		lodsb
		cmp	al,cs:EscapeUnderline	; set underline on?
		jne	@@NotUnderline
		mov	cs:underLineOn,TRUE
@@NextCharacter:
		loop	TextStringLoop
		pop	es
		pop	di
		ret
@@NotUnderline:
		cmp	al,CR
		jne	@@NotCR
		mov	ax,cs:xMin
		mov	cs:xCP,ax
		loop	TextStringLoop
		pop	es
		pop	di
		ret
@@NotCR:
		cmp	al,LF
		jne	@@NotLF
		mov	ax,cs:textHeight
		add	cs:yCP,ax
		loop	TextStringLoop
		pop	es
		pop	di
		ret
@@NotLF:
		push	cx
		push	si			; save string variables
		push	ds

		mov	bx,cs:writemode
		shl	bx,1
		mov	si,cs:[bx+TextRtns]	; get text write routine

		xor	ah,ah			; change byte to word
		mov	cx,cs:textWidth		; get text width
		mov	bp,cx			; save for later adds
		shr	cx,1
		shr	cx,1
		shr	cx,1			; get # bytes wide
		mul	cx
		mov	bx,cs:textHeight
		mul	bx
		mov	dx,si			; save routine address
		mov	si,ax			; and get source pointer
		add	si,word ptr cs:textPointer ; get to text desired
		mov	ds,cs:word ptr textPointer+2
		mov	di,cs:yCP
		push	dx
		mov	al,[di+PageTable]
		mov	dx,TSENGPAGEREG
		out	dx,al
		pop	dx
		shl	di,1
		mov	di,cs:[di+YTable]
		add	di,word ptr cs:screen_adr
		add	di,cs:xCP
		mov	es,cs:word ptr screen_adr+2

		mov	ah,cs:drawcolor
		jmp	dx

;{----------------------------------------------------------------------}
;{	TextReplace:							}
;{	  Draw text string in replace mode				}
;{----------------------------------------------------------------------}
TextReplace	Proc	near

		mov	cx,bp			; width of character
		xor	dh,dh			; initial # bits from source
@@WidthLoop:
		cmp	dh,0			; see if out of source pixels
		jne	@@NotNextSource		; nope
		lodsb				; else get new source
		mov	dl,al			; into save register
		mov	dh,8			; number bits this byte
@@NotNextSource:
		mov	al,cs:backcolor		; get background color
		rol	dl,1
		jnc	@@xparent		; see if bit is on
		mov	al,ah			; then get color
@@xparent:
		stosb				; and write pixel
		dec	dh			; minus one source
		loop	@@WidthLoop		; loop for width of character

		sub	di,bp
		add	di,cs:Ytable+2		; next y position
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		dec	bx
		jne	TextReplace		; do height of character
		call	near ptr UnderLine	; do underline if wanted
		mov	ax,cs:textWidth
		add	cs:xCP,ax		; update x position
		pop	ds
		pop	si
		pop	cx
		dec	cx
		je	@@ExitText
		jmp	TextStringLoop		; back to text string
@@ExitText:
		pop	es
		pop	di
		ret

TextReplace	Endp

;{----------------------------------------------------------------------}
;{	TextXor:							}
;{	  Draw text string in XOR mode					}
;{----------------------------------------------------------------------}
TextXor		Proc	Near

		mov	cx,bp			; width of character
		xor	dh,dh			; initial # bits from source
@@WidthLoop:
		cmp	dh,0			; see if out of source pixels
		jne	@@NotNextSource		; nope
		lodsb				; else get new source
		mov	dl,al			; into save register
		mov	dh,8			; number bits this byte
@@NotNextSource:
		mov	al,cs:backcolor		; get background color
		rol	dl,1
		jnc	@@xparent		; see if bit is on
		mov	al,ah			; then get color
@@xparent:
		xor	es:[di],al		; and write pixel
		inc	di			
		dec	dh			; minus one source
		loop	@@WidthLoop		; loop for width of character

		sub	di,bp			
		add	di,cs:Ytable+2		; next y position
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		dec	bx			
		jne	TextXor			; do height of character
		call	near ptr UnderLine	; do underline if wanted
		mov	ax,cs:textWidth		
		add	cs:xCP,ax		; update x position
		pop	ds
		pop	si
		pop	cx
		dec	cx
		je	@@ExitText		
		jmp	TextStringLoop		; back to text string			    
@@ExitText:
		pop	es
		pop	di
		ret

TextXor		Endp

;{----------------------------------------------------------------------}
;{	TextOr:								}
;{	  Draw text string in OR mode					}
;{----------------------------------------------------------------------}
TextOr		Proc	near

		mov	cx,bp			; width of character
		xor	dh,dh			; initial # bits from source
@@WidthLoop:
		cmp	dh,0			; see if out of source pixels
		jne	@@NotNextSource		; nope
		lodsb				; else get new source
		mov	dl,al			; into save register
		mov	dh,8			; number bits this byte
@@NotNextSource:
		mov	al,cs:backcolor		; get background color
		rol	dl,1
		jnc	@@xparent		; see if bit is on
		mov	al,ah			; then get color
@@xparent:
		or	es:[di],al		; and write pixel
		inc	di
		dec	dh			; minus one source
		loop	@@WidthLoop		; loop for width of character

		sub	di,bp
		add	di,cs:Ytable+2		; next y position
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		dec	bx
		jne	TextOr			; do height of character
		call	near ptr UnderLine	; do underline if wanted
		mov	ax,cs:textWidth
		add	cs:xCP,ax		; update x position
		pop	ds
		pop	si
		pop	cx
		dec	cx
		je	@@ExitText
		jmp	TextStringLoop		; back to text string		
@@ExitText:
		pop	es
		pop	di
		ret

TextOr		Endp

;{----------------------------------------------------------------------}
;{	TextAnd:							}
;{	  Draw text string in And mode					}
;{----------------------------------------------------------------------}
TextAnd		Proc	near

		mov	cx,bp			; width of character
		xor	dh,dh			; initial # bits from source
@@WidthLoop:
		cmp	dh,0			; see if out of source pixels
		jne	@@NotNextSource		; nope
		lodsb				; else get new source
		mov	dl,al			; into save register
		mov	dh,8			; number bits this byte
@@NotNextSource:
		mov	al,cs:backcolor		; get background color
		rol	dl,1
		jnc	@@xparent		; see if bit is on
		mov	al,ah			; then get color
@@xparent:
		and	es:[di],al		; and write pixel
		inc	di
		dec	dh			; minus one source
		loop	@@WidthLoop		; loop for width of character

		sub	di,bp
		add	di,cs:Ytable+2		; next y position
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		dec	bx
		jne	TextAnd			; do height of character
		call	near ptr UnderLine	; do underline if wanted
		mov	ax,cs:textWidth
		add	cs:xCP,ax		; update x position
		pop	ds
		pop	si
		pop	cx
		dec	cx
		je	@@ExitText
		jmp	TextStringLoop		; back to text string		
@@ExitText:
		pop	es
		pop	di
		ret

TextAnd		Endp

;{----------------------------------------------------------------------}
;{	TextXParent:							}
;{	  Draw text string in trasparent mode				}
;{----------------------------------------------------------------------}
TextXParent	Proc	Near

		mov	cx,bp			; width of character
		xor	dh,dh			; initial # bits from source
@@WidthLoop:
		cmp	dh,0			; see if out of source pixels
		jne	@@NotNextSource		; nope
		lodsb				; else get new source
		mov	dl,al			; into save register
		mov	dh,8			; number bits this byte
@@NotNextSource:
		rol	dl,1			; see if bit is on
		jnc	@@xparent
		mov	es:[di],ah		; and write pixel
@@xparent:					
		inc	di			
		dec	dh			; minus one source
		loop	@@WidthLoop		; loop for width of character
						
		sub	di,bp			
		add	di,cs:Ytable+2		; next y position
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		dec	bx			
		jne	TextXParent		; do height of character
		call	near ptr UnderLine	; do underline if wanted
		mov	ax,cs:textWidth		
		add	cs:xCP,ax		; update x position
		pop	ds
		pop	si			
		pop	cx
		dec	cx
		je	@@ExitText		
		jmp	TextStringLoop		; back to text string		
@@ExitText:
		pop	ds			
		pop	si
		ret

TextXParent	Endp

text		endp

;{----------------------------------------------------------------------}
;{	UnderLine:							}
;{	  if underline on do underline of character			}
;{									}
;{----------------------------------------------------------------------}
UnderLine	Proc	near

		cmp	cs:underLineOn,TRUE	; is underline on?
		jne	@@NoUnderLine
		mov	cs:underLineOn,FALSE	; only for one character
		mov	cx,bp
		mov	bx,cs:writemode		; do underline in write mode
		shl	bx,1
		mov	bx,cs:[bx+UnderLineRtns]
		mov	al,ah
		jmp	bx

ULReplace:
		stosb				; replace underline
		loop	ULReplace
@@NoUnderLine:
		ret
ULXor:
		xor	es:[di],al		; xor underline
		inc	di
		loop	ULXor
		ret
ULOr:
		or	es:[di],al		; or underline
		inc	di
		loop	ULOr
		ret
ULAnd:
		and	es:[di],al		; and underline
		inc	di
		loop	ULAnd
		ret
ULXParent:
		cmp	al,cs:backcolor		; transparent underline
		jne	ULReplace
		ret

UnderLine	Endp

;{----------------------------------------------------------------------}
;{	textsize:							}
;{	  get the text size in width and height in graphics pixels	}
;{									}
;{	parameters:							}
;{	  cx = length of string in characters				}
;{	  es:bx = pointer to string					}
;{									}
;{	returns:							}
;{	  bx = width of string in graphic units				}
;{	  cx = height of string in graphic units			}
;{----------------------------------------------------------------------}
textsize	proc	near

		push	bp
		push	si
		push	di

		push	es
		pop	ds
		mov	si,bx			; set up pointer
		xor	bp,bp			; displayed character width
		mov	bx,cs:textHeight	; initial height
		xor	di,di			; current width
		xor	dx,dx			; what to add if characters
						; on this line
		jcxz	@@NotLF2
@@TextLoop:
		lodsb
		cmp	al,cs:EscapeUnderLine	; escape underline character?
		je	@@DontCount
		cmp	al,CR			; see if carriage return
		jne	@@NotCR			; nope
		xor	di,di			; zero out temp width
		jmp	@@DontCount		; but don't inc width
@@NotCR:
		cmp	al,LF			; is it line feed
		jne	@@NotLF			; nope
		mov	dx,cs:textHeight	; new text height
		jmp	@@DontCount		; but don't inc width
@@NotLF:
		add	bx,dx			; update height if line feed
		xor	dx,dx			; last character != LF
		add	di,cs:textWidth
		cmp	di,bp			; see if this line is biggest
		jl	@@DontCount		; width
		mov	bp,di			; yep so save off new with
@@DontCount:
		loop	@@TextLoop		; do all characters

		cmp	al,LF			; see if any characters on
		jne	@@NotLF2		; this line
		cmp	bx,cs:textHeight
		jle	@@NotLF2
		sub	bx,cs:textHeight	; nope so doesn't add
@@NotLF2:
		mov	cx,bx
		mov	bx,bp			; save width in pixels
		pop	di
		pop	si
		pop	bp
		ret

textsize	endp

;{----------------------------------------------------------------------}
;{	bar:								}
;{	  draw a 3d bar	(emulate from library)				}
;{----------------------------------------------------------------------}
bar		proc	near

		jmp	EMULATE

bar		endp

;{----------------------------------------------------------------------}
;{	pieslice:							}
;{	  draw pie slice (emulate from library)				}
;{----------------------------------------------------------------------}
pieslice	proc	near

		jmp	EMULATE

pieslice	endp

;{----------------------------------------------------------------------}
;{	filled_ellipse:							}
;{	  draw filled ellipse (emulate from library)			}
;{----------------------------------------------------------------------}
filled_ellipse	proc	near

		jmp	EMULATE

filled_ellipse	endp

;{----------------------------------------------------------------------}
;{	arc:								}
;{	  draw arc (emulate from library)				}
;{----------------------------------------------------------------------}
arc		proc	near

		jmp	EMULATE

arc		endp


;{----------------------------------------------------------------------}
;{	textstyle:							}
;{	  set hardware text style and font #				}
;{----------------------------------------------------------------------}
textstyle	proc	near

		ret

textstyle	endp

;{----------------------------------------------------------------------}
;{	color_query:							}
;{	  get maximum colors or pointer to Device Color Table (DCT)	}
;{									}
;{	parmeters:							}
;{	  al = command 0, get maximum colors in bx, last color in cx	}
;{		      !0 = es:bx = DCT pointer				}
;{----------------------------------------------------------------------}

color_query	proc	near

		or	al,al
		jne	@@getDCT
		mov	bx,MAXCOLORS
		mov	cx,MAXCOLORS-1
		ret
@@getDCT:
		push	cs
		pop	es
		mov	bx,offset DCTable
		ret

color_query	endp

;{----------------------------------------------------------------------}
;{	patbar:								}
;{	  draw a patterned 2-d bar to the visible screen		}
;{									}
;{	parameters:							}
;{	  ax = x1--rectangles left coordinate				}
;{	  bx = y1--rectangles right coordinate				}
;{	  cx = x2--rectangles right coordinate				}
;{	  dx = y2--rectangles bottom coordinate				}
;{----------------------------------------------------------------------}
patbar		proc	near

		call	near ptr ClipRect	; clip the rectangle
		jnc	@@pbOK
		ret				; all clipped so bye-bye
@@pbOK:
		push	di
		push	es
		mov	di,ax
		mov	bp,cx
		sub	bp,ax			; make width
		inc	bp
		sub	dx,bx			; get height of rectangle
		inc	dx
		mov	si,bx			; save for later
		push	dx
		mov	al,[bx+PageTable]
		mov	dx,TSENGPAGEREG
		out	dx,al
		pop	dx
		shl	bx,1
		add	di,[bx+Ytable]
		add	di,word ptr screen_adr	; get to screen
		mov	es,word ptr screen_adr+2

		mov	bx,writemode
		shl	bx,1
		mov	bx,[bx+PatBarRtns]
		
		mov	ah,fillcolor
		
		and	si,7
		add	si,offset PatternFill	; get to pattern fill value
		jmp	bx

patbar		endp

;{----------------------------------------------------------------------}
;{	PatBarReplace:							}
;{	   Draw pattern bar in Replace Mode				}
;{----------------------------------------------------------------------}
PatBarReplace	Proc	Near

		mov	bh,al			; save x value & 7
		and	bh,7

@@pbHeightLoop:
		mov	bl,[si] 		; get pattern byte
		mov	cl,bh
		rol	bl,cl			; get pixel value start in pattern
		mov	cx,bp
@@pbWidthLoop:
		xor	al,al
		rol	bl,1
		jnc	@@SkipPixel		; see if time to plot
		mov	al,ah
@@SkipPixel:
		stosb
		loop	@@pbWidthLoop
		sub	di,bp
		add	di,cs:Ytable+2
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		inc	si			; next y fill position
		cmp	si,offset EndPatternFill
		jb	@@NotYWrap
		mov	si,offset PatternFill
@@NotYWrap:
		dec	dx
		jne	@@pbHeightLoop		; and do height
@@pbAllDone:
		pop	es
		pop	di
		ret

PatBarReplace	Endp

;{----------------------------------------------------------------------}
;{	PatBarXor:							}
;{	   Draw pattern bar in XOR Mode					}
;{----------------------------------------------------------------------}
PatBarXor	Proc	Near

		mov	bh,al			; save x value & 7
		and	bh,7
@@pbHeightLoop:
		mov	bl,[si] 		; get pattern byte
		mov	cl,bh
		rol	bl,cl			; get pixel value start in pattern
		mov	cx,bp
@@pbWidthLoop:
		xor	al,al
		rol	bl,1
		jnc	@@SkipPixel		; see if time to plot
		mov	al,ah
@@SkipPixel:
		xor	es:[di],al
		inc	di
		loop	@@pbWidthLoop
		sub	di,bp
		add	di,cs:Ytable+2
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		inc	si			; next y fill position
		cmp	si,offset EndPatternFill
		jb	@@NotYWrap
		mov	si,offset PatternFill
@@NotYWrap:
		dec	dx
		jne	@@pbHeightLoop		; and do height
@@pbAllDone:
		pop	es
		pop	di
		ret

PatBarXor	Endp

;{----------------------------------------------------------------------}
;{	PatBarOr:							}
;{	   Draw pattern bar in OR Mode					}
;{----------------------------------------------------------------------}
PatBarOr	Proc	Near

		mov	bh,al			; save x value & 7
		and	bh,7

@@pbHeightLoop:
		mov	bl,[si] 		; get pattern byte
		mov	cl,bh
		rol	bl,cl			; get pixel value start in pattern
		mov	cx,bp
@@pbWidthLoop:
		xor	al,al
		rol	bl,1
		jnc	@@SkipPixel		; see if time to plot
		mov	al,ah
@@SkipPixel:
		or	es:[di],al
		inc	di
		loop	@@pbWidthLoop
		sub	di,bp
		add	di,cs:Ytable+2
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		inc	si			; next y fill position
		cmp	si,offset EndPatternFill
		jb	@@NotYWrap
		mov	si,offset PatternFill
@@NotYWrap:
		dec	dx
		jne	@@pbHeightLoop		; and do height
@@pbAllDone:
		pop	es
		pop	di
		ret

PatBarOr	Endp

;{----------------------------------------------------------------------}
;{	PatBarAnd:							}
;{	   Draw pattern bar in And Mode					}
;{----------------------------------------------------------------------}
PatBarAnd	Proc	Near

		mov	bh,al			; save x value & 7
		and	bh,7

@@pbHeightLoop:
		mov	bl,[si] 		; get pattern byte
		mov	cl,bh
		rol	bl,cl			; get pixel value start in pattern
		mov	cx,bp
@@pbWidthLoop:
		xor	al,al
		rol	bl,1
		jnc	@@SkipPixel		; see if time to plot
		mov	al,ah
@@SkipPixel:
		and	es:[di],al
		inc	di
		loop	@@pbWidthLoop
		sub	di,bp
		add	di,cs:Ytable+2
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		inc	si			; next y fill position
		cmp	si,offset EndPatternFill
		jb	@@NotYWrap
		mov	si,offset PatternFill
@@NotYWrap:
		dec	dx
		jne	@@pbHeightLoop		; and do height
@@pbAllDone:
		pop	es
		pop	di
		ret

PatBarAnd	Endp

;{----------------------------------------------------------------------}
;{	PatBarXParent:							}
;{	   Draw pattern bar in transparent Mode				}
;{----------------------------------------------------------------------}
PatBarXParent	Proc	Near

		mov	bh,al			; save x value & 7
		and	bh,7

@@pbHeightLoop:
		mov	bl,[si] 		; get pattern byte
		mov	cl,bh
		rol	bl,cl			; get pixel value start in pattern
		mov	cx,bp
@@pbWidthLoop:
		rol	bl,1
		jnc	@@SkipPixel		; see if time to plot
		mov	es:[di],ah
@@SkipPixel:
		inc	di
		loop	@@pbWidthLoop
		sub	di,bp
		add	di,cs:Ytable+2
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		inc	si			; next y fill position
		cmp	si,offset EndPatternFill
		jb	@@NotYWrap
		mov	si,offset PatternFill
@@NotYWrap:
		dec	dx
		jne	@@pbHeightLoop		; and do height
@@pbAllDone:
		pop	es
		pop	di
		ret

PatBarXParent	Endp

;{----------------------------------------------------------------------}
;{	ClipRect:							}
;{	  Clip rectangle against clipping region			}
;{									}
;{	parameters:							}
;{	  ax = x1							}
;{	  bx = y1							}
;{	  cx = x2							}
;{	  dx = y2							}
;{----------------------------------------------------------------------}
ClipRect	Proc	Near

		cmp	ax,cx			; make sure in right order
		jl	@@xRightOrder
		xchg	ax,cx
@@xRightOrder:
		cmp	bx,dx
		jl	@@yRightOrder
		xchg	bx,dx
@@yRightOrder:
		cmp	ax,xMax
		jg	@@ClippedOut
		cmp	cx,xMin
		jl	@@ClippedOut		; first check if completly 
		cmp	bx,yMax			; clipped
		jg	@@ClippedOut
		cmp	dx,yMin
		jge	@@NotClippedOut
@@ClippedOut:
		stc				; return full clipped
		ret
@@NotClippedOut:
		cmp	ax,xMin			; in clip range?
		jge	@@NoClipLeft		; yep
		mov	ax,xMin			; else set to left
@@NoCLipLeft:
		cmp	cx,xMax
		jle	@@NoClipRight
		mov	cx,xMax
@@NoClipRight:
		cmp	bx,yMin
		jge	@@NoClipTop
		mov	bx,yMin
@@NoClipTop:
		cmp	dx,yMax
		jle	@@NoClipBottom
		mov	dx,yMax
@@NoClipBottom:
		clc
		ret

ClipRect	Endp

;{----------------------------------------------------------------------}
;{	palette:							}
;{	  set palette registers						}
;{									}
;{	parameters:							}
;{	  ax = index and command code					}
;{----------------------------------------------------------------------}
palette		proc	near

		cmp	ax,3fffh
		ja	@@NotPalZeroIndex
		mov	bh,bl
		mov	bl,al
		mov	ax,((VGAPAL SHL 8) OR SETPALREG)
		int	VIDEOIO
		ret
@@NotPalZeroIndex:
		cmp	ax,8fffh
		ja	@@NotPalTwoIndex
		mov	ch,cl
		mov	cl,dl
		mov	dh,bl
		mov	bx,ax
		mov	ax,((VGAPAL SHL 8) OR SETDACREG)
		int	VIDEOIO
		ret
@@NotPalTwoIndex:
		cmp	ax,9000h
		jb	@@NoIndex
		mov	ax,((VGAPAL SHL 8) OR SETOVERSCAN)
		int	VIDEOIO
@@NoIndex:
		ret

palette		endp


;{----------------------------------------------------------------------}
;{	color:								}
;{	  set drawing color and fill color				}
;{									}
;{	parameters:							}
;{	  al = drawing color						}
;{	  ah = fill color						}
;{----------------------------------------------------------------------}
color		proc	near

		mov	drawcolor,al              ; save reg contents for BIOS
		mov	fillcolor,ah
		ret

color		endp


;{----------------------------------------------------------------------}
;{	fillstyle:							}
;{	  set fill style for patterned bars				}
;{									}
;{	parameters:							}
;{	  al = pattern # if -1 the es:bx pointer to user pattern	}
;{----------------------------------------------------------------------}
fillstyle	proc	near

		push	si
		push	di
		push	ds
		push	es
		mov	cx,es
		mov	ds,cx
		mov	cx,cs
		mov	es,cx
		cmp	al,-1			; user pattern?
		je	@@savePattern
		mov	bx,cs
		mov	ds,bx
		cbw
		shl	ax,1
		shl	ax,1
		shl	ax,1			; get one of the standard
		mov	bx,ax			; fill patterns from table
		add	bx,offset PatternStdFill 
@@savePattern:
		mov	si,bx
		mov	di,offset PatternFill
		mov	cx,4
		rep	movsw
		pop	es
		pop	ds
		pop	di
		pop	si
		ret

fillstyle	endp


;{----------------------------------------------------------------------}
;{	vectstyle:							}
;{	  set up vector style for drawing a line			}
;{									}
;{	parameters:							}
;{	  al = line pattern number					}
;{	  bx = User-Defined line drawing pattern if al > 4		}
;{	  cx = line width for drawing					}
;{----------------------------------------------------------------------}
vectstyle	proc	near

		cmp	ax,4
		ja	@@vSRet
		je	@@vSSave
		shl	ax,1
		mov	bx,ax
		mov	bx,[bx+vectStdPatterns]
@@vSSave:
		mov	vectPattern,bx
		mov	vectWidth,cx
@@vSRet:
		ret

vectstyle	endp



;{----------------------------------------------------------------------}
;{	floodfill:							}
;{	  flood fill a bounded region					}
;{----------------------------------------------------------------------}
floodfill	proc	near

		jmp	EMULATE

floodfill	endp


;{----------------------------------------------------------------------}
;{	allpalette:							}
;{	  sets the palette register block				}
;{									}
;{----------------------------------------------------------------------}
allpalette	proc	near

		mov	dx,bx
		mov	ax,((VGAPAL SHL 8) OR SETREGBLOCK)
		int	VIDEOIO
		ret

allpalette	endp

;{----------------------------------------------------------------------}
;{	getpixel:							}
;{	  get a pixel from the screen					}
;{									}
;{	parms:								}
;{	  ax = x coordinate						}
;{	  bx = y coordinate						}
;{									}
;{	returns:							}
;{	  dl = color index of pixel read				}
;{----------------------------------------------------------------------}
getpixel	proc	near

		push	di
		push	es
		les	di,screen_adr		; get screen address
		add	di,ax			; x position add
		mov	al,[bx+PageTable]
		mov	dx,TSENGPAGEREG
		out	dx,al
		shl	bx,1
		add	di,cs:[bx+Ytable]
		mov	dl,byte ptr es:[di]	; get pixel value

		pop	es
		pop	di
		ret

getpixel	endp

;{----------------------------------------------------------------------}
;{	setpixel:							}
;{	  set a pixel on the screen					}
;{									}
;{	parms:								}
;{	  ax = x coordinate						}
;{	  bx = y coordinate						}
;{	  dl = color index of pixel to write				}
;{----------------------------------------------------------------------}
setpixel	proc	near

		push	di
		push	es
		les	di,screen_adr		; get screen address
		add	di,ax			; x position add
		push	dx
		mov	al,[bx+PageTable]
		mov	dx,TSENGPAGEREG
		out	dx,al
		pop	dx
		shl	bx,1
		add	di,cs:[bx+Ytable]
		mov	bx,writemode
		shl	bx,1
		jmp	cs:[bx+PixelRtns]
PixelReplace:
		mov	byte ptr es:[di],dl	; store pixel value
		pop	es
		pop	di
		ret
PixelXor:
		xor	byte ptr es:[di],dl	; xor pixel value
		pop	es
		pop	di
		ret
PixelOr:
		or	byte ptr es:[di],dl	; or pixel value
		pop	es
		pop	di
		ret
PixelAnd:
		and	byte ptr es:[di],dl	; and pixel value
		pop	es
		pop	di
		ret
PixelXParent:
		cmp	dl,backcolor
		je	@@SPExit
		xor	byte ptr es:[di],dl	; xor pixel value
@@SPExit:
		pop	es
		pop	di
		ret

setpixel	endp


;{----------------------------------------------------------------------}
;{	bitmaputil:							}
;{	  return far address of far vectors for bitmap utility vectors	}
;{									}
;{	parameters:							}
;{	  none								}
;{									}
;{	returns:							}
;{	  es:bx pointer to utility vectors				}
;{----------------------------------------------------------------------}
bitmaputil	proc	near

		mov	bx,offset bitmaputilvecs
		push	ds
		pop	es
		ret

bitmaputil	endp
			    
;{----------------------------------------------------------------------}
;{	bitsperpixel:							}
;{	  return bits per pixel for this mode				}
;{									}
;{	returns:							}
;{	  ax = bits per pixel						}
;{----------------------------------------------------------------------}
bitsperpixel	proc	far

		mov	ax,8                    ; each pixel occupies 8 bits
		ret

bitsperpixel	endp

;{----------------------------------------------------------------------}
;{	gotographic:							}
;{	  goto graphics mode						}
;{----------------------------------------------------------------------}
gotographic	proc	far

		ret

gotographic	endp

;{----------------------------------------------------------------------}
;{	exitgraphic:							}
;{	  exit graphics mode						}
;{----------------------------------------------------------------------}
exitgraphic	proc	far

		ret

exitgraphic	endp

;{----------------------------------------------------------------------}
;{	farputpixel:							}
;{	  set pixel call						}
;{----------------------------------------------------------------------}
farputpixel	proc	far

		call	setpixel
		ret

farputpixel	endp


;{----------------------------------------------------------------------}
;{	fargetpixel:							}
;{	  get pixel call						}
;{----------------------------------------------------------------------}
fargetpixel	proc	far

		call	getpixel
		ret

fargetpixel	endp


;{----------------------------------------------------------------------}
;{	setpage:							}
;{	  set graphics writing page					}
;{----------------------------------------------------------------------}
setpage		proc	far

		ret

setpage		endp

;{----------------------------------------------------------------------}
;{	setvisual:							}
;{	  set graphics visual page					}
;{----------------------------------------------------------------------}
setvisual	proc	far

		ret

setvisual	endp

;{----------------------------------------------------------------------}
;{	setwritemode:							}
;{	  set graphics writing mode					}
;{									}
;{	parameters:							}
;{	  al = write mode to set					}
;{----------------------------------------------------------------------}
setwritemode	proc	far

		push	ds
		push	cs
		pop	ds
		xor	ah,ah
		mov	writemode,ax
		pop	ds
		ret

setwritemode	endp

;{----------------------------------------------------------------------}
;{	copyraster:							}
;{	  copy raster image from source to destination			}
;{									}
;{	parameters:							}
;{	  es:bx = pointer to copy raster structure			}
;{	  source followed by destination				}
;{	    struct copyrast {						}
;{		int    rasterWidth;					}
;{		int    rasterHeight;					}
;{		raster srcRaster;					}
;{		raster destRaster;					}
;{	    };								}
;{									}
;{	    struct raster {						}
;{		int rastX;						}
;{		int rastY;						}
;{		int rastW;						}
;{		char huge *dataPointer;					}
;{	    };								}
;{----------------------------------------------------------------------}
copyraster	proc	near

		push	si
		push	di
		push	bp
		push	ds
		push	es
		
		lds	si,es:[bx].SRC.RasterData	; load source pointer
		mov	ax,es:[bx].SRC.rastY	; get source y position
		mov	cx,es:[bx].SRC.rastW	; source width
		mul	cx			; get to offset
		add	si,ax			; add to soure pointer
		add	si,es:[bx].SRC.rastX	; and adjust x also

		mov	ax,es:[bx].DST.rastY	; get destination y
		mov	di,es:[bx].DST.rastW	; and width
		mul	di			; now make offset
		mov	dx,di
		add	ax,es:[bx].DST.rastX	; and add in x offset
		mov	di,ax			; put in pointer register
		mov	ax,cx			; save source width
		add	di,word ptr es:[bx].DST.RasterData
		mov	cx,es:[bx].RasterWidth
		mov	bp,es:[bx].RasterHeight
		mov	es,word ptr es:[bx].DST.RasterData+2
		mov	bx,cx			; save width for later
		sub	ax,cx
		sub	dx,cx
@@HeightLoop:
		mov	cx,bx
		shr	cx,1
		rep	movsw
		adc	cx,cx
		rep	movsb
		add	si,ax
		add	di,dx
		dec	bp
		jne	@@HeightLoop
		
		pop	es
		pop	ds
		pop	bp
		pop	di
		pop	si
		ret

copyraster	endp

;{----------------------------------------------------------------------}
;{	setpageaddress:							}
;{	  set graphics page address					}
;{									}
;{	parameters:							}
;{	  ax = page number to set					}
;{	  es:bx = page address to set to				}
;{----------------------------------------------------------------------}
setpageaddress	proc	near

		push	ds
		push	cs
		pop	ds

		xchg	ax,bx
		and	bx,1			; either 0 or 1 page
		shl	bx,1
		shl	bx,1
		mov	word ptr [bx+screen_adr],ax
		mov	word ptr [bx+screen_adr+2],es

		pop	ds
		
		ret

setpageaddress	endp

;{----------------------------------------------------------------------}
;{	getpageaddress:							}
;{	  get graphics page address					}
;{									}
;{	parameters:							}
;{	  ax = page number to get					}
;{									}
;{	returns:							}
;{	  es:bx = page address of requested page			}
;{----------------------------------------------------------------------}
getpageaddress	Proc	near

		push	ds
		push	cs
		pop	ds
		mov	bx,ax
		and	bx,1			; either 0 or 1 page
		shl	bx,1
		shl	bx,1
		les	bx,[bx+screen_adr]

		pop	ds
		
		ret

getpageaddress	endp

;{----------------------------------------------------------------------}
;{	getpixelshift:							}
;{	  get shift value to convert pixels to bytes			}
;{									}
;{	returns:							}
;{	  ax = shift value						}
;{									}
;{----------------------------------------------------------------------}
getpixelshift	Proc	near

		xor	ax,ax
		ret

getpixelshift	Endp

;{----------------------------------------------------------------------}
;{	clipBitmap:							}
;{	  ax = x position						}
;{	  bx = y position						}
;{	  cx = width							}
;{	  dx = height							}
;{	returns:							}
;{	  bp = 1 if nothing to draw					}
;{	  bp = 0, registers adjusted to fit in clip area		}
;{	uses:								}
;{	  clip parameters in data segment				}
;{----------------------------------------------------------------------}
clipBitmap	Proc	Near

		push	di
		push	ds

		mov	cs:topAdjust,0
		mov	cs:leftAdjust,0
		mov	cs:rightAdjust,0

		xor	bp,bp			; start out ok to draw
		cmp	ax,cs:xMin		; check left side
		jge	@@xMinOK		; >= left so far so good
		sub	ax,cs:xMin
		add	cx,ax			; and width is less
		neg	ax
		mov	cs:leftAdjust,ax	; what to add to source x
		mov	ax,cs:xMin		; reset x position
		jg	@@xMinOK		; if > 0 ok to draw
		mov	bp,1			; set flag
		jmp	clipBMExit		; else nothing to draw
@@xMinOK:
		mov	di,ax			; get destination x position
		add	di,cx			; add in width
		cmp	di,cs:xMax		; see if off screen right side
		jle	@@xMaxOK		; nope so ok to draw
		sub	di,cs:XMax		; get amount over
		dec	di
		mov	cs:rightAdjust,di
		mov	cx,cs:xMax		; right side value
		sub	cx,ax			; subtract destination x value
		inc	cx
		jg	@@xMaxOK		; only if something to draw
		mov	bp,1			; set flag as to
		jmp	clipBMExit		; nothing to draw
@@xMaxOK:
		cmp	bx,cs:yMin		; see if below clip y
		jge	@@yMinOK
		sub	bx,cs:yMin
		add	dx,bx			; and height is less
		neg	bx
		mov	cs:topAdjust,bx
		mov	bx,cs:yMin		; reset y position
		jg	@@yMinOK		; if no carry and != 0
		mov	bp,1
		jmp	clipBMExit		; else nothing to draw
@@yMinOK:
		mov	di,bx			; get destination x position
		add	di,dx			; add in width
		cmp	di,cs:yMax		; see if off screen bottom
		jle	clipBMExit		; nope so ok to draw
		mov	dx,cs:yMax
		sub	dx,bx
		inc	dx
		jg	clipBMExit
		mov	bp,1
clipBMExit:
		pop	ds
		pop	di
		
		ret

clipBitmap	Endp

;{----------------------------------------------------------------------}
;{	savebitmap:							}
;{	  save bitmap from screen to memory				}
;{									}
;{	parameters:							}
;{	  es:bx = pointer to bitmap					}
;{	  cx = x position						}
;{	  dx = y position of source					}
;{----------------------------------------------------------------------}
savebitmap	proc	near

		push	di
		push	es
		
		mov	di,bx			; save pointer to bitmap
		mov	ax,cx			; put x in ax register
		mov	bx,dx			; and y in bx
		mov	cx,es:[di]		; get width
		mov	dx,es:[di+2]		; and height

		call	near ptr clipBitmap	; clip bitmap to clip rectangle
		or	bp,bp
		je	@@saveBMOK		; see if all clipped out
		pop	di			; return if so
		pop	es
		ret
@@saveBMOK:
		mov	si,ax			; source pointer
		push	dx
		mov	al,[bx+PageTable]
		mov	dx,TSENGPAGEREG
		out	dx,al
		pop	dx
		shl	bx,1
		add	si,cs:[bx+Ytable]
		add	si,word ptr screen_adr	; and offset of screen address
		mov	ds,word ptr screen_adr+2 ; get segment now

		mov	bp,dx			; because mult kill dx

		mov	ax,es:[di]
		add	di,cs:leftAdjust
		mov	dx,cs:rightAdjust
		add	cs:leftAdjust,dx
		mov	dx,cs:topAdjust
		mul	dx
		add	di,ax
		add	di,4
		mov	dx,bp
		mov	bp,cx

		mov	bx,cs:Ytable+2
		sub	bx,bp			; add value for next line
@@sbHeight:
		mov	cx,bp
		shr	cx,1
		rep	movsw			; move in number of words
		adc	cx,cx
		rep	movsb
		add	si,bx
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:

		add	di,cs:leftAdjust
		dec	dx
		jne	@@sbHeight
		pop	es
		pop	di
		ret

savebitmap	endp

;{----------------------------------------------------------------------}
;{	restorebitmap:							}
;{	  put bitmap from memory to screen 				}
;{									}
;{	parameters:							}
;{	  al = mode for write						}
;{	  es:bx = pointer to bitmap					}
;{	  cx = x position						}
;{	  dx = y position of source					}
;{----------------------------------------------------------------------}
restorebitmap	proc near

		push	di
		push	es
		mov	di,es
		mov	ds,di

		push	ax			; save write mode

		mov	di,bx			; save pointer to bitmap
		mov	ax,cx			; put x in ax register
		mov	bx,dx			; and y in bx
		mov	cx,[di]			; get width
		mov	dx,[di+2]		; and height

		call	near ptr clipBitmap	; clip bitmap to clip rectangle
		or	bp,bp
		je	@@restoreBMOK		; see if all clipped out
		pop	ax
		pop	di			; return if so
		pop	es
		ret
@@restoreBMOK:
		mov	si,di			; save source pointer
		mov	di,ax			; destination pointer
		push	dx
		mov	al,[bx+PageTable]
		mov	dx,TSENGPAGEREG
		out	dx,al
		pop	dx
		shl	bx,1
		add	di,cs:[bx+Ytable]
		add	di,word ptr cs:screen_adr	; and offset of screen address
		mov	es,word ptr cs:screen_adr+2 ; get segment now

		mov	bp,dx			; because mult kills dx

		mov	ax,[si]			; get width of source
		add	si,cs:leftAdjust	; add source left side start
		mov	dx,cs:rightAdjust
		add	cs:leftAdjust,dx
		mov	dx,cs:topAdjust		; get top adjust
		mul	dx
		add	si,ax			; add in top offset
		add	si,4			; bypass width & height words

		mov	dx,bp			; save back height
		mov	bp,cx			; save off width

		pop	ax			; recover write mode
		and	ax,0ffh
		shl	ax,1
		mov	bx,ax
		
		mov	ax,cs:[bx+rasterOp]
		mov	bx,cs:Ytable+2
		sub	bx,bp			; add value for next line
		jmp	ax
;
; -----	Raster move sub-routine
;
rastMove	Proc	Near

		mov	cx,bp
		shr	cx,1
		rep	movsw		; move in number of words
		adc	cx,cx
		rep	movsb
		add	di,bx
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		add	si,cs:leftAdjust
		dec	dx
		jne	rastMove
		pop	es
		pop	di
		ret

rastMove	endp
;
; -----	Raster xor sub-routine even bytes
;
rastXor		Proc	Near

		shr	bp,1
		jc	@@rXorWOdd	; if width is odd do seperate loop
		mov	cx,bp		; setup counter for loop
@@rXorWidth:
		lodsw
		xor	ax,es:[di]
		stosw
		loop	@@rXorWidth
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		add	di,bx		; next line
		add	si,cs:leftAdjust
		dec	dx
		mov	cx,bp		; reset line counter register
		jne	@@rXorWidth
		pop	es
		pop	di
		ret

;
; -----	Raster xor sub-routine odd bytes
;
@@rXorWOdd:
		mov	cx,bp
		lodsb
		xor	al,es:[di]
		stosb
@@rXorWOddLoop:
		lodsw
		xor	ax,es:[di]
		stosw
		loop	@@rXorWOddLoop
		jnc	@@NotNextPage2

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage2:
		add	di,bx
		add	si,cs:leftAdjust
		dec	dx
		jne	@@rXorWOdd
		pop	es
		pop	di
		ret

rastXor		Endp
		
;
; -----	Raster or sub-routine even bytes
;
rastOr		Proc	Near

		shr	bp,1
		jc	@@rOrWOdd	; if width is odd do seperate loop
		mov	cx,bp		; setup counter for loop
@@rOrWidth:
		lodsw
		or	ax,es:[di]
		stosw
		loop	@@rOrWidth
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		add	di,bx		; next line
		add	si,cs:leftAdjust
		dec	dx
		mov	cx,bp		; reset line counter register
		jne	@@rOrWidth
		pop	es
		pop	di
		ret
;
; -----	Raster or sub-routine odd bytes
;
@@rOrWOdd:
		mov	cx,bp
		lodsb
		or	al,es:[di]
		stosb
@@rOrWOddLoop:
		lodsw
		xor	ax,es:[di]
		stosw
		loop	@@rOrWOddLoop
		jnc	@@NotNextPage2

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage2:
		add	di,bx
		add	si,cs:leftAdjust
		dec	dx
		jne	@@rOrWOdd
		pop	es
		pop	di
		ret

rastOr		Endp

;
; -----	Raster and sub-routine even bytes
;
rastAnd		Proc

		shr	bp,1
		jc	@@rAndWOdd	; if width is odd do seperate loop
		mov	cx,bp		; setup counter for loop
@@rAndWidth:
		lodsw
		and	ax,es:[di]
		stosw
		loop	@@rAndWidth
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		add	di,bx		; next line
		add	si,cs:leftAdjust
		dec	dx
		mov	cx,bp		; reset line counter register
		jne	@@rAndWidth
		pop	es
		pop	di
		ret
;
; -----	Raster and sub-routine odd bytes
;
@@rAndWOdd:
		mov	cx,bp
		lodsb
		and	al,es:[di]
		stosb
@@rAndWOddLoop:
		lodsw
		and	ax,es:[di]
		stosw
		loop	@@rAndWOddLoop
		jnc	@@NotNextPage2

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage2:
		add	di,bx
		add	si,cs:leftAdjust
		dec	dx
		jne	@@rAndWOdd
		pop	es
		pop	di
		ret

rastAnd		Endp
;
; -----	Raster not sub-routine even bytes
;
rastXParent	Proc	Near

		mov	ah,cs:transparent
		mov	cx,bp		; setup counter for loop
@@rastXParentLoop:
		lodsb
		cmp	al,ah
		je	@@rastNotXparent
		mov	es:[di],al
@@rastNotXparent:
		inc	di
		loop	@@rastXParentLoop

		add	di,bx		; next line
		jnc	@@NotNextPage

		push	dx
		mov	dx,TSENGPAGEREG
		in	al,dx
		add	al,39h
		out	dx,al
		pop	dx

@@NotNextPage:
		add	si,cs:leftAdjust
		dec	dx
		mov	cx,bp		; reset line counter register
		jne	@@rastXParentLoop
		pop	es
		pop	di
		ret

rastXParent	Endp

restorebitmap	endp


;{----------------------------------------------------------------------}
;{	setclip:							}
;{	  set clipping rectangle to draw in				}
;{									}
;{	parameters:							}
;{	  ax = x Minimum value						}
;{	  bx = y Minimum value						}
;{	  cx = x Maximum value						}
;{	  dx = y Maximum value						}
;{----------------------------------------------------------------------}
setclip		proc	near

		push	si
		mov	si,InstalledTable
		or	ax,ax			; see if x min in range
		jge	.xinRange1
		xor	ax,ax
.xinRange1:
		cmp	ax,cx
		jle	.xinRange2
		xchg	ax,cx
.xinRange2:
		mov	xMin,ax
		cmp	cx,cs:[si].$xres
		jle	.xinRange3
		mov	cx,cs:[si].$xres
.xinRange3:
		mov	xMax,cx

		or	bx,bx			; see if y min in range
		jge	.yinRange1
		xor	bx,bx
.yinRange1:
		cmp	bx,dx
		jle	.yinRange2
		xchg	bx,dx
.yinRange2:
		mov	yMin,bx
		cmp	dx,cs:[si].$yres	; and y max in range
		jle	.yinRange3
		mov	dx,cs:[si].$yres
.yinRange3:
		mov	yMax,dx
		pop	si
		ret

setclip		endp

_TEXT 		ends

		end

