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


   // bl BigInt_larger

   // if (lLength1 <= lLength2) goto else1;
   cmp x0, x1
   ble else1

   // lLarger = lLength1;
   mov LSUMLENGTH, x0

   // goto endif6;
   b endif6

else1:
   // lLarger = lLength2;
   mov LSUMLENGTH, x1

endif6:

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

   // if (lIndex >= lSumLength) goto endfor1;
   cmp LINDEX, LSUMLENGTH
   bge endfor1

   // clear c flag
   mov x0, 0
   adcs x0, x0, x0

startfor1:

   // ulSum = 0
   mov ULSUM, 0

   // ulSum += oAddend1->aulDigits[lIndex];
   mov x0, OADDEND1
   mov x7, AULDIGIT
   add x0, x0, x7
   ldr x1, [x0, LINDEX, lsl 3]

   // ulSum += oAddend2->aulDigits[lIndex];
   mov x0, OADDEND2
   mov x7, AULDIGIT
   add x0, x0, x7
   ldr x2, [x0, LINDEX, lsl 3]

   // adding to ulSum
   adcs ULSUM, x1, x2

   // oSum->aulDigits[lIndex] = ulSum;
   mov x0, OSUM
   mov x7, AULDIGIT
   add x0, x0, x7
   str ULSUM, [x0, LINDEX, lsl 3]

   // lIndex++;
   add LINDEX, LINDEX, 1

   // if (lIndex < lSumLength) goto endfor1;
   cmp LINDEX, LSUMLENGTH
   blt startfor1

endfor1:
   bhs endif4

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
