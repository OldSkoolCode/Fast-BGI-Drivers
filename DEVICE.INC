; ************************************************************************
; File: Device.inc
;
; Copyright (c) 1988,1989  Borland International, Inc.
;
; Purpose: define all the strucs/macros for the BGI interface
;
; Last Update: 9/30/88
;
; Updates:
;
; ************************************************************************

callBGI macro	p
	ifndef	BGI_add				; long call device driver ovr
	extrn	BGI_add:dword			; though pointer to driver
	endif
	mov	si,$&p				; (si) is the function code
	call	dword ptr BGI_add
	endm

BGIstat macro	p				; get es:<si> --> ddo status
	ifndef	stable
	extrn	stable:dword
	endif
	les	si,cs:dword ptr stable		; get location of status to si
	add	si,$&p				; offset to correct location
	endm

; **********************************************************************

; The following macro builds the required BGI header block

BGI	macro	name				; the following macro builds
	public	name				; the required ddo header block
name	proc	far				; the vector table must be at
						; 'ddovec' if vector not speced
	push	ds				; (push ds, push cs are signature)
	push	cs				; make ds=cs
	pop	ds
	cld					; just in case
	push	bp				; 6 bytes
	call	[DDOVEC+si]			; call the local function
	pop	bp
	pop	ds				; restore
	ret					; far
name	endp
	db	'FS'				; just for fun
	dw	?
EMULATE:ret					; emulate function (nop until
	dw	0,0				; patched by loader)
RESERVED:
NONE:	ret					; near ret for unused functions
	endm

; ************** the device driver vector table definition **************

$ddo		struc

$install	dw	?	; install device.
				; required to return es:<bx> to status table.

$init		dw	?	; (bh)=texture (bl)= background color to use.
				; ready device for output.
				; es:[di] --> rotate,xclip1,yclip1,xclip2,yclip2

$clear		dw	?	; clear graphics device and ready it for
				; output.

$post		dw	?	; make picture visible. used for making
				; printer bitmaps visible, for unloading
				; the plotter pen, or for restoring screen.

$move		dw	?	; used by text, arc, symbol, draw, fill etc.
				; set c.p. (ax,bx) = (x,y)

$draw		dw	?	; draw to (ax,bx) = (x,y)

$vect		dw	?	; (ax,bx,cx,dx) = x0,y0,x1,y1

$poly		dw	?	; draw polygon.
				; ax=0 start new polygon definition
				; ax=1 close and trace poly
				; ax=2 close,  fill poly and trace
				; ax=3 close and fill poly
				; ax=4 draw points and don't capture
				; ax=5 turn off polygon capture
				; ax=6 draw polygon at es:[bx] and (cx) points
				; ax=7 fill & trace polygon at es:[bx] with (cx) points
				; ax=8 fill polygon at es:[bx] with (cx) points

$dbar		dw	?	; bar fill (cpx,cpy,ax,bx)=x0,y0,x1,y1
				; (bx,cx)=dx,dy for 3d (with outline)

$patbar		dw	?	; pattern bar (no outline)

$darc		dw	?	; draw arc

$piesl		dw	?	; (ax,bx)= start ang, end ang
				; (cx,dx)= x radius, y radius
				; center is a cp. (with outline)

$fellipse	dw	?	; (ab,bx) = x radius, yradius
				; (no outline)

$palette	dw	?	; load a palette entry
				; (ax)=entry # (bx)=value
				; if (ax)=-1 set background

$allpalette	dw	?	; load the full palette
				; es:[bx] --> palette array

$color		dw	?	; set active draw color & pattern fill color
				; (al)= draw (trace) color (ah)=fill color

$fstyle		dw	?	; (al)=fill pattern #
				; (al)=0 no fill, 1 solid ...
				; (ah)=background color (normally 0)
				; (used only if pattern in al > 80h)
				; if (al)=ff es:<bx>--> pattern definition

$lstyle		dw	?	; (al)=0(solid) 1(dotted) 2(centerline) 3(dash)
				; 4(use pattern) (bx)=bit pattern
				; (cx)=line width (normally one)

$tstyle		dw	?	; (al)=font (ah)=style
				; (bx)=x charsize (cx)=y charsize
				; if (al)=ff es:<bx>--> font definition table
				; changes all params to those available.

$text		dw	?	; draw text. es:<bx> --> <string>, (0)

$textsize	dw	?	; text length.

$textinfo	dw	?	; extended text settings.

$flood		dw	?	; floodfill (ax,bx) = x,y seed coordinate.

$getpix		dw	?	; read pixel @(ax,bx) to (dl)

$putpix		dw	?	; put (dl) to pixel @(ax,bx)

$bitmaputil	dw	?	; returns (es:[bx]) = bitmap utilities.
				;	dw gotographic
				;	dw exitgraphic
				;	dw putpix
				;	dw getpix
				;	dw pixelsperbyte
				;	dw setwritemode

$savebitmap	dw	?	; es:[bx]--> buffer to save bitmap to.
				; contain bitmap size (pixels) in 1st 2 words
				; cx = start x	dx = start line # y


$restorebitmap	dw	?	; es:[bx]--> bitmap buffer to restore.
				; contains bitmap size (pixels) in 1st 2 words
				; cx=start x dx= start y to put
				; (al) = bitblt op (copy, xor, comp, etc.)

$setclip	dw	?	; extended function to set clip window
				; (ax,bx)-(cx,dx) = clip rectangle

$query_color	dw	?	; extended function for color information

$escape		dw	?	; escape function for direct i/o

$symbol		dw	?	; draw symbol (al) = symbol #
				; if (al)=ff es:<bx>--> symbol definition

$reserve	dw	?	; 32 reserved entry points

$user		dw	?	; User available entry points

$ddo		ends

; ************** the device driver status table definition **************

$status struc
$stat	db	0		; 0 = no errors
$devtyp db	0		; device type 0=screen 1=printer 2=plotter
$xres	dw	639		; full resolution
$yres	dw	199
$xefres dw	639		; effective resolution
$yefres dw	199
$xinch	dw	9000		; device size in inches*1000
$yinch	dw	7000
$aspec	dw	21200		; aspect ratio
$chsiz	dw	808h		; standard char size x,y (points)
$coltbl dw	9090h		; color tables
$status ends

; **********************************************************************
; this struc defines the info struc returned from the
; bgi bitmaputil function call @(es:[bx])
$bitmapinfo	struc
$gotographic	dw	?
$exitgraphic	dw	?
$putpixel	dw	?
$getpixel	dw	?
$bitsperpixel	dw	?
$setpage	dw	?	; draw page in (al)
$setvisual	dw	?	; visual display page (al)
$setwritemode	dw	?	; set write mode (al)
$bitmapinfo	ends

; **********************************************************************
; this struc defines the Device Information Table
;
$DIT		struc

$backcolor	db	?	; background color for initializing screen
$initflag	db	?	; Init flag: 0a5h = don't init; anything
				; else = init
$reserved	db	64 dup (?)

$DIT		ends


