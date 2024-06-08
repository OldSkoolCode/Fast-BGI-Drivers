/*****************************************************************************
   bgimouse.c  -  a quick (and maybe dirty) program that attaches a mouse
			   handler to the Microsoft mouse driver to provide hands-free
			   (interrupt driven) graphics cursor movement.

			   It should work with all BGI drivers, in all graphics modes.
			   It works better (less flicker) with our 16 Super VGA drivers
			   since our getimage/putimage routines are faster.

			   It is useful when using extended VGA modes (as with our
			   Super VGA BGI drivers) where the Microsoft graphics mouse
			   cursor CANNOT be used.

   Compile it as-is to see it work with Borland's BGI drivers
		  ...or if you have a fancy VGA card...
   See comments in main() on how to use our BGI driver with this program.

Written by:
Reagan Thomas  CIS: 73520,2067

Thomas Design
P.O. Box 586
Stillwater, OK 74076


NOTE:  1) When using the mouse handler, it's a always good idea to say
		HideMouse = TRUE;
		when doing a lot of graphics drawing.

*****************************************************************************/

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <graphics.h>
#include <conio.h>
#include <dos.h>

#include "isvgadet.h"
#include "isvga256.h"
#include "vgaextra.h"

/* defines for mouse events */
#define  MOVED        0x01
#define  L_PRESS      0x02
#define  L_RELEASE    0x04
#define  R_PRESS      0x08
#define  R_RELEASE    0x10
#define  M_PRESS      0x20
#define  M_RELEASE    0x40

#define	TRUE		1
#define	FALSE	0

union REGS inreg, outreg;

int	GraphDriver, GraphMode;
int	MaxX, MaxY, ssize;
int	ErrorCode;
void *ptr, *screen;
unsigned MouseBtn, MouseX, MouseY, OldMX, OldMY, OldButt;
unsigned char MouseEvent, HideMouse = 0;
int  XMofs = 0, YMofs = 0, OldxO, OldyO;


/* -------------------------------------------------------------------------
   This is the important routine.  Once it's hooked into the Microsoft mouse
   driver, it keeps mouse variable/events up to date and updates the position
   of the pointer icon
   -------------------------------------------------------------------------*/

void interrupt gfxmousehandler(void) {
unsigned int a, b, c, d;

 a = _AX;            /* save mouse status from uSoft mouse driver */
 b = _BX;
 c = _CX;
 d = _DX;

 OldMX = MouseX;     /* store old mouse status */
 OldMY = MouseY;
 OldButt = MouseBtn;
 MouseEvent |= a;    /* store new mouse status */
 MouseBtn = b;
 MouseX = c;
 MouseY = d;

 if(!HideMouse) {
	if((MouseX != OldxO) || (MouseY != OldyO)) {


 /* Here I was experimenting with Vertical Sync in VGA modes...doesn't make
    much difference and it cause problems (this is an interrupt, you know!)
    Use it with caution.

	while(inport(0x3da) & 0x08);		wait til NOT in retrace
	while(!(inport(0x3da) & 0x08));	wait til very start of retrace  */


 /* update pointer icon position */

		putimage(OldxO, OldyO, screen, COPY_PUT);
		getimage(MouseX, MouseY, MouseX+XMofs, MouseY+YMofs, screen);
		putimage(MouseX, MouseY, ptr, OR_PUT);
		OldxO = MouseX;	OldyO = MouseY;
	}
 }
					/* Recover registers and return to mouse driver */
 __emit__(
		0x8b, 0x0e5,   /*	MOV	SP,BP */
		0x5d,          /*   POP  BP    */
		0x07,          /*   POP  ES    */
		0x1f,          /*   POP  DS    */
		0x5f,          /*   POP  DI    */
		0x5e,          /*   POP  SI    */
		0x5a,          /*   POP  DX    */
		0x59,          /*   POP  CX    */
		0x5b,          /*   POP  BX    */
		0x58,          /*   POP  AX    */
		0x0cb          /*   RETF       */
		);
}


/* initializes the mouse driver */

int init_mouse(void) {
int	test;

 _AX = 0;
 geninterrupt(51);
 test = _AX;
 if(test == 0)
	return(FALSE);
 else
	return(TRUE);
}

/* Enables the text mode mouse cursor */
void mouse_cursor(void) {
 _AX = 1;
 geninterrupt(51);
}

/* Disables the text mode mouse cursor */
void disable_cursor(void) {
 _AX = 2;
 geninterrupt(51);
}

/* Returns the current status of the mouse */
void read_mouse(int *mousex, int *mousey, int *button) {
 _AX = 3;
 geninterrupt(51);
 *button = 3&_BX;
 *mousex = _CX;
 *mousey = _DX;
}

/* Sets the mouse XY counts */
void move_mouse(int mousex, int mousey) {
 _AX = 4;
 _CX = mousex;
 _DX = mousey;
 geninterrupt(51);
}

/* Sets the mouse speed */
void mouse_speed(int speed) {
 _AX = 0x0013;
 _DX = speed;
 geninterrupt(51);
}

/* Set limits for mouse counts */
void mouse_range(int xmin, int ymin, int xmax, int ymax) {
 _AX = 7;
 _CX = xmin;
 _DX = xmax;
 geninterrupt(51);
 _AX = 8;
 _CX = ymin;
 _DX = ymax;
 geninterrupt(51);
}

/* Sets the ratio of X to Y mouse counts */
void mouse_ratio(int xaxis, int yaxis) {
 _AX = 0x000f;
 _CX = xaxis;
 _DX = yaxis;
 geninterrupt(51);
}

/* Installs the mouse handler by hooking into the Microsoft driver */

void InstallMouseHandler(unsigned mask, unsigned taskSeg, unsigned taskOfs) {
struct SREGS seg;

 inreg.x.ax = 12;
 inreg.x.cx = mask;
 inreg.x.dx = taskOfs;
 seg.es = taskSeg;
 int86x(0x33, &inreg, &outreg, &seg);
 }



void main(void) {

 if((init_mouse()) == 0) {
	printf("\nMOUSE DRIVER not active!!!\n\n\n\n\n");
	exit(1);
 }

 /* If you would like to try our Super VGA 16 color integrated driver...
    ...un-comment-out the following line.--
								   |
  -----------------------------------------
 |
 |  NOTE: This driver (ISVGA256.BGI)
 |  supports 256 color modes from 640x400 to 1024x786 on the following VGA
 |  cards: ATI, Techmar, Video7 VRAM, Paradise, Orchid, cards using the
 |  Paradise chipset, the Tseng Labs chipset, the Trident chipset, and those
 |  using the Chips and Tech chipset.
 |  The first five cards listed will autodetect(), but for the others, you
 |  may have the 'force' the driver to be active.  To force the driver, replace
 |  the line:
 |
 |  GraphDriver = DETECT;
 |       with
 |  GraphDriver = 134;
 |
 \/                        */

 installuserdriver("ISVGA256",DetectISVGA256);
 GraphDriver = DETECT;
 initgraph(&GraphDriver, &GraphMode, "");

 ErrorCode = graphresult();
 if(ErrorCode != grOk){
   printf(" Graphics System Error: %s\n", grapherrormsg(ErrorCode));
   exit(1);
 }

 MaxX = getmaxx();
 MaxY = getmaxy();				/* Read size of screen */

 mouse_speed(10);                  /* setup mouse related stuff */
 mouse_ratio(8,15);
 disable_cursor();
 mouse_range(0, 0, MaxX, MaxY);
 move_mouse(80,80);

 setcolor(255);

 setfillstyle(1,1);
 bar(0,0,getmaxx(),getmaxy());
								/* Draw the pointer */
 moveto(26, 36);	lineto(26, 52);
 lineto(30, 51);	lineto(31, 55);
 lineto(36, 54);	lineto(34, 49);
 lineto(37, 47);	lineto(26, 36);

 ssize  = imagesize(26, 36, 37, 55);    /* reserve space for getimage() */
 ptr    = malloc(ssize);
 screen = malloc(ssize);

 setfillstyle(1,4);
 floodfill(29,40,255);
 getimage(26, 36, 37, 55, ptr);         /* 'get' the pointer icon       */
 getimage(100, 100, 111, 119, screen);  /* 'get' some blank screen...   */
 putimage(26, 36, screen, COPY_PUT);    /* ...and cover up the icon     */

 XMofs = 11;	YMofs = 19; /* these vars specify icon size */
 OldxO = 26;	OldyO = 36; /* tell my mouse handler where the icon was drawn */

 InstallMouseHandler(0x15, FP_SEG(gfxmousehandler), FP_OFF(gfxmousehandler));
/*				  ^
				  |__ setup events for movement and buttons released  */


outtextxy(10,100, "Go ahead and move the mouse - press a key to quit");

 while(!kbhit());   /* loop til key pressed, mouse handler does the rest! */
 while(kbhit())
	getch();

 init_mouse();		/* MUST unhook gfx mouse handler before swapping to text...
				...else really HORRIBLE things happen !!!             */
 restorecrtmode();

}

