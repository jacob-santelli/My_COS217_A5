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
   str x0, [sp, LLENGTH1]
   str x1, [sp, LLENGTH2]

   // long lLarger

   // if (lLength1 <= lLength2) goto else1;
   ldr x0, [sp, LLENGTH1]
   ldr x1, [sp, LLENGTH2]
   cmp x0, x1
   ble else1

   // lLarger = lLength1;
   str x0, [sp, LLARGER]

   // goto endif6;
   b endif6

   else1:
   // lLarger = lLength2;
   str x1, [sp, LLARGER]

   endif6:
   // return lLarger;
   ldr     x0, [sp, LLARGER]
   ldr     x30, [sp]
   add     sp, sp, LARGER_STACK_BYTECOUNT
   ret

   .size   BigInt_larger, (. - BigInt_larger)

.global BigInt_add
BigInt_add:
   // Prolog
   sub sp, sp, ADD_STACK_BYTECOUNT
   str x30, [sp]
   str x0, [sp, OADDEND1]
   str x1, [sp, OADDEND2]
   str x2, [sp, OSUM] 

   // unsigned long ulCarry;
   // unsigned long ulSum;
   // long lIndex;
   // long lSumLength; 

   /* Determine the larger length. */
   // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
   ldr x0, [sp, OADDEND1]
   ldr x0, [x0, LLENGTH]
   ldr x1, [sp, OADDEND2]
   ldr x1, [x1, LLENGTH]
        bl BigInt_larger
        ldr x1, [sp, LSUMLENGTH]
        str x0, [x1]

   /* Clear oSum's array if necessary. */
   // if (oSum->lLength <= lSumLength) goto endif1;
   ldr x0, [sp, OSUM]
   ldr x0, [x0, LLENGTH]
   ldr x1, [sp, LSUMLENGTH]
   cmp x0, x1
   ble endif1
      // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));

      // third thing

      // ldr x0, [sp, ULCARRY]
      // bl sizeof
      // mov x1, MAX_DIGITS
      // mul x0, x0, x1
      // mov x3, x0

      // first thing
      ldr x0, [sp, OSUM]
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
   mov x0, 0
   str x0, [sp, ULCARRY]
   // lIndex = 0
   mov x0, 0
   str x0, [sp, LINDEX]

   startfor1:
   // if (lIndex >= lSumLength) goto endfor1;
   ldr x0, [sp, LINDEX]
   ldr x1, [sp, LSUMLENGTH]
   cmp x0, x1
   bge endfor1

      // ulSum = ulCarry;
      ldr x0, [sp, ULCARRY]
      str x0, [sp, ULSUM]
      // ulCarry = 0
      mov x0, 0
      str x0, [sp, ULCARRY]

      // ulSum += oAddend1->aulDigits[lIndex];
      ldr x0, [sp, OADDEND1]
      ldr x1, [sp, LINDEX]
      mov x7, AULDIGIT
      add x0, x0, x7
      ldr x2, [x0, x1, lsl 3]

      // adding to ulSum
      ldr x1, [sp, ULSUM]
      add x1, x1, x2
      str x1, [sp, ULSUM]
      
      /* Check for overflow. */
      // if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif2;
      ldr x0, [sp, ULSUM]
      ldr x1, [sp, OADDEND1]
      ldr x2, [sp, LINDEX]
      mov x7, AULDIGIT
      add x1, x1, x7
      ldr x3, [x1, x2, lsl 3]
      cmp x0, x3
      bge endif2

         // ulCarry = 1;
         mov x0, 1
         str x0, [sp, ULCARRY]
      
      endif2:

      // ulSum += oAddend2->aulDigits[lIndex];
      ldr x0, [sp, OADDEND2]
      ldr x1, [sp, LINDEX]
      mov x7, AULDIGIT
      add x0, x0, x7
      ldr x2, [x0, x1, lsl 3]

      // adding to ulSum
      ldr x1, [sp, ULSUM]
      add x1, x1, x2
      str x1, [sp, ULSUM]

    // if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif3; /* Check for overflow. */
   ldr x0, [sp, ULSUM]
   ldr x1, [sp, OADDEND2]
   ldr x2, [sp, LINDEX]
   mov x7, AULDIGIT
   add x1, x1, x7
   ldr x3, [x1, x2, lsl 3]
   cmp x0, x3
   // bge might be wrong bcond
   bge endif3

   // ulCarry = 1
   mov x1, 1
   str x1, [sp, ULCARRY]

endif3:
   // oSum->aulDigits[lIndex] = ulSum;
   ldr x0, [sp, OSUM]
   ldr x1, [sp, LINDEX]
   mov x7, AULDIGIT
   add x0, x0, x7
   ldr x2, [sp, ULSUM]
   str x2, [x0, x1, lsl 3]

   // lIndex++;
   ldr x0, [sp, LINDEX]
   add x0, x0, 1
   str x0, [sp, LINDEX]

   // goto startfor1;
   b startfor1
   
endfor1:

    // if (ulCarry != 1) goto endif4;
   ldr x0, [sp, ULCARRY]
   cmp x0, 1
   bne endif4

   // if (lSumLength != MAX_DIGITS) goto endif5;
   ldr x0, [sp, LSUMLENGTH]
   mov x1, MAX_DIGITS
   cmp x0, x1
   bne endif5

   // epilog, return FALSE;
   mov x0, FALSE
   ldr x30, [sp]
   add sp, sp, ADD_STACK_BYTECOUNT
   ret 
   .size   BigInt_add, (. - BigInt_add)

endif5:
   // oSum->aulDigits[lSumLength] = 1;
   ldr x1, [sp, LSUMLENGTH]
   ldr x0, [sp, OSUM]
   mov x7, AULDIGIT
   add x0, x0, x7
   mov x2, 1
   str x2, [x0, x1, lsl 3]


   // lSumLength++;
   ldr x0, [sp, LSUMLENGTH]
   add x0, x0, 1
   str x0, [sp, LSUMLENGTH]

endif4:
   // oSum->lLength = lSumLength;
   ldr x1, [sp, LSUMLENGTH]
   ldr x0, [sp, OSUM]
   str x1, [x0]

   // epilog, return TRUE;
   mov x0, TRUE
   ldr x30, [sp]
   add sp, sp, ADD_STACK_BYTECOUNT
   ret
   .size   BigInt_add, (. - BigInt_add)
