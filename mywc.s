/*--------------------------------------------------------------------*/
/* mywc.s                                                             */
/* Author: Jingran Zhou                                               */
/*--------------------------------------------------------------------*/

        ### enum {FALSE, TRUE}; 
        .equ FALSE, 0
        .equ TRUE, 1

        .equ EOF, -1
        
### --------------------------------------------------------------------      
        .section ".rodata"

cPrintFormat:
        .string "%7ld %7ld %7ld\n"

### --------------------------------------------------------------------
        .section ".data"
### static long lLineCount = 0;
lLineCount:
        .quad 0
        
### static long lWordCount = 0;
lWordCount:
        .quad 0
        
### static long lCharCount = 0;
lCharCount:
        .quad 0
        
### static int iInWord = FALSE;
iInWord:
        .long FALSE

### --------------------------------------------------------------------
        .section ".bss"
### static int iChar;
iChar:
        .skip 4

### --------------------------------------------------------------------
        .section ".text"

        .globl main
        .type main,@function

        ## -------------------------------------------------------------
        ## Write to stdout counts of how many lines, words, and
        ## characters are in stdin. A word is a sequence of
        ## non-whitespace characters. Whitespace is defined by the
        ## isspace() function. Return 0.
        ## -------------------------------------------------------------
main:
loop1:
        ## if ((iChar = getchar()) == EOF) goto endloop1;
        call getchar
        movl %eax, iChar
        cmpl $EOF, %eax
        je endloop1

        ## lCharCount++;
        incq lCharCount

        ## if (isspace(iChar) == FALSE) goto else1;
        movl iChar, %edi
        call isspace
        cmpl $FALSE, %eax
        je else1

        ## if (iInWord == FALSE) goto endif2;
        cmpl $FALSE, iInWord
        je endif2

        ## lWordCount++;
        incq lWordCount
        ## iInWord = FALSE;
        movl $FALSE, iInWord
endif2:
        jmp endif1
else1:
        ## if (iInWord == 1) goto endif3;
        cmpl $1, iInWord
        je endif3
        movl $TRUE, iInWord
endif3:
endif1:
        ## if (iChar != '\n') goto endif4;
        cmp $'\n', iChar
        jne endif4
        ## lLineCount++;
        incq lLineCount
endif4:
        jmp loop1
endloop1:
        ## if (iInWord == FALSE) goto endif5;
        cmp $FALSE, iInWord
        je endif5
        ## lWordCount++;
        incq lWordCount
endif5:
        ## printf("%7ld %7ld %7ld\n", lLineCount, lWordCount
        ##                                      , lCharCount);
        movq $cPrintFormat, %rdi
        movq lLineCount, %rsi
        movq lWordCount, %rdx
        movq lCharCount, %rcx
        movl $0, %eax
        call printf

        ## return 0;
        movl $0, %eax
        ret
