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
   str x19, [sp, 8] // LLENGTH1
   str x20, [sp, 16] // LLENGTH2
   str x21, [sp, 24] // LLARGER
   mov x19, x0
   mov x20, x1

   // long lLarger

   // if (lLength1 <= lLength2) goto else1;
   cmp x19, x20
   ble else1

   // lLarger = lLength1;
   mov x21, x19

   // goto endif6;
   b endif6

else1:
   // lLarger = lLength2;
   mov x21, x20

endif6:
   // return lLarger;
   mov x0, x21
   ldr x19, [sp, 8]
   ldr x20, [sp, 16]
   ldr x21, [sp, 24]
   ldr x30, [sp]
   add sp, sp, LARGER_STACK_BYTECOUNT
   ret

   .size   BigInt_larger, (. - BigInt_larger)

   .global BigInt_add
BigInt_add:
   // Prolog
   sub sp, sp, ADD_STACK_BYTECOUNT
   str x30, [sp]
   str x19, [sp, 8] // ULCARRY
   str x20, [sp, 16] // ULSUM
   str x21, [sp, 24] // LINDEX
   str x22, [sp, 32] // LSUMLENGTH
   str x23, [sp, 40] // OADDEND1
   str x24, [sp, 48] // OADDEND2
   str x25, [sp, 56] // OSUM

   mov x23, x0
   mov x24, x1
   mov x25, x2

   // unsigned long ulCarry;
   // unsigned long ulSum;
   // long lIndex;
   // long lSumLength; 

   /* Determine the larger length. */
   // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
   ldr x0, [x23]
   ldr x1, [x24]
   bl BigInt_larger
   mov x22, x0

   /* Clear oSum's array if necessary. */
   // if (oSum->lLength <= lSumLength) goto endif1;
   ldr x0, [x25]
   cmp x0, x22
   ble endif1
   // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));

   // first thing
   mov x0, x25
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
   mov x19, 0
   // lIndex = 0
   mov x21, 0

   startfor1:
   // if (lIndex >= lSumLength) goto endfor1;
   cmp x21, x22
   bge endfor1

   // ulSum = ulCarry;
   mov x20, x19
   // ulCarry = 0
   mov x19, 0

   // ulSum += oAddend1->aulDigits[lIndex];
   mov x0, x23
   mov x7, AULDIGIT
   add x0, x0, x7
   ldr x2, [x0, x21, lsl 3]

   // adding to ulSum
   add x20, x20, x2

   /* Check for overflow. */
   // if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif2;
   mov x0, x23
   mov x7, AULDIGIT
   add x0, x0, x7
   ldr x1, [x0, x21, lsl 3]
   cmp x20, x1
   bhs endif2

   // ulCarry = 1;
   mov x19, 1
   
endif2:

   // ulSum += oAddend2->aulDigits[lIndex];
   mov x0, x24
   mov x7, AULDIGIT
   add x0, x0, x7
   ldr x2, [x0, x21, lsl 3]

   // adding to ulSum
   add x20, x20, x2

    // if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif3; /* Check for overflow. */
   mov x0, x24
   mov x7, AULDIGIT
   add x0, x0, x7
   ldr x1, [x0, x21, lsl 3]
   cmp x20, x1
   bhs endif3

   // ulCarry = 1
   mov x19, 1

endif3:
   // oSum->aulDigits[lIndex] = ulSum;
   mov x0, x25
   mov x7, AULDIGIT
   add x0, x0, x7
   str x20, [x0, x21, lsl 3]

   // lIndex++;
   add x21, x21, 1

   // goto startfor1;
   b startfor1
   
endfor1:

    // if (ulCarry != 1) goto endif4;
   cmp x19, 1
   bne endif4

   // if (lSumLength != MAX_DIGITS) goto endif5;
   mov x1, MAX_DIGITS
   cmp x22, x1
   bne endif5

   // epilog, return FALSE;
   mov x0, FALSE
   ldr x30, [sp]
   ldr x19, [sp, 8] // ULCARRY
   ldr x20, [sp, 16] // ULSUM
   ldr x21, [sp, 24] // LINDEX
   ldr x22, [sp, 32] // LSUMLENGTH
   ldr x23, [sp, 40] // OADDEND1
   ldr x24, [sp, 48] // OADDEND2
   ldr x25, [sp, 56] // OSUM
   add sp, sp, ADD_STACK_BYTECOUNT
   ret 
   .size   BigInt_add, (. - BigInt_add)

endif5:
   // oSum->aulDigits[lSumLength] = 1;
   mov x0, x25
   mov x7, AULDIGIT
   add x0, x0, x7
   mov x2, 1
   str x2, [x0, x22, lsl 3]

   // lSumLength++;
   add x22, x22, 1

endif4:
   // oSum->lLength = lSumLength;
   str x22, [x25]

   // epilog, return TRUE;
   mov x0, TRUE
   ldr x30, [sp]
   ldr x19, [sp, 8] // ULCARRY
   ldr x20, [sp, 16] // ULSUM
   ldr x21, [sp, 24] // LINDEX
   ldr x22, [sp, 32] // LSUMLENGTH
   ldr x23, [sp, 40] // OADDEND1
   ldr x24, [sp, 48] // OADDEND2
   ldr x25, [sp, 56] // OSUM
   add sp, sp, ADD_STACK_BYTECOUNT
   ret
   .size   BigInt_add, (. - BigInt_add)
