   .section .rodata
   
   .section .data

   .section .bss

   .section .text

   // Must be multiples of 16
   .equ LARGER_STACK_BYTECOUNT, 32
   .equ ADD_STACK_BYTECOUNT, 64

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
   MAX_DIGITS .req x10
   ONE .req x11

   // passing parameters in
   mov OADDEND1, x0
   mov OADDEND2, x1
   mov OSUM, x2

   // using registers as "enums"
   mov MAX_DIGITS, 32768
   mov ONE, 1

   // unsigned long ulCarry;
   // unsigned long ulSum;
   // long lIndex;
   // long lSumLength; 

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
   // first parameter
   mov x0, OSUM
   add x0, x0, AULDIGIT

   // second parameter
   eor w1, w1, w1

   // third parameter
   lsl x2, MAX_DIGITS, 3

   bl memset

endif1:

   // lIndex = 0
   eor LINDEX, LINDEX, LINDEX

   // if (lIndex >= lSumLength) goto endfor1;
   cbz LSUMLENGTH, endif4

   // reset c flag to zero
   // directly modify pstate register, 
   // setting c flag to 0
   msr nzcv, LINDEX

startfor1:

   // lIndex++;
   // do this out of order to correctly 
   // load oAddend->aulDigits[lIndex]
   add LINDEX, LINDEX, ONE

   // find oAddend1->aulDigits[lIndex];
   ldr x1, [OADDEND1, LINDEX, lsl 3]

   // find oAddend2->aulDigits[lIndex];
   ldr x2, [OADDEND2, LINDEX, lsl 3]

   // add to ulSum with carry flag
   adcs ULSUM, x1, x2

   // oSum->aulDigits[lIndex] = ulSum;
   str ULSUM, [OSUM, LINDEX, lsl 3]

   // if (lIndex < lSumLength) goto startfor1
   // use eor + cbnz instead of cmp to avoid 
   // changing carry flag on pstate register
   eor x0, LINDEX, LSUMLENGTH
   cbnz x0, startfor1

   // if carry flag still 1 go to endif4
   bcc endif4

   // if (lSumLength != MAX_DIGITS) goto endif5;
   cmp LSUMLENGTH, MAX_DIGITS
   bne endif5

   // epilog, return FALSE;
   eor w0, w0, w0
   ldr x30, [sp]
   add sp, sp, ADD_STACK_BYTECOUNT
   ret 
   .size   BigInt_add, (. - BigInt_add)

endif5:
   // oSum->aulDigits[lSumLength] = 1;
   add x0, OSUM, AULDIGIT
   str ONE, [x0, LSUMLENGTH, lsl 3]

   // lSumLength++;
   add LSUMLENGTH, LSUMLENGTH, ONE

endif4:
   // oSum->lLength = lSumLength;
   str LSUMLENGTH, [OSUM]

   // epilog, return TRUE;
   mov x0, ONE
   ldr x30, [sp]
   add sp, sp, ADD_STACK_BYTECOUNT
   ret
   .size   BigInt_add, (. - BigInt_add)
