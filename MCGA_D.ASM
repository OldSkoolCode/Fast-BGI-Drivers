
;
; -----	at start up several modules need to be initialized before
;	their routines can be called the initialize routines are set
;	up in a segment called INITSTART.  Each entry in this segment
;	contains an identifier of GRIN or Grace Initialization.  If
;	this identifier isn't present Grace will assume there are no more
;	entries into this table.  Priority is the priority of the 
;	initialization routine. 0 being the lowest and 65535 being the 
;	highest.  Normally this should be set to 32767.
;

Executehead	struc
identifier	db	4 dup (?)
priority	dw	?
routine		dd	?		; far call to routine to initialize
misc		db	6 dup (?)	; miscellaneous parameters
Executehead	Ends



DGROUP		GROUP 	_DATA

_DATA		segment public 'DATA'

DRIVERFLAG	equ	1


_DATA		ends


AUTODETECT	Segment	Public 'FAR_DATA'

		Executehead	<"AUDE", 32000, mcgaDetect>

AUTODETECT	Ends




mcgaseg		segment 'CODE'

		assume	cs:mcgaseg, ds:DGROUP


mcgaDetect	Proc	far


		ret


mcgaDetect	Endp


mcgaseg		ends

		end





