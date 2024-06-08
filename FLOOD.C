#include <dos.h>
#include <graphics.h>
#include <alloc.h>
#include <stdlib.h>
   int g_driver,g_mode,g_error;
   int x;

static long stime ;		       /* time-of-day from last call*/

struct PTS {
  int x, y;
};	/* Structure to hold vertex points	*/

int jztimer(void) {        /* count elapsed time since last call (in ticks) */
union REGS sreg , dreg ;
long etime , delta ;

 sreg.x.ax = 0 ;		     /* operation = get time count */
 int86(0x1a,&sreg,&dreg);	    /* do software interrupt */
				       /* assemble 32-bit TOD value */
 etime = ( ((long) dreg.x.cx) << 16 ) + dreg.x.dx;
 delta = etime - stime ;
 if( (dreg.x.ax & 0xff) != 0)       /* new day since last call? */
    delta = delta + 0x01800B0L ;   /* yes-add 1 day in ticks*/
 stime = etime ;		       /* save TOD for next call */
 return( (int) (delta / 18 )) ;	      /* return as an integer */
}


void main() {
char temp[20];
int i;
  struct PTS poly[ 6 ];		/* Space to hold datapoints	*/

 printf("\nMode: ");
 gets(temp);
 g_mode = atoi(temp);
    installuserdriver("ISVGA256",NULL);
    g_driver = 134;
    initgraph(&g_driver,&g_mode,"");

    g_error = graphresult();
    if (g_error != 0) {
       printf("%s \n",grapherrormsg(g_error));
       exit(1);
    }
    settextstyle(0,HORIZ_DIR,1);
    outtextxy(50,50,"Sample Text");
    getch();
 jztimer();
    setfillstyle(SOLID_FILL,120);
    setcolor(75);
    fillellipse(85,75,50,50);
    setcolor(3);
    setfillstyle(EMPTY_FILL,0);
    poly[0].x = 50;
    poly[0].y = 50;
    poly[1].x = 75;
    poly[1].y = 30;
    poly[2].x = 150;
    poly[2].y = 50;
    poly[3].x = 225;
    poly[3].y = 18;
    poly[4].x = 290;
    poly[4].y = 150;
    poly[5].x = 150;
    poly[5].y = 100;
    poly[6].x = 10;
    poly[6].y = 180;
    poly[7].x = 50;
    poly[7].y = 50;
    fillpoly( 8, (int far *)poly );    /* Draw the actual polygon	    */

      setfillstyle(XHATCH_FILL,4);
      floodfill(75,75,3);
    getch();
    restorecrtmode();
 printf("\nIt took %d seconds to do 300 circles with our driver.\n", jztimer());

}
