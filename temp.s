   // if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif3; /* Check for overflow. */
   ldr x0, [sp, ULSUM]
   ldr x1, [sp, OADDEND2]
   add x2, AULDIGIT, LINDEX
   ldr x1, [x1, x2]
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
   add x1, AULDIGIT, LSUMLENGTH
   add x0, x0, x1
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
   str x1, MAX_DIGITS
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