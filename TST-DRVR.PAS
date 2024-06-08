{$R+,S+,I+,D+,T-,F-,V+,B-,N-,L+ }
{ M 16384,0,16384 }

{ >>> CHECK STATMENTS FLAGGED WITH !PATH! BEFORE RUNNING! <<< }

uses
  crt, Graph;

const copyright : array[1..66] of char =
'Copyright 1988 by Sam Denton, St. Louis, MO, CompuServ 76314,1512.';

procedure ReservedProc; external;
{$L RESERVED.OBJ }                                                     {!PATH!}

const
  MyPattern : FillPatternType = ($20,$20,$FF,$20,$20,$20,$20,$20);

type BitMap = record
    dx,dy : word;
    pixels : array[1..maxint] of byte;
  end;

var
  GraphDriver, GraphMode : integer;
  i, r : integer;
  x1,y1,x2,y2 : integer;
  XAsp,YAsp : word;
  size : word;
  image : ^ BitMap;

begin
  directvideo := false;
  DetectGraph(GraphDriver,GraphMode);
(**)
  if RegisterBGIdriver(@ReservedProc) < 0 then
      halt(99);
  if GraphResult <> grOk then
    begin
      writeln('not registered');
      halt;
    end
  else
    writeln('Registered!');
  GraphDriver := 6;
  GraphMode := -1;
(**)
  System.FileMode := 0;
  InitGraph(GraphDriver, GraphMode, 'c:\turbo\pascal\');               {!PATH!}
  if GraphResult <> grOk then
    begin
      writeln('error: ',GraphErrorMsg(GraphDriver));
      halt;
    end;

  Size := ImageSize(0,0,7,7);
  GetMem(image, 2*Size);          { just in case }
  FillChar(image^,2*size,1);      { to aid recognition }
  GetImage(0,0,7,7, image^);

  x1 := GetMaxX;
  y1 := GetMaxY;
  for i := 0 to x1 do
    begin
      PutPixel(i,0,32+i mod 144);
      PutPixel(i,y1,32 + i mod 144);
    end;
  for i := 0 to y1 do
    begin
      PutPixel(0,i,32 + i mod 144);
      PutPixel(x1,i,32 + i mod 144);
    end;

  if x1 > y1 then
    r := y1 div 3
  else
    r := x1 div 3;
  x1 := x1 div 2;
  y1 := y1 div 2;
  SetColor(1);
  SetLineStyle(UserBitLn,$E7E7,3);
  for i := 0 to 15 do
    begin
      x2 := trunc(r*sin(i*pi/8));
      y2 := trunc(r*cos(i*pi/8));
      SetColor(i+16);
      Line(x1,y1,x1+x2,y1-y2);
    end;

  SetColor(1);
  Ellipse(x1,y1,0,360,r,r);

  SetColor(2);
  SetFillPattern(MyPattern,1);                  {should be BLUE cross-hatches}
  Bar(66,66,2,2);

  SetColor(3);
  SetLineStyle(SolidLn,0,1);
  SetFillStyle(InterleaveFill,1);
  for i := 0 to 3 do
    PieSlice(x1,y1,90*i,90*i+90,r div 2);       {...doesn't work yet...}

  SetColor(4);
  SetTextJustify(RightText,CenterText);
  SetTextStyle(DefaultFont,HorizDir,1);
  OutTextXY(GetMaxX-2,y1,'Default Font');

  SetColor(5);
  SetTextJustify(LeftText,CenterText);
  SetTextStyle(SmallFont,HorizDir,4);
  i := GraphResult;
  if i = 0 then
    OutTextXY(2,y1,'Stroked Font')
  else
    OutTextXY(2,y1,GraphErrorMsg(i));

  Delay(2500);
  GetAspectRatio(XAsp,Yasp);
  CloseGraph;

  writeln('Aspect ration = ',XAsp,':',YAsp);
  writeln('Size of an 8x8 region = ',size);
  writeln('Following should be "7,7", then 64 zeros, then ones.');
  writeln(image^.dx,',',image^.dy);
  for i := 1 to size-3 do
    write(image^.pixels[i]:4);
  writeln;
end.