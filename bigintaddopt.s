/*--------------------------------------------------------------------*/
/* bigintaddopt.s                                                        */
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
        ## Return the larger of lLength1 and lLength2.
        ## static long BigInt_larger(long lLength1, long lLength2)
        ## -------------------------------------------------------------

        ## Local variables:
        .equ LLARGER, %r12      # Callee-saved

        ## Parameters:
        .equ LLENGTH2, %rsi     # Caller-saved
        .equ LLENGTH1, %rdi     # Caller-saved

        .type BigInt_larger,@function

BigInt_larger:
        
        pushq %r12              # Save callee-saved register

        ## long lLarger
        
        ## if (lLength1 <= lLength2) goto else0
        cmpq LLENGTH2, LLENGTH1 
        jle else0

        ## lLarger = lLength1
        movq LLENGTH1, LLARGER

        ## goto endif0
        jmp endif0

else0:
        
        ## lLarger = lLength2
        movq LLENGTH2, LLARGER

endif0:
        ## return lLarger
        movq LLARGER, %rax
        popq %r12               # Restore callee-saved register
        ret

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
        .equ ULCARRY, %r15      # Callee-saved
        

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
        pushq %r15              # Save callee-saved register

        ## unsigned long ulCarry
        ## unsigned long ulSum
        ## long lIndex
        ## long lSumLength

        ## Determine the larger length.
        ## lSumLength = BigInt_larger(oAddend1->lLength,
        ##                            oAddend2->lLength)
        pushq %rdi              # Save caller-saved register
        pushq %rsi              # Save caller-saved register
        pushq %rdx              # Save caller-saved register

        movq LLENGTH(OADDEND1), %rdi
        movq LLENGTH(OADDEND2), %rsi
        call BigInt_larger
        movq %rax, LSUMLENGTH

        popq %rdx               # Restore caller-saved register
        popq %rsi               # Restore caller-saved register
        popq %rdi               # Restore caller-saved register

        ## Clear oSum's array if necessary.
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

        ## Perform the addition.
        ## ulCarry = 0
        movq $0, ULCARRY

        ## lIndex = 0
        movq $0, LINDEX

loop1:
        ## if (lIndex >= lSumLength) goto endloop1;
        cmpq LSUMLENGTH, LINDEX
        jge endloop1

        ## ulSum = ulCarry
        movq ULCARRY, ULSUM

        ## ulCarry = 0
        movq $0, ULCARRY

        ## ulSum += oAddend1->aulDigits[lIndex]
        movq LINDEX, %r10
        addq 8(OADDEND1, %r10, 8), ULSUM

        ## Check for overflow.
        ## if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif2
        cmpq 8(OADDEND1, %r10, 8), ULSUM
        jae endif2

        ## ulCarry = 1
        movq $1, ULCARRY

endif2:
        ## ulSum += oAddend2->aulDigits[lIndex]
        movq LINDEX, %r10
        addq 8(OADDEND2, %r10, 8), ULSUM

        ## Check for overflow.
        ## if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif3
        cmpq 8(OADDEND2, %r10, 8), ULSUM
        jae endif3

        ## ulCarry = 1
        movq $1, ULCARRY

endif3:
        ## oSum->aulDigits[lIndex] = ulSum
        movq LINDEX, %r10
        movq ULSUM, 8(OSUM, %r10, 8)

        ## lIndex++
        incq LINDEX;

        ## goto loop1
        jmp loop1
        
endloop1:

        ## Check for a carry out of the last "column" of the addition.
        ## if (ulCarry != 1) goto endif4
        cmpq $1, ULCARRY
        jne endif4

        ## if (lSumLength != MAX_DIGITS) goto endif5
        cmpq $MAX_DIGITS, LSUMLENGTH
        jne endif5

        ## return FALSE
        movq $FALSE, %rax

        popq %r15               # Restore callee-saved register
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

        popq %r15               # Restore callee-saved register
        popq %r14               # Restore callee-saved register
        popq %r13               # Restore callee-saved register
        popq %r12               # Restore callee-saved register
        
        ret
