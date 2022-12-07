   .section .rodata
   
   .section .data

   .section .bss

   .section .text

   // enum {MAX_DIGITS = 32768}; 
   .equ MAX_DIGITS, 32768

   // enum {FALSE, TRUE};
   .equ FALSE, 0
   .equ TRUE, 1

   // Must be a multiple of 16
   .equ LARGER_STACK_BYTECOUNT, 32
   .equ ADD_STACK_BYTECOUNT, 64
      
   // Local variable stack offsets:
   .equ LLARGER, 8

   // Parameter stack offsets:
   .equ LLENGTH1, 16
   .equ LLENGTH2, 24


   // Local variable stack offsets for BigInt_add:
   .equ ULCARRY, 8
   .equ ULSUM, 16
   .equ LINDEX, 24
   .equ LSUMLENGTH, 32 

   // Parameter stack offsets for BigInt_add:
   .equ OADDEND1, 40
   .equ OADDEND2, 48
   .equ OSUM, 56

   // BigInt_T offsets
   .equ LLENGTH, 0
   .equ AULDIGIT, 8

BigInt_larger:

   // Prolog
   sub sp, sp, LARGER_STACK_BYTECOUNT
   str x30, [sp]

   LLENGTH1 .req x19
   LLENGTH2 .req x20
   LLARGER .req x21

   str LLENGTH1, [sp, 8] // LLENGTH1
   str LLENGTH2, [sp, 16] // LLENGTH2
   str LLARGER, [sp, 24] // LLARGER
   
   mov LLENGTH1, x0
   mov LLENGTH2, x1

   // long lLarger

   // if (lLength1 <= lLength2) goto else1;
   cmp LLENGTH1, LLENGTH2
   ble else1

   // lLarger = lLength1;
   mov LLARGER, LLENGTH1

   // goto endif6;
   b endif6

else1:
   // lLarger = lLength2;
   mov LLARGER, LLENGTH2

endif6:
   // return lLarger;
   mov x0, LLARGER
   ldr LLENGTH1, [sp, 8]
   ldr LLENGTH2, [sp, 16]
   ldr LLARGER, [sp, 24]
   ldr x30, [sp]
   add sp, sp, LARGER_STACK_BYTECOUNT
   ret

   .size   BigInt_larger, (. - BigInt_larger)

   .global BigInt_add
BigInt_add:
   // Prolog
   sub sp, sp, ADD_STACK_BYTECOUNT
   str x30, [sp]

   ULCARRY .req x19
   ULSUM .req x20
   LINDEX .req x21
   LSUMLENGTH .req x22
   OADDEND1 .req x23
   OADDEND2 .req x24
   OSUM .req x25

   str ULCARRY, [sp, 8] // ULCARRY
   str ULSUM, [sp, 16] // ULSUM
   str LINDEX, [sp, 24] // LINDEX
   str LSUMLENGTH, [sp, 32] // LSUMLENGTH
   str OADDEND1, [sp, 40] // OADDEND1
   str OADDEND2, [sp, 48] // OADDEND2
   str OSUM, [sp, 56] // OSUM

   mov OADDEND1, x0
   mov OADDEND2, x1
   mov OSUM, x2

   // unsigned long ulCarry;
   // unsigned long ulSum;
   // long lIndex;
   // long lSumLength; 

   /* Determine the larger length. */
   // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
   ldr x0, [OADDEND1]
   ldr x1, [OADDEND2]
   bl BigInt_larger
   mov LSUMLENGTH, x0

   /* Clear oSum's array if necessary. */
   // if (oSum->lLength <= lSumLength) goto endif1;
   ldr x0, [OSUM]
   cmp x0, LSUMLENGTH
   ble endif1
   // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));

   // first thing
   mov x0, OSUM
   add x0, x0, AULDIGIT

   // second thing
   mov w1, 0

   // third thing
   mov x2, 8
   mov x3, MAX_DIGITS
   mul x2, x2, x3

   bl memset
endif1:

   /* Perform the addition. */
   // ulCarry = 0
   mov ULCARRY, 0
   // lIndex = 0
   mov LINDEX, 0

   startfor1:
   // if (lIndex >= lSumLength) goto endfor1;
   cmp LINDEX, LSUMLENGTH
   bge endfor1

   // ulSum = ulCarry;
   mov ULSUM, ULCARRY
   // ulCarry = 0
   mov ULCARRY, 0

   // ulSum += oAddend1->aulDigits[lIndex];
   mov x0, OADDEND1
   mov x7, AULDIGIT
   add x0, x0, x7
   ldr x2, [x0, LINDEX, lsl 3]

   // adding to ulSum
   add ULSUM, ULSUM, x2

   /* Check for overflow. */
   // if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif2;
   mov x0, OADDEND1
   mov x7, AULDIGIT
   add x0, x0, x7
   ldr x1, [x0, LINDEX, lsl 3]
   cmp ULSUM, x1
   bhs endif2

   // ulCarry = 1;
   mov ULCARRY, 1
   
endif2:

   // ulSum += oAddend2->aulDigits[lIndex];
   mov x0, OADDEND2
   mov x7, AULDIGIT
   add x0, x0, x7
   ldr x2, [x0, LINDEX, lsl 3]

   // adding to ulSum
   add ULSUM, ULSUM, x2

    // if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif3; /* Check for overflow. */
   mov x0, OADDEND2
   mov x7, AULDIGIT
   add x0, x0, x7
   ldr x1, [x0, LINDEX, lsl 3]
   cmp ULSUM, x1
   bhs endif3

   // ulCarry = 1
   mov ULCARRY, 1

endif3:
   // oSum->aulDigits[lIndex] = ulSum;
   mov x0, OSUM
   mov x7, AULDIGIT
   add x0, x0, x7
   str ULSUM, [x0, LINDEX, lsl 3]

   // lIndex++;
   add LINDEX, LINDEX, 1

   // goto startfor1;
   b startfor1
   
endfor1:

    // if (ulCarry != 1) goto endif4;
   cmp ULCARRY, 1
   bne endif4

   // if (lSumLength != MAX_DIGITS) goto endif5;
   mov x1, MAX_DIGITS
   cmp LSUMLENGTH, x1
   bne endif5

   // epilog, return FALSE;
   mov x0, FALSE
   ldr x30, [sp]
   ldr ULCARRY, [sp, 8] // ULCARRY
   ldr ULSUM, [sp, 16] // ULSUM
   ldr LINDEX, [sp, 24] // LINDEX
   ldr LSUMLENGTH, [sp, 32] // LSUMLENGTH
   ldr OADDEND1, [sp, 40] // OADDEND1
   ldr OADDEND2, [sp, 48] // OADDEND2
   ldr OSUM, [sp, 56] // OSUM
   add sp, sp, ADD_STACK_BYTECOUNT
   ret 
   .size   BigInt_add, (. - BigInt_add)

endif5:
   // oSum->aulDigits[lSumLength] = 1;
   mov x0, OSUM
   mov x7, AULDIGIT
   add x0, x0, x7
   mov x2, 1
   str x2, [x0, LSUMLENGTH, lsl 3]

   // lSumLength++;
   add LSUMLENGTH, LSUMLENGTH, 1

endif4:
   // oSum->lLength = lSumLength;
   str LSUMLENGTH, [OSUM]

   // epilog, return TRUE;
   mov x0, TRUE
   ldr x30, [sp]
   ldr ULCARRY, [sp, 8] // ULCARRY
   ldr ULSUM, [sp, 16] // ULSUM
   ldr LINDEX, [sp, 24] // LINDEX
   ldr LSUMLENGTH, [sp, 32] // LSUMLENGTH
   ldr OADDEND1, [sp, 40] // OADDEND1
   ldr OADDEND2, [sp, 48] // OADDEND2
   ldr OSUM, [sp, 56] // OSUM
   add sp, sp, ADD_STACK_BYTECOUNT
   ret
   .size   BigInt_add, (. - BigInt_add)
