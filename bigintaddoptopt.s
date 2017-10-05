/*--------------------------------------------------------------------*/
/* bigintaddoptopt.s                                                  */
/* Author: Jingran Zhou                                               */
/*--------------------------------------------------------------------*/

        .equ FALSE, 0
        .equ TRUE, 1

        .equ MAX_DIGITS, 32768

        .equ LLENGTH, 0
        
### --------------------------------------------------------------------
        .section ".rodata"
### --------------------------------------------------------------------
        .section ".data"
### --------------------------------------------------------------------
        .section ".bss"
### --------------------------------------------------------------------
        .section ".text"

        ## -------------------------------------------------------------
        ## Assign the sum of oAddend1 and oAddend2 to oSum. oSum should
        ## be distinct from oAddend1 and oAddend2. Return 0 (FALSE) if
        ## an overflow occured, and 1 (TRUE) otherwise.
        ## int BigInt_add(BigInt_T oAddend1, BigInt_T oAddend2,
        ##                BigInt_T oSum)
        ## -------------------------------------------------------------

        ## Local vairables:
        .equ LSUMLENGTH, %r12   # Callee-saved
        .equ LINDEX, %r13       # Callee-saved
        .equ ULSUM, %r14        # Callee-saved
        
        ## Parameters:
        .equ OSUM, %rdx         # Caller-saved
        .equ OADDEND2, %rsi     # Caller-saved
        .equ OADDEND1, %rdi     # Caller-saved

        .globl BigInt_add
        .type BigInt_add,@function

BigInt_add:
        
        pushq %r12              # Save callee-saved register
        pushq %r13              # Save callee-saved register 
        pushq %r14              # Save callee-saved register
        
        ## unsigned long ulSum
        ## long lIndex
        ## long lSumLength

        ## Determine the larger length.
        ## if (oAddend1->lLength <= oAddend2->lLength) goto else0
        movq LLENGTH(OADDEND2), %rax
        cmpq %rax, LLENGTH(OADDEND1)
        jle else0
        
        ## lSumLength = oAddend1->lLength
        movq LLENGTH(OADDEND1), LSUMLENGTH
        
        ## goto endif0
        jmp endif0
        
else0:
        
        ## lSumLength = oAddend2->lLength
        movq LLENGTH(OADDEND2), LSUMLENGTH
        
endif0:

        ## Clean oSum's array if necessary.
        ## if (oSum->lLength <= lSumLength) goto endif1
        cmpq LSUMLENGTH, LLENGTH(OSUM)
        jle endif1

        ## memset(oSum->aulDigits, 0, MAX_DIGITS*sizeof(unsigned long))
        pushq %rdi              # Save caller-saved register
        pushq %rsi              # Save caller-saved register
        pushq %rdx              # Save caller-saved register

        movq OSUM, %rdi
        addq $8, %rdi
        movq $0, %rsi
        movq $MAX_DIGITS, %r10
        imulq $8, %r10
        movq %r10, %rdx
        call memset

        popq %rdx               # Restore caller-saved register
        popq %rsi               # Restore caller-saved register
        popq %rdi               # Restore caller-saved register

endif1:

        
### --------------------------------------------------------------------

        ## Perform the addition
        
        ## ulCarry = 0
        clc
        lahf
        
        ## lIndex = 0
        movq $0, LINDEX
        
        ## goto test
        jmp test
        
loop:

        ## ulSum = 0
        movq $0, ULSUM

        ## ulSum += oAddend1->aulDigits[lIndex] (+ carry)
        movq LINDEX, %r10
        addq 8(OADDEND1, %r10, 8), ULSUM
        
        ## ulSum += oAddend2->aulDigits[lIndex] (+ carry)
        movq LINDEX, %r10
        sahf
        adcq 8(OADDEND2, %r10, 8), ULSUM
        lahf
        
        ## oSum->aulDigits[lIndex] = ulSum
        movq LINDEX, %r10
        movq ULSUM, 8(OSUM, %r10, 8)

        ## lIndex++
        incq LINDEX
        
test:
        
        ## if (lIndex < lSumLength) goto loop
        cmpq LSUMLENGTH, LINDEX
        jl loop
        
### --------------------------------------------------------------------

        ## Check for a carry out of the last "column" of the addition.
        ## if (carry != 1) goto endif4
        sahf
        jnc endif4
        
        ## if (lSumLength != MAX_DIGITS) goto endif5
        cmpq $MAX_DIGITS, LSUMLENGTH
        jne endif5

        ## return FALSE
        movq $FALSE, %rax

        popq %r14               # Restore callee-saved register
        popq %r13               # Restore callee-saved register
        popq %r12               # Restore callee-saved register
        
        ret

endif5:

        ## oSum->aulDigits[lSumLength] = 1;
        movq LSUMLENGTH, %r10
        movq $1, 8(OSUM, %r10, 8)

        ## lSumLength++
        incq LSUMLENGTH

endif4:

        ## Set the length of the sum.

        ## oSum->lLength = lSumLength
        movq LSUMLENGTH, LLENGTH(OSUM)
        
        ## return TRUE
        movq $TRUE, %rax

        popq %r14               # Restore callee-saved register
        popq %r13               # Restore callee-saved register
        popq %r12               # Restore callee-saved register
        
        ret
