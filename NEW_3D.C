
#include <graphics.h>
#include <stdio.h>
#include <dos.h>
#include <conio.h>
#include <math.h>
#include <alloc.h>

typedef unsigned char      Byte;
typedef unsigned int       Word;
typedef unsigned long      DWord;

typedef enum {false, true} Boolean;

typedef struct
{
  Byte Red;
  Byte Grn;
  Byte Blu;
} RGB;

typedef RGB Palette_Register[256];

typedef float TDA[3];
typedef int   TDIA[3];
typedef float FDA[4];
typedef float Matx4x4[4][4];

#define MaxCol   7
#define MaxInten 35

#define Ln10			2.30258509299405E+000
#define OneOverLn10	0.43429448190325E+000
#define Pi				3.1415927
#define PiOver180		1.74532925199433E-002
#define PiUnder180	5.72957795130823E+001

union REGS		reg;
struct SREGS	inreg;
int				XRes, YRes;
Word				MaxXRes, MaxYRes;
Word				MaxX, MaxY;
float				Asp;
Boolean			PerspectivePlot;
float				Mx, My, Mz, ds;
Boolean			Draw_Axis_And_Palette;
int				Angl, Tilt;

Word				X_Off, Y_Off;
static Word far	*Pre_Calc_Y1;
static DWord far	*Pre_Calc_Y2;
static Byte		Res;
int				CentreX, CentreY;

#define Low_Res    1
#define Medium_Res 2
#define High_Res   3

/* ************************************************************************
   *									  *
   *		       	    Mathematical Functions                        *
   *									  *
   ************************************************************************

   Radians   - converts degrees to radians
   Degrees   - converts radians to degrees
   CosD	     - cosine in degrees
   SinD	     - sine in degrees
   Power     - power a^n
   Log       - log base 10
   Exp10     - exp base 10
   Sign      - negative=-1  positive=1  null=0
   IntSign   - negative=-1  positive=1  null=0
   IntSqrt   - integer square root
   IntPower  - integer power a^n
*/

int Round(double x)
{
  return((int)(x+0.5));
}

int Trunc(double x)
{
  return((int)(x));
}

float Frac(double x)
{
  int y;

  y=((int)(x));
  return(x-(float)y);
}

float SqrFP(float x)
{
  return(x*x);
}

int Sqr(int x)
{
  return(x*x);
}

float Radians(float Angle)
{
  return(Angle*PiOver180);
}

float Degrees(float Angle)
{
  return(Angle*PiUnder180);
}

float CosD(float Angle)
{
  return(cos(Radians(Angle)));
}

float SinD(float Angle)
{
  return(sin(Radians(Angle)));
}

/***********************************************************************
			Video Graphics Array Driver
 ***********************************************************************

   Plot		 - place pixel to screen
   Set_Palette	 - set palette register
   Init_Palette2 - 7 colors with 35 intensities each - use with Pixel
   Draw		 - line draw routine
   Init_Graphics - initialize graphics
   Wait_For_Key	 - wait for key press
   Exit_Graphics - sound and wait for keypress before exiting graphics
*/

void Calc_Offsets()
{
  Word tmp, tmp2;

  if(XRes<MaxXRes)
  {
    tmp=MaxXRes>>1;
    tmp2=XRes>>1;
    X_Off=tmp-tmp2;
  }
  else
    X_Off=0;
  if(YRes<MaxYRes)
  {
    tmp=MaxYRes>>1;
    tmp2=YRes>>1;
    Y_Off=tmp-tmp2;
  }
  else
    Y_Off=0;
}

void Pre_Calc()
{
	Word j;

	for(j=0; j<=MaxYRes; j++)
		Pre_Calc_Y1[j]=MaxXRes*j;
}

static Word Old_Page, Old_Page_2;

void Plot(Word x, Word y, Byte color)
{
	long		L_Offset;
	Word		Offset,Page;
	char far	*address;

  if ((x<XRes) && (y<YRes)) {
		Offset=Pre_Calc_Y1[y+Y_Off]+x+X_Off;
		address=(char far *)(0xA0000000L+Offset);
		*address=color;
	}
}

static Palette_Register Color;

void Set_Palette(Palette_Register Hue)
{
  reg.x.ax=0x1012;
  segread(&inreg);
  inreg.es=inreg.ds;
  reg.x.bx=0;
  reg.x.cx=256;
  reg.x.dx=(int)&Hue[0];
  int86x(0x10,&reg,&reg,&inreg);
}

void Swap(int *first, int *second)
{
  int temp;

  temp=*first;
  *first=*second;
  *second=temp;
}

void Draw(int xx1, int yy1, int xx2, int yy2, Byte color)
{
  int LgDelta, ShDelta, Cycle, LgStep, ShStep, dtotal;

  LgDelta=xx2-xx1;
  ShDelta=yy2-yy1;
  if(LgDelta<0)
  {
    LgDelta=-LgDelta;
    LgStep=-1;
  }
  else
    LgStep=1;
  if(ShDelta<0)
  {
    ShDelta=-ShDelta;
    ShStep=-1;
  }
  else
    ShStep=1;
  if(ShDelta<LgDelta)
  {
    Cycle=LgDelta>>1;
    while(xx1!=xx2)
    {
      Plot(xx1, yy1, color);
      Cycle+=ShDelta;
      if(Cycle>LgDelta)
      {
	Cycle-=LgDelta;
	yy1+=ShStep;
      }
      xx1+=LgStep;
    }
    Plot(xx1, yy1, color);
  }
  else
  {
    Cycle=ShDelta >> 1;
    Swap(&LgDelta, &ShDelta);
    Swap(&LgStep, &ShStep);
    while(yy1 != yy2)
    {
      Plot(xx1, yy1, color);
      Cycle+=ShDelta;
      if(Cycle>LgDelta)
      {
	Cycle-=LgDelta;
	xx1+=ShStep;
      }
      yy1+=LgStep;
    }
    Plot(xx1, yy1, color);
  }
}

void Init_Palette_2(Palette_Register Color)
{
  Word i;

  for(i=0; i<36; i++)
  {
    Color[i].Red=0;
    Color[i].Grn=0;
    Color[i].Blu=Round(1.8*i);
  }
  for(i=36; i<72; i++)
  {
    Color[i].Red=0;
    Color[i].Grn=Round(1.8*(i-36));
    Color[i].Blu=0;
  }
  for(i=72; i<108; i++)
  {
    Color[i].Red=0;
    Color[i].Grn=Round(1.8*(i-72));
    Color[i].Blu=Round(1.8*(i-72));
  }
  for(i=108; i<144; i++)
  {
    Color[i].Red=Round(1.8*(i-108));
    Color[i].Grn=0;
    Color[i].Blu=0;
  }
  for(i=144; i<180; i++)
  {
    Color[i].Red=Round(1.8*(i-144));
    Color[i].Grn=0;
    Color[i].Blu=Round(1.8*(i-144));
  }
  for(i=180; i<216; i++)
  {
    Color[i].Red=Round(1.8*(i-180));
    Color[i].Grn=Round(1.8*(i-180));
    Color[i].Blu=0;
  }
  for(i=216; i<252; i++)
  {
    Color[i].Red=Round(1.8*(i-216));
    Color[i].Grn=Round(1.8*(i-216));
    Color[i].Blu=Round(1.8*(i-216));
  }
}

void Init_Graphics()
{
	Res=Low_Res;
	MaxXRes=320;
	MaxYRes=200;
	MaxX=MaxXRes-1;
	MaxY=MaxYRes-1;
	if (XRes==0)
		XRes=MaxXRes;
	if (YRes==0)
		YRes=MaxYRes;
	CentreX=XRes/2;
	CentreY=YRes/2;
	Asp=(1024.0/768.0)*((float)YRes/(float)XRes);
	Pre_Calc();
	Init_Palette_2(Color);
	Set_Palette(Color);
}

void Wait_For_Key()
{
	while(!getch())
		;
}

void Exit_Graphics()
{
	if(Pre_Calc_Y1>0)
		farfree(Pre_Calc_Y1);
	if(Pre_Calc_Y2>0)
		farfree(Pre_Calc_Y2);
	Wait_For_Key();
	closegraph();
}

/* **********************************************************************
   *                                                                    *
   *             Three Dimensional Plotting Routines                    *
   *								        *
   **********************************************************************

   InitPlotting       - rotation and tilt angles
   InitPerspective    - observer location and distances
   MapCoordinates     - maps 3D space onto the 2D screen
*/

float CosA, SinA;
float CosB, SinB;
float CosACosB, SinASinB;
float CosASinB, SinACosB;

void Init_Plotting(int Ang, int Tlt)
{
  CentreX=XRes/2;
  CentreY=YRes/2;
  Angl=Ang;
  Tilt=Tlt;
  CosA=CosD(Angl);
  SinA=SinD(Angl);
  CosB=CosD(Tilt);
  SinB=SinD(Tilt);
  CosACosB=CosA*CosB;
  SinASinB=SinA*SinB;
  CosASinB=CosA*SinB;
  SinACosB=SinA*CosB;
}

void Init_Perspective(Boolean Perspective, float x, float y, float z, float m)
{
  PerspectivePlot=Perspective;
  Mx=x;
  My=y;
  Mz=z;
  ds=m;
}

void Map_Coordinates(float X, float Y, float Z, int *Xp, int *Yp)
{
  float Xt, Yt, Zt;
  float OneOverZt;

  Xt=(Mx+X*CosA-Y*SinA);
  Yt=(My+X*SinASinB+Y*CosASinB+Z*CosB);
  if(PerspectivePlot)
  {
    Zt=Mz+X*SinACosB+Y*CosACosB-Z*SinB;
    OneOverZt=1.0/Zt;
    *Xp=CentreX+Round(ds*Xt*OneOverZt);
    *Yp=CentreY-Round(ds*Yt*OneOverZt*Asp);
  }
  else
  {
    *Xp=CentreX+Round(Xt);
    *Yp=CentreY-Round(Yt*Asp);
  }
}

#define	IMAGE_SIZE	15

float	House[IMAGE_SIZE*6] = {
	54.0, 0.0, 0.0,54.0,16.0, 0.0,	/* Front */
	54.0,16.0, 0.0,54.0,16.0,10.0,
	54.0,16.0,10.0,54.0, 8.0,16.0,
	54.0, 8.0,16.0,54.0, 0.0,10.0,
	54.0, 0.0,10.0,54.0, 0.0, 0.0,

	54.0, 0.0, 0.0,30.0, 0.0, 0.0,	/* Connections */
	54.0,16.0, 0.0,30.0,16.0, 0.0,
	54.0,16.0,10.0,30.0,16.0,10.0,
	54.0, 8.0,16.0,30.0, 8.0,16.0,
	54.0, 0.0,10.0,30.0, 0.0,10.0,

	30.0, 0.0, 0.0,30.0,16.0, 0.0,	/* Back */
	30.0,16.0, 0.0,30.0,16.0,10.0,
	30.0,16.0,10.0,30.0, 8.0,16.0,
	30.0, 8.0,16.0,30.0, 0.0,10.0,
	30.0, 0.0,10.0,30.0, 0.0, 0.0
};

#define	AXIS_SIZE	11

float	Axis_3d[] = {
	-100.0,   0.0,   0.0,  100.0,   0.0,   0.0,	/* X Axis */
	 100.0,  20.0,   0.0,   90.0,  10.0,   0.0,
	 100.0,  10.0,   0.0,   90.0,  20.0,   0.0,

	   0.0,-100.0,   0.0,    0.0, 100.0,   0.0,	/* Y Axis */
	  20.0, 100.0,   0.0,   15.0,  95.0,   0.0,
	  15.0,  95.0,   0.0,   20.0,  90.0,   0.0,
	  15.0,  95.0,   0.0,   10.0,  95.0,   0.0,

	   0.0,   0.0,-100.0,    0.0,   0.0, 100.0,	/* Z Axis */
	   0.0,  20.0, 100.0,    0.0,  20.0,  90.0,
	   0.0,  20.0,  90.0,    0.0,  10.0, 100.0,
	   0.0,  10.0, 100.0,    0.0,  10.0,  90.0
};

void
Draw_Axis(int color)
{
	int	i,j;
	int	X1,Y1,X2,Y2;

	j = 0;
	for (i=0; i<AXIS_SIZE; i++) {
		Map_Coordinates(Axis_3d[j], Axis_3d[j+1], Axis_3d[j+2], &X1, &Y1);
		j += 3;
		Map_Coordinates(Axis_3d[j], Axis_3d[j+1], Axis_3d[j+2], &X2, &Y2);
		j += 3;
		if ((X1 >= 0 && X1 < 320 && Y1 >= 0 && Y1 < 200) &&
			(X2 >= 0 && X2 < 320 && Y2 >= 0 && Y2 < 200)) {
			setcolor(color);
			line(X1,Y1,X2,Y2);
		}
	}
}

int huge
detectMCGA(void)
{
	return(0);		/* return mode found */
}

void main()
{
	int	i,j;
	int	X1,Y1,X2,Y2;
	float	size;
	int	GraphMode;
	int	GraphDriver;

	GraphMode = installuserdriver("mcga", detectMCGA);
	GraphDriver = DETECT; 		/* Request auto-detection	*/
	initgraph( &GraphDriver, &GraphMode, "" );


	Init_Perspective(true, 0.0, 0.0, 200.0, 200.0);
	Init_Plotting(90.0, 0.0);

	for (size=0.0; size<360.0; size += 5.0) {
		Init_Plotting(size, size);
		Draw_Axis(205);
		Draw_Axis(0);
	}
	Exit_Graphics();
	exit(0);

	for (size=100.0; size<2000.0; size += 50.0) {
		ds = size;
		j = 0;
		/* Other colors = 143, 169, 205 */
		for (i=0; i<IMAGE_SIZE; i++) {
			Map_Coordinates(House[j], House[j+1], House[j+2], &X1, &Y1);
			j += 3;
			Map_Coordinates(House[j], House[j+1], House[j+2], &X2, &Y2);
			j += 3;
			if ((X1 >= 0 && X1 < 320 && Y1 >= 0 && Y1 < 200) &&
				(X2 >= 0 && X2 < 320 && Y2 >= 0 && Y2 < 200))
				Draw(X1,Y1,X2,Y2,205);
		}
		j = 0;
		for (i=0; i<IMAGE_SIZE; i++) {
			Map_Coordinates(House[j], House[j+1], House[j+2], &X1, &Y1);
			j += 3;
			Map_Coordinates(House[j], House[j+1], House[j+2], &X2, &Y2);
			j += 3;
			if ((X1 >= 0 && X1 < 320 && Y1 >= 0 && Y1 < 200) &&
				(X2 >= 0 && X2 < 320 && Y2 >= 0 && Y2 < 200))
				Draw(X1,Y1,X2,Y2,0);
		}
	}
	while (!(kbhit()))
		;
	Exit_Graphics();
}

