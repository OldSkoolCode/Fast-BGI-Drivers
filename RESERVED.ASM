;  These routines use BIOS calls to do all graphing.  Vast improvments can
;  be realized by addressing memory directly, but this is more portable,
;  especially if you want to support yet another graphics mode.

;  The driver starts with a header that contains
;  various pieces of information about itself.
BGI_hdr  segment
         org     0
         db      "pk"                  ; signature for .BGI file
         dw      2056                  ; Sam Denton celebrates 101st b-day!
         db      "This is a simple test .BGI file",26
         dw      -1                    ; patch in correct amount later
         dw      2
         dw      -1                    ; patch in correct amount later
         db      1
         db      0
         db      1
         db      16 dup(0)             ; leave room for move to adjust
                                       ; alignment of BGI_main
BGI_hdr  ends



BGI_main segment
         assume  cs:BGI_main,ds:BGI_main
intro    proc    far
         cld
         push    bp
         push    ds
         push    cs
         pop     ds
         call    [jmp_tbl+si]          ; invoke proper internal routine
         pop     ds
         pop     bp
         ret
intro    endp



;  If we don't know how do do something, let Charlie do it!
;  (The five bytes at offset 16 into the segment are overwritten
;  by the GRAPH unit with a call FAR instruction to code that can
;  handle many 'difficult' procedures.)
         org     intro+16
charlie  proc    near;
         ret
         nop
         nop
         nop
         nop
ignore:  ret
charlie  endp




jmp_tbl  label word
         dw    offset get_info         ; 00 get driver information
         dw    offset set_mode         ; 02 initialize graphics hardware
         dw    offset clr_screen       ; 04 ClrScr
         dw    offset ignore           ; 06 no-op
         dw    offset move_to          ; 08 MoveTo(AX,BX)
         dw    offset line_to          ; 0A LineTo(AX,BX)
         dw    offset line             ; 0C Line(AX,BX,CX,DX)
         dw    offset charlie          ; 0E draw polygon
         dw    offset charlie          ; 10 Bar3D(cp.x,cp.y,AX,BX,CX,DX)
         dw    offset fill_area        ; 12 Bar(AX,BX,CX,DX)
         dw    offset charlie          ; 14 Ellipse(cp.x,cp.y,AX,BX,CX,DX)
         dw    offset ignore          ;; 16 PieSlice(cp.x,cp.y,AX,BX,CX)
         dw    offset ignore           ; 18 no op
         dw    offset set_background   ; 1A SetBkColor(BX)
         dw    offset unknown          ; 1C unknown
         dw    offset set_color        ; 1E SetColor
         dw    offset set_fill         ; 20 SetFillStyle/Pattern(AX,[ES:BX])
         dw    offset set_line         ; 22 SetLineStyle(AX,BX)
         dw    offset charlie          ; 24 SetTextStyle
         dw    offset out_text         ; 26 OutText
         dw    offset text_size        ; 28 TextSize
         dw    offset ignore           ; 2A no op
         dw    offset flood_fill       ; 2C FloodFill(AX,BX,CX)
         dw    offset get_pixel        ; 2E GetPixel(AX,BX) :- DX
         dw    offset put_pixel        ; 30 PutPixel(AX,BX,DL)
         dw    offset strange          ; 32 get additional entry points
         dw    offset get_image        ; 34 GetImage
         dw    offset put_image        ; 36 PutImage
         dw    offset set_viewport     ; 38 SetViewport(AX,BX,CX,DX)
more     label word
         dw    4 dup(offset ignore)
         dw    offset pixels
         dw    offset ignore
x_min    dw    ?
y_min    dw    ?
x_max    dw    ?
y_max    dw    ?
x_cp     dw    ?
y_cp     dw    ?
std_pat  dw    0FFFFh,9999h,8FF1h,0C3C3h
my_colr  dw    ?
my_line  dw    ?
std_fill db    8 dup(0),8 dup(0FFh),2 dup(0,0FFh,0FFh,0)  ; Empty, Solid, Line
         db    080h,040h,020h,010h,008h,004h,002h,001h    ; LtSlash
         db    0C1h,0E0h,070h,038h,01Ch,00Eh,007h,083h    ; Slash
         db    083h,007h,00Eh,01Ch,038h,070h,0E0h,0C1h    ; BkSlash
         db    001h,002h,004h,008h,010h,020h,040h,080h    ; LtBkSlash
         db    4 dup(8),0FFh,3 dup(8)                     ; Hatch
         db    2 dup(081h,042h,024h,018h)                 ; XHatch
         db    4 dup(055h,0AAh)                           ; Interleave
         db    4 dup(0),080h,3 dup(0)                     ; WideDot
         db    2 dup(088h,0,044h,0)                       ; CloseDot
my_fill  db    20h,20h,0FFh,20h,20h,20h,20h,20h
l_x1     dw    ?
l_y1     dw    ?
l_x2     dw    ?
l_y2     dw    ?
l_dx     dw    ?
l_sx     dw    ?
l_dy     dw    ?
l_sy     dw    ?
l_er     dw    ?
l_i1     dw    ?
l_i2     dw    ?
counter  dw    ?
pointer  dd    ?
charset  dd    ?
desc_txt db    "My own device driver"
desc_tbl dw    0                                          ; unknown
         dw    319,199                                    ; getmaxx,getmaxy
         dw    319,199,7000,8750                          ; ditto?,ditto?,?,?
         dw    8333                                       ; aspect ratio
         db    8,8,90h,90h                                ; colors/palettes?



get_info       proc near
         cmp   al,1
         jne   try2
         mov   cx,1
         ret
try2:
         push  ds
         pop   es
         cmp   al,2
         jne   misc
         mov   bx,offset desc_txt
         ret
misc:
         mov   bx,offset desc_tbl
         ret
get_info       endp



set_mode       proc near
         mov   ax,13h                  ; we can use any old mode ...
         int   10h                     ; ... provided BIOS supports it
         mov   ax,1010h                ; set VGA palette entry
         mov   bl,255                  ; last entry (normally black)
         mov   dh,255                  ; set red on full
         mov   ch,255                  ; set green on full
         mov   cl,255                  ; set blue on full
         int   10h                     ; do it!
         ret
set_mode       endp



clr_screen     proc near
         mov   ax,13h                  ; Use any old mode
         int   10h                     ; provided BIOS supports it
         ret
clr_screen     endp



move_to        proc near
         mov   x_cp,ax
         mov   y_cp,bx
         ret
move_to        endp



line_to        proc near
         mov   cx,ax
         mov   dx,bx
         xchg  ax,x_cp
         xchg  bx,y_cp
;        jmp   line                    ; ok if line immediately follows
line_to        endp



;   procedure Bresenham(x1,y1,x2,y2,c : integer);
;   { adapted from J. D. Foley and A. van Dam, "Fundamentals of Interactive
;     Computer Graphics", Addison-Wesley, Reading, Massachusetts, 1984. }
;   var
;     x,y,dx,dy,sx,sy,i1,i2,er : integer;
;
;   begin
;     if x1 > x2 then
;       begin
;         dx := x1 - x2;
;         sx := -1;
;       end
;     else
;       begin
;         dx := x2 - x1;
;         sx := +1;
;       end;
;     if y1 > y2 then
;       begin
;         dy := y1 - y2;
;         sy := -1;
;       end
;     else
;       begin
;         dy := y2 - y1;
;         sy := +1;
;       end;
;     x := x1;
;     y := y1;
;     putpixel(x,y,c);
;     if dx >= dy then
;       begin
;         d  := 2 * dy - dx;
;         i1 := 2 * dy;
;         i2 := 2 * (dy - dx);
;         while x <> x2 do
;           begin
;             x := x + sx;
;             if d < 0 then
;               d := d + i1
;             else
;               begin
;                 y := y + sy;
;                 d := d + i2;
;               end;
;             putpixel(x,y,c);
;           end;
;       end
;     else
;       begin
;         d  := 2 * dx - dy;
;         i1 := 2 * dx;
;         i2 := 2 * (dx - dy);
;         while y <> y2 do
;           begin
;             y := y + sy;
;             if d < 0 then
;               d := d + i1
;             else
;               begin
;                 x := x + sx;
;                 d := d + i2;
;               end;
;             putpixel(x,y,c);
;           end;
;       end
;   end;
line           proc near
; hand-optimized and enhanced by Sam Denton
         mov   l_x1,ax                 ; store params for later
         mov   l_y1,bx
         mov   l_x2,cx
         mov   l_y2,dx
         xor   bx,bx                   ; check direction
         sub   ax,cx
         jz    lx_z
         js    lx_s
         dec   bx
         jmp   short lx_z
lx_s:    inc   bx
         neg   ax
lx_z:    mov   l_dx,ax
         mov   l_sx,bx
         mov   ax,l_y1                 ; check y direction
         xor   bx,bx
         sub   ax,dx
         jz    ly_z
         js    ly_s
         dec   bx
         jmp   short ly_z
ly_s:    inc   bx
         neg   ax
ly_z:    mov   l_dy,ax
         mov   l_sy,bx
         mov   bx,my_line              ; initialize bx with pattern
         mov   cx,l_x1                 ; initialize regs for BIOS
         mov   dx,l_y1
         cmp   ax,l_dx                 ; are we drawing mostly x or y
         jns   ly_draw

lx_draw:
         mov   ax,l_dy                 ; calc i1,i2,error
         shl   ax,1
         mov   l_i1,ax                 ; i1 := 2*dy
         sub   ax,l_dx
         mov   l_er,ax                 ; er := 2*dy - dx
         sub   ax,l_dx
         mov   l_i2,ax                 ; i2 := 2*dy - 2*dx
         jmp   short lx_plot           ; start in middle of loop

lx_loop: add   cx,l_sx                 ; x := x + 1
         mov   ax,l_er
         cmp   ax,0
         jge   lx_y                    ; if er < 0 then
         add   ax,l_i1                 ;   er := er + i1
         jmp   short lx_pt             ; else
lx_y:    add   ax,l_i2                 ;   er := er + i2
         add   dx,l_sy                 ;   y := y + 1
lx_pt:   mov   l_er,ax
lx_plot: rol   bx,1                    ; check pattern
         mov   ax,my_colr              ; tell BIOS to plot point
         jc    lx_skip
         mov   al,0
lx_skip: int   10h
         cmp   cx,l_x2                 ; are we done?
         jne   lx_loop
         ret

ly_draw:                               ; comments are same as above
         mov   ax,l_dx
         shl   ax,1
         mov   l_i1,ax
         sub   ax,l_dy
         mov   l_er,ax
         sub   ax,l_dy
         mov   l_i2,ax
         jmp   short ly_plot
ly_loop: add   dx,l_sy
         mov   ax,l_er
         cmp   ax,0
         jge   ly_x
         add   ax,l_i1
         jmp   short ly_pt
ly_x:    add   ax,l_i2
         add   cx,l_sx
ly_pt:   mov   l_er,ax
ly_plot: rol   bx,1
         mov   ax,my_colr
         jc    ly_skip
         mov   al,0
ly_skip: int   10h
         cmp   dx,l_y2
         jne   ly_loop
         ret
line           endp



out_text       proc near
         mov   counter,cx              ; save number of chars
         mov   word ptr pointer,bx     ; save offset
         mov   word ptr pointer+2,es   ; save segment
         mov   ax,1130h                ; ask BIOS for characters
         mov   bh,1                    ; 8x8 patterns
         int   10h                     ; BIOS video services
         mov   word ptr charset,bp     ; save offset
         mov   word ptr charset+2,es   ; save segment
ot_loop: mov   dx,y_cp                 ; where to start drawing
         mov   di,8                    ; height of character
         les   bx,pointer
         mov   al,byte ptr es:[bx]     ; get a character
         cbw
         mov   cl,3                    ; multiply by eight
         shl   ax,cl
         les   bx,charset              ; get pointer to patterns
         add   bx,ax                   ; point to correct char
ot_vert: mov   cx,x_cp                 ; where to start drawing
         mov   si,8                    ; width of character
         push  bx                      ; save for later
         mov   bl,byte ptr es:[bx]     ; get a row of bits
ot_horz: rol   bl,1
         mov   ax,my_colr
         jc    ot_skip
         mov   al,0
ot_skip: int   10h
         inc   cx                      ; next spot along x
         dec   si                      ; done all eight bits yet?
         jnz   ot_horz
         pop   bx                      ; recover value
         inc   bx                      ; point to next row of pixels
         inc   dx                      ; next spot along y
         dec   di                      ; done all eight bytes yet?
         jnz   ot_vert
         mov   cx,x_cp                 ; move to start of next character
         add   cx,8                    ; width of character
         mov   x_cp,cx                 ; where to start drawing
         inc   word ptr pointer        ; point to next character
         dec   counter                 ; done all characters yet?
         jnz   ot_loop
         ret
out_text       endp



text_size      proc near
         mov   ax,8
         mul   cx
         mov   cx,ax
         mov   bx,8
         ret
text_size      endp



fill_area      proc near
; coded by Sam Denton by the seat of his pants (i.e. not optimized)
         mov   l_x1,ax                 ; find left side
         sub   ax,cx
         js    fax_s
         mov   l_x1,cx
         neg   ax
fax_s:   dec   ax
         mov   l_dx,ax                 ; find (negative) width

         mov   l_y1,bx                 ; find top side
         sub   bx,dx
         js    fay_s
         mov   l_y1,dx
         neg   bx
fay_s:   dec   bx
         mov   l_dy,bx                 ; find (negative) height

fa_loop: mov   di,l_dx                 ; this is a NEGATIVE number
         mov   si,l_y1
         and   si,7
         mov   bl,my_fill[si]
         mov   cx,l_x1
         and   cx,7
fa_just: jcxz  fa_fill
         rol   bl,1
         dec   cx
         jmp   fa_just
fa_fill: mov   cx,l_x1
         mov   dx,l_y1
fa_horz: rol   bl,1
         mov   ax,my_colr
         jc    fa_skip
         mov   al,0
fa_skip: int   10h
         inc   cx
         inc   di                      ; this is a NEGATIVE number
         jnz   fa_horz
         inc   l_y1
         inc   l_dy                    ; this is a NEGATIVE number
         jnz   fa_loop
         ret
fill_area      endp



set_background proc near
; should set palette entry zero (background) to indicated color
         ret
set_background endp



unknown        proc near
         ret
unknown        endp



set_color      proc near
; set current drawing color to indicated palette entry
         mov   ah,12
         mov   my_colr,ax              ; save reg contents for BIOS
         ret
set_color      endp



set_fill       proc near
         cmp   ax,-1
         je    sf_user
         cbw
         mov   cl,3
         shl   ax,cl
         mov   si,ax
         add   si,offset std_fill
         jmp   short sf_copy
sf_user: push  bx
         pop   si
         push  es
         pop   ds
sf_copy: mov   di,offset my_fill
         push  cs
         pop   es
         mov   cx,8
   rep   movsb
         ret
set_fill       endp



set_line       proc near
         cmp   ax,4
         ja    sl_ret
         je    sl_save
         shl   ax,1
         mov   si,ax
         mov   bx,std_pat+[si]
sl_save: mov   my_line,bx
;        mov   thickns,cx              ; not needed, effect handled in GRAPH
sl_ret:  ret
set_line       endp



flood_fill     proc near
         ret
flood_fill     endp



get_pixel      proc near
         mov   dx,-1
;        or    ax,ax
;        js    gp_done
;        add   ax,x_min
;        cmp   ax,x_max
;        ja    gp_done
;        or    bx,bx
;        js    gp_done
;        add   bx,y_min
;        cmp   bx,y_max
;        ja    gp_done
         mov   cx,ax
         mov   dx,bx
         mov   ah,13
         int   10h
         xor   ah,ah
         mov   dx,ax
gp_done:
         ret
get_pixel      endp



put_pixel      proc near
         push  dx
         mov   cx,ax
         mov   dx,bx
         pop   ax
         mov   ah,12
;        or    cx,cx
;        js    pp_done
;        add   cx,x_min
;        cmp   cx,x_max
;        ja    pp_done
;        or    dx,dx
;        js    pp_done
;        add   dx,y_min
;        cmp   dx,y_max
;        ja    pp_done
         int   10h
pp_done:
         ret
put_pixel      endp



strange        proc near
         mov   bx,offset more
         push  ds
         pop   es
         ret
strange        endp



pixels         proc far
         mov   ax,8                    ; each pixel occupies 8 bits
         ret
pixels         endp



get_image      proc near
         mov   l_x1,cx                 ; save left side
         mov   si,word ptr es:[bx]     ; get image width
         mov   l_dx,si                 ; save it
         mov   l_sx,si                 ; save it again
         add   bx,2                    ; bump ptr
         mov   si,word ptr es:[bx]     ; get image height
         mov   l_dy,si                 ; save it
         add   bx,2                    ; bump ptr
gi_loop:
         mov   ah,13
         int   10h
         mov   byte ptr es:[bx],al     ; save pixel
         inc   bx
         inc   cx
         dec   l_dx
         jge   gi_loop
         mov   cx,l_x1                 ; restart at beginning of column
         mov   si,l_sx
         mov   l_dx,si
         inc   dx                      ; but one row down
         dec   l_dy
         jge   gi_loop
         ret
get_image      endp



rasterop       label word
         dw    offset pi_mov
         dw    offset pi_xor
         dw    offset pi_or
         dw    offset pi_and
         dw    offset pi_not
put_image      proc near
         cbw
         shl   ax,1
         mov   si,ax
         mov   di,rasterop[si]
         mov   l_x1,cx                 ; save left side
         mov   si,word ptr es:[bx]     ; get image width
         mov   l_dx,si                 ; save it
         mov   l_sx,si                 ; save it again
         add   bx,2                    ; bump ptr
         mov   si,word ptr es:[bx]     ; get image height
         mov   l_dy,si                 ; save it
         add   bx,2                    ; bump ptr
pi_loop:
         mov   ah,13
         int   10h
         mov   si,ax                   ; get current pixel
         mov   al,byte ptr es:[bx]     ; get desired pixel
         jmp   di                      ; perform raster op
pi_xor:
         xor   ax,si
         jmp   short pi_mov
pi_or:
         or    ax,si
         jmp   short pi_mov
pi_and:
         and   ax,si
         jmp   short pi_mov
pi_not:
         not   ax
pi_mov:
         mov   ah,12
         int   10h
         inc   bx
         inc   cx
         dec   l_dx
         jge   pi_loop
         mov   cx,l_x1                 ; restart at beginning of column
         mov   si,l_sx
         mov   l_dx,si
         inc   dx                      ; but one row down
         dec   l_dy
         jge   pi_loop
         ret
put_image      endp



set_viewport   proc near
         mov   x_min,ax
         mov   y_min,bx
         mov   x_max,cx
         mov   y_max,dx
         ret
set_viewport   endp



BGI_main ends
         end
