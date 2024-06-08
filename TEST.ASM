


		.model tiny

biosseg		segment at 0
		org	4a8h
saveTabPtr	dd	?

biosseg		ends

		.code
		org	100h
start:
		mov	ax,29h
		int	10h			; 800x600 16 color
	
		xor	ax,ax
		mov	ds,ax

		assume	ds:biosseg
		lds	si,saveTabPtr
		lds	si,[si]			; get parameter save table

		push	cs
		pop	es
		mov	di,offset tempmem

		mov	cx,40h/2
		rep	movsw

		mov	ax,03
		int	10h

		mov	ax,4c00h
		int	21h

tempmem		label	byte


		end	start
