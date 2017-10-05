/*--------------------------------------------------------------------*/
/* mywc.c                                                             */
/* Author: Bob Dondero                                                */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>

/*--------------------------------------------------------------------*/

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

/*--------------------------------------------------------------------*/

static long lLineCount = 0;      /* Bad style. */
static long lWordCount = 0;      /* Bad style. */
static long lCharCount = 0;      /* Bad style. */
static int iChar;                /* Bad style. */
static int iInWord = FALSE;      /* Bad style. */

/*--------------------------------------------------------------------*/

/* Write to stdout counts of how many lines, words, and characters
   are in stdin. A word is a sequence of non-whitespace characters.
   Whitespace is defined by the isspace() function. Return 0. */

int main(void)
{
   
  loop1:
   if((iChar = getchar()) == EOF) goto endloop1;
   
   lCharCount++;
   
   if (isspace(iChar) == FALSE) goto else1;
   
   if (iInWord == FALSE) goto endif2;
   lWordCount++;
   iInWord = FALSE;
  endif2:
   
   goto endif1;
  else1:
   
   if (iInWord == 1) goto endif3;
   iInWord = TRUE;
  endif3:
   
  endif1:
   
   if (iChar != '\n') goto endif4;
   lLineCount++;
  endif4:
   
   goto loop1;
  endloop1:
   
   if (iInWord == FALSE) goto endif5;
   lWordCount++;
  endif5:
   
   printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
   return 0;
}
