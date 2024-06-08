
/*
    BH - writes header portion of BGI driver

    Copyright (c) 1988,89 Borland International
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define VERSION 	3		/* Version Number of header	*/
#define REVISION	0		/* Revision number of header	*/
#define MIN_VERSION	1		/* Minimum Version Number	*/
#define MIN_REVISION	1		/* Minimum Revision Number	*/
#define HEADER_SIZE	160		/* Size (in bytes) of header	*/

FILE	*Ifile, *Ofile = stdout;

char mask[] = "pk\010\010BGI Device Driver (%s) %d.%02d - " __DATE__ "\r\n"
	      "Copyright (c) 1993 Futurescape Productions\r\n";

char help[] = "BGI Driver Builder Copyright (c) 1987,1989 Borland International, Inc.\n\n"
              "Usage is:  BH [input.BIN] [output.BGI] [drv_name]\n\n"
	      "    input.BIN is the DRIVER.BIN from EXE2BIN.\n"
	      "    output.BGI is the DRIVER.BGI file name.\n"
	      "    drv_name is the device name in ASCII (i.e. EGA or CGA)\n";

int	drv_num = 0;

void main( argc, argv )
int argc;
char *argv[];
{
  long int size, offset;
  int i, j;
  char name[80], *cptr;

  argv++;	argc--; 		/* Skip over program name	*/

  if( argc != 3 && argc != 4 ){ 	/* Must have input and output	*/
    fprintf( stderr, help );		/* Give user a help message	*/
    exit( 1 );				/* Leave the program		*/
    }

  strcpy( name, *argv++ );		/* Get input file name		*/
  cptr = strchr( name, '.' );           /* Is ther an extention?        */
  if( cptr ) *cptr = '\0';              /* Cut extent if give           */
  strcat( name, ".BIN" );               /* Add input file extention     */

  Ifile = fopen( name, "rb" );          /* Open input file              */
  if( NULL == Ifile ){			/* Did the open suceed? 	*/
    fprintf( stderr, "ERROR: Could not open input file %s.\n", *(argv-1) );
    exit( 2 );				/* Leave the program		*/
    }

  strcpy( name, *argv++ );		/* Get input file name		*/
  cptr = strchr( name, '.' );           /* Is ther an extention?        */
  if( cptr ) *cptr = '\0';              /* Cut extent if give           */
  strcat( name, ".BGI" );               /* Add input file extention     */

  Ofile = fopen( name, "wb" );          /* Open output file             */
  if( NULL == Ofile ){			/* Did the open suceed? 	*/
    fprintf( stderr, "ERROR: Could not open output file %s.\n", *(argv-1) );
    exit( 3 );				/* Leave the program		*/
    }

  strcpy( name, *argv++ );		/* Get driver name from line	*/
  strupr( name );			/* Convert name to uppercase	*/

/*	The driver number is not needed for version 2 drivers, but is	*/
/*	allowed for version 1 compatability.				*/

  if( argc == 4 )			/* Is driver number is present? */
    drv_num = atoi( *argv++ );		/* convert driver number to bin */

  fseek( Ifile, 0L, SEEK_END ); 	/* Goto the end of the file	*/
  size = ftell( Ifile );		/* Read the length of the file	*/
  fseek( Ifile, 0L, SEEK_SET ); 	/* Goto the beginning of file	*/

  fprintf( Ofile, mask, name, VERSION, REVISION );
  putc( 0x00, Ofile );			/* Null terminate string in file*/
  putc( 0x1a, Ofile );			/* Control Z terminate file	*/

  putw( HEADER_SIZE, Ofile );		/* Write out the size of header */
  putw( drv_num, Ofile );		/* Write out the driver number	*/
  putw( (int) size, Ofile );		/* Size (in bytes) of driver	*/

  putc( VERSION, Ofile );		/* Write the version number	*/
  putc( REVISION, Ofile );		/* Write the revision number	*/

  putc( MIN_VERSION, Ofile );		/* Write the version number	*/
  putc( MIN_REVISION, Ofile );		/* Write the revision number	*/

  offset = ftell( Ofile );		/* Find location in output file */
  for( i=(int)offset ; i<0x80 ; ++i ) putc( 0x00, Ofile );

  putw( HEADER_SIZE, Ofile );		/* Write out the size of header */
  putw( drv_num, Ofile );		/* Write out the driver number	*/
  putw( (int) size, Ofile );		/* Size (in bytes) of driver	*/

  putc( VERSION, Ofile );		/* Write the version number	*/
  putc( REVISION, Ofile );		/* Write the revision number	*/

  putc( MIN_VERSION, Ofile );		/* Write the version number	*/
  putc( MIN_REVISION, Ofile );		/* Write the revision number	*/

  name[8] = '\0';                       /* Cut name to 8 characters     */
  j = strlen( name );			/* Get device driver int name	*/
  putc( j, Ofile );			/* Make string pascal format	*/
  for( i=0 ; i<j ; ++i ) putc( name[i], Ofile );

  size = ftell( Ofile );		/* How big is header so far	*/
  i = HEADER_SIZE - (int) size; 	/* Determine # of pad bytes	*/

  for( j=0 ; j<i ; ++j )		/* Pad header with zeros	*/
		putc( 0, Ofile );

  i = getc( Ifile );			/* Read source byte		*/
  while( !feof(Ifile) ){		/* Copy the input to output	*/
    putc( i, Ofile );			/* Write destination byte	*/
    i = getc( Ifile );			/* Read source byte		*/
    }

  fclose( Ifile );			/* Close file streams		*/
  fclose( Ofile );

}

