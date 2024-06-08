
		global	ExecuteRtns:far
		global	_detectVideo:far

DGROUP		GROUP 	_DATA

_DATA		segment public 'DATA'

		global DRIVERFLAG:abs

_DATA		ends


agroup		group AUTODETECT

AUTODETECT	Segment	Public 'FAR_DATA'


AUTODETECT	Ends




detectseg	segment 'CODE'

		assume	cs:detectseg, ds:DGROUP

;{----------------------------------------------------------------------}
;{ Function:	char far *dectectVideo(int maxHRez, int maxVRez,	}
;{			int maxColors, int maxPages);			}
;{ Description:	detect best video mode with parameters			}
;{ Parameters:	maxHRez = maximum horizonatal resolution you want	}
;{		maxVRez	= maximum vertical resolution you want		}
;{ 		maxColors = maximum colors you will accept		}
;{		maxPages = maximum pages you will accept		}
;{ Returns:	far pointer to BGI driver name				}
;{----------------------------------------------------------------------}
_detectVideo	Proc	far

		mov	ax,seg AUTODETECT
		xor	bx,bx
		mov	cx,"UA"
		mov	dx,"ED"		; header checks
 		call	far ptr ExecuteRtns
		jnc	@@detectExit
		xor	ax,ax
		xor	dx,dx			; no pointer found anywhere
@@detectExit:
		ret

_detectVideo	Endp

detectseg	ends

		end





