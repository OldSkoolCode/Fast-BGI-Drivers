echo off
if not exist %1.asm goto :error
masm %1;
if errorlevel 1 goto :error
link %1;
if errorlevel 1 goto :error
echo If a fix-up value is requested, enter 0 (zero).
exe2bin %1
if errorlevel 1 goto :error
cls
echo You will now be placed into DEBUG. Use the "D" command to examine the file.
echo Use the "R" command to get the size of the file from the CX register. Use the
echo "E" command to change the two occurances of "FF FF" into the offset of the
echo beginning of the code and the size of the code. Remember that DEBUG loads at
echo 0100, so adjust the offset accordingly. The size of the code should be the
echo value in the CX register less the true value of the offset. Remember that
echo when entering a word as two bytes, the low order byte is entered first; i.e.
echo the value "1234" is entered as "34 12". An example follows.
pause
echo -d
echo 3504:0100  70 6B 08 08 54 68 69 73-20 69 73 20 61 20 73 69   pk..This is a si
echo 3504:0110  6D 70 6C 65 20 74 65 73-74 20 2E 42 47 49 20 66   mple test .BGI f
echo 3504:0120  69 6C 65 1A FF FF 02 00-FF FF 01 00 01 00 00 00   ile.............
echo 3504:0130  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
echo 3504:0140  FC 55 1E 0E 1F FF 94 16-00 1F 5D CB 00 00 00 00   .U........].....
echo 3504:0150  C3 90 90 90 90 C3 85 00-9B 00 A1 00 15 00 A7 00   ................
echo 3504:0160  AF 00 BB 00 10 00 10 00-10 00 10 00 10 00 15 00   ................
echo 3504:0170  BC 00 BD 00 BE 00 10 00-BF 00 10 00 10 00 10 00   ................
echo -r
echo AX=0000  BX=0000  CX=0144  DX=0000  SP=FFEE  BP=0000  SI=0000  DI=0000
echo DS=3504  ES=3504  SS=3504  CS=3504  IP=0100   NV UP EI PL NZ NA PO NC
echo 3504:0100 706B          JO      016D
echo -e 124 40 00
echo -e 128 04 01
echo -w
echo Writing 0144 bytes
echo -q
pause
debug %1.bin
c:\turbo\pascal\binobj %1.bin %1.obj %1proc
if errorlevel 1 goto :error
goto :exit
:error
echo Halting due to errors!
:exit
