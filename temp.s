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
   







      lSumLength++;
   endif4:

   /* Set the length of the sum. */
   oSum->lLength = lSumLength;

   return TRUE;