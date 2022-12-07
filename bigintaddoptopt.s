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

   ULSUM .req x4
   LINDEX .req x5
   LSUMLENGTH .req x6
   OADDEND1 .req x7
   OADDEND2 .req x8
   OSUM .req x9

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
   mov x2, MAX_DIGITS
   lsl x2, x2, 3

   bl memset

endif1:

   /* Perform the addition. */
   // lIndex = 0
   mov LINDEX, 0

   // if (lIndex >= lSumLength) goto endfor1;
   cbz LSUMLENGTH, endif4

   // set c flag to zero
   adcs x0, LINDEX, LINDEX

startfor1:

   // find oAddend1->aulDigits[lIndex];
   add x0, OADDEND1, AULDIGIT
   ldr x1, [x0, LINDEX, lsl 3]

   // find oAddend2->aulDigits[lIndex];
   add x0, OADDEND2, AULDIGIT
   ldr x2, [x0, LINDEX, lsl 3]

   // adding to ulSum
   adcs ULSUM, x1, x2

   // oSum->aulDigits[lIndex] = ulSum;
   add x0, OSUM, AULDIGIT
   str ULSUM, [x0, LINDEX, lsl 3]

   // lIndex++;
   add LINDEX, LINDEX, 1

   // if (lIndex < lSumLength) goto startfor1
   sub x0, LINDEX, LSUMLENGTH
   cbnz x0, startfor1

endfor1:
   bcc endif4

   // if (lSumLength != MAX_DIGITS) goto endif5;
   mov x1, MAX_DIGITS
   cmp LSUMLENGTH, x1
   bne endif5

   // epilog, return FALSE;
   mov x0, FALSE
   ldr x30, [sp]
   add sp, sp, ADD_STACK_BYTECOUNT
   ret 
   .size   BigInt_add, (. - BigInt_add)

endif5:
   // oSum->aulDigits[lSumLength] = 1;
   add x0, OSUM, AULDIGIT
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
   add sp, sp, ADD_STACK_BYTECOUNT
   ret
   .size   BigInt_add, (. - BigInt_add)
