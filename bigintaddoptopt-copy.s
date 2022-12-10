   .section .rodata
   
   .section .data

   .section .bss

   .section .text

   .equ LARGER_STACK_BYTECOUNT, 32
   .equ ADD_STACK_BYTECOUNT, 64

   .equ LLENGTH, 0
   .equ AULDIGIT, 8

   .global BigInt_add
BigInt_add:
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

   mov OADDEND1, x0
   mov OADDEND2, x1
   mov OSUM, x2

   mov MAX_DIGITS, 32768
   mov ONE, 1

   ldr x0, [OADDEND1]
   ldr x1, [OADDEND2]

   cmp x0, x1
   ble else1

   mov LSUMLENGTH, x0

   b endif6

else1:
   mov LSUMLENGTH, x1

endif6:
   ldr x0, [OSUM]
   cmp x0, LSUMLENGTH
   ble endif1
   mov x0, OSUM
   add x0, x0, AULDIGIT
   eor w1, w1, w1
   lsl x2, MAX_DIGITS, 3
   bl memset
endif1:

   eor LINDEX, LINDEX, LINDEX
   cbz LSUMLENGTH, endif4
   msr nzcv, LINDEX

startfor1:

   add x0, OADDEND1, AULDIGIT
   ldr x1, [x0, LINDEX, lsl 3]

   add x0, OADDEND2, AULDIGIT
   ldr x2, [x0, LINDEX, lsl 3]

   adcs ULSUM, x1, x2
   add x0, OSUM, AULDIGIT
   str ULSUM, [x0, LINDEX, lsl 3]
   add LINDEX, LINDEX, ONE

   eor x0, LINDEX, LSUMLENGTH
   cbnz x0, startfor1

   bcc endif4

   cmp LSUMLENGTH, MAX_DIGITS
   bne endif5


   eor w0, w0, w0
   ldr x30, [sp]
   add sp, sp, ADD_STACK_BYTECOUNT
   ret 
   .size   BigInt_add, (. - BigInt_add)

endif5:
   add x0, OSUM, AULDIGIT
   str ONE, [x0, LSUMLENGTH, lsl 3]

   add LSUMLENGTH, LSUMLENGTH, ONE

endif4:
   str LSUMLENGTH, [OSUM]
   mov x0, ONE
   ldr x30, [sp]
   add sp, sp, ADD_STACK_BYTECOUNT
   ret
   .size   BigInt_add, (. - BigInt_add)
