/*
* Print routines file for COMS35102 labs
* (c) Simon Hollis (simon@cs.bris.ac.uk)
* December 2012
*/

#include <stdio.h>
#include <stm32f4xx.h> // for ITM_SendChar


/*
* Re-implement fputc() to go over the debug interface
* Will then appear in the debug (printf) window of the debugger
* and printf() will work too.
*/

int fputc(int c, FILE *f)
{
   return(ITM_SendChar(c));
}


// Low level debug port function for ST M Series processors
#define ITM_Port8(n) (*((volatile unsigned char *)(0xE0000000+4*n)))
void ITM_Write(int value)
{
	ITM_Port8(0) = value + 0x30; /* displays value in ASCII */
	while (ITM_Port8(0) == 0);
	ITM_Port8(0) = 0x0D;
	while (ITM_Port8(0) == 0);
	ITM_Port8(0) = 0x0A;
}

// now some simple print helper functions
void PrintHello()
{
	printf("Hello World!\n") ;
}

void PrintString(char *string)
{
	printf(string) ;
	printf("\n") ;}

void PrintChar(char character)
{
	char string[3] ; 
	char *p = &string[0] ;
	string[0] = character ;
	string[1] = '\n' ;
	string[2] = '\0' ;
	printf(p) ;
}

void PrintHex(unsigned value)
{
	printf("%x\n", value);
}

void PrintDec(unsigned value)
{
	printf("%d\n", value);
}
