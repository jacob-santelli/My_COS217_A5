   .section .rodata
   
   .section .data

   .section .bss

   .section .text

   // enum {MAX_DIGITS = 32768}; 
   .equ MAX_DIGITS, 32768

   // enum {FALSE, TRUE};
   .equ FALSE, 0
   .equ TRUE, 1

   .equ EOF, -1

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
   ldr x0, [x0]
   ldr x1, [sp, OADDEND2]
   ldr x1, [x1]
   bl BigInt_larger
   ldr x1, [sp, LSUMLENGTH]
   str x0, [x1]

   /* Clear oSum's array if necessary. */
   // if (oSum->lLength <= lSumLength) goto endif1;
   ldr x0, [sp, OSUM]
   ldr x0, [x0]
   ldr x1, [sp, LSUMLENGTH]
   cmp x0, x1
   ble endif1
      // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));

      // third thing
      // this may be wrong

      // ldr x0, [sp, ULCARRY]
      // bl sizeof
      mov x0, 8
      mov x1, MAX_DIGITS
      mul x0, x0, x1
      mov x3, x0

      // second thing
      mov w1, 0

      // first thing
      ldr x0, [sp, OSUM]
      ldr x0, [x0]

      bl memset
   endif1:

   /* Perform the addition. */
   //vulCarry = 0
   mov x0, 0
   str x0, [sp, ULCARRY]
   // lIndex = 0
   mov x0, 0
   str x0, [sp, LINDEX]


   // if (lIndex >= lSumLength) goto endfor1;
   ldr x0, [sp, LINDEX]
   ldr x1, [sp, LSUMLENGTH]
   cmp x0, x1
   bge endfor1
   startfor1:
      // ulSum = ulCarry;
      ldr x0, [sp, ULCARRY]
      str x0, [sp, ULSUM]
      // ulCarry = 0
      mov x0, 0
      str x0, [sp, ULCARRY]

      // ulSum += oAddend1->aulDigits[lIndex];
      ldr x0, [sp, OADDEND1]
      ldr x0, [x0, AULDIGIT + LINDEX]

      // adding to ulSum
      ldr x1, [sp, ULSUM]
      add x0, x0, x1
      str x0, [sp, ULSUM]

      /* Check for overflow. */
      // if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif2;
      ldr x0, [sp, ULSUM]
      ldr x1, [sp, OADDEND1]
      ldr x1, [x1, AULDIGIT + LINDEX]
      cmp x0, x1
      bgt endif2

         // ulCarry = 1;
         mov x0, 1
         str x0, [sp, ULCARRY]
      
      endif2:

      // ulSum += oAddend2->aulDigits[lIndex];
      ldr x0, [sp, OADDEND2]
      ldr x0, [x0, AULDIGIT + LINDEX]

      // adding to ulSum
      ldr x1, [sp, ULSUM]
      add x0, x0, x1
      str x0, [sp, ULSUM]

    // if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif3; /* Check for overflow. */
   ldr x0, [sp, ULSUM]
   ldr x1, [sp, OADDEND2]
   ldr x1, [x1, AULDIGIT + LINDEX]
   cmp x0, x1
   // bge might be wrong bcond
   bge endif3

   // ulCarry = 1
   ldr x0, [sp, ULCARRY]
   mov x1, 1
   str x1, [x0]

endif3:
   // oSum->aulDigits[lIndex] = ulSum;
   ldr x0, [sp, OSUM]
   add x0, x0, AULDIGIT + LSUMLENGTH
   ldr x1, [sp, ULSUM]
   str x1, [x0]

   // lIndex++;
   ldr x0, [sp, LINDEX]
   add x0, x0, 1
   str x0, [sp, LINDEX]

   // goto startfor1;
   b startfor1
   
endfor1:

    // if (ulCarry != 1) goto endif4;
   str x0, [sp, ULCARRY]
   cmp x0, 1
   bne endif4

   // if (lSumLength != MAX_DIGITS) goto endif5;
   str x0, [sp, LSUMLENGTH]
   mov x1, MAX_DIGITS
   cmp x0, x1
   bne endif5

   // epilog, return FALSE;
   mov x0, FALSE
   ldr x30, [sp]
   add sp, sp, ADD_STACK_BYTECOUNT
   ret 

endif5:
   // oSum->aulDigits[lSumLength] = 1;
   ldr x0, [sp, OSUM]
   add x0, x0, AULDIGIT + LSUMLENGTH
   mov x1, 1
   str x1, [x0]

   // lSumLength++;
   ldr x0, [sp, LSUMLENGTH]
   add x0, x0, 1
   str x0, [sp, LSUMLENGTH]

endif4:
   // oSum->lLength = lSumLength;
   ldr x0, [sp, OSUM]
   ldr x1, [sp, LSUMLENGTH]
   str x1, [x0]

   // epilog, return TRUE;
   mov x0, TRUE
   ldr x30, [sp]
   add sp, sp, ADD_STACK_BYTECOUNT
   ret
