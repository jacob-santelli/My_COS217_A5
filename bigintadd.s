   .section .rodata
   
   .section .data

   .section .bss

   .section .text

   .equ    MAIN_STACK_BYTECOUNT, 16

   // enum {FALSE, TRUE};
   .equ FALSE, 0
   .equ TRUE, 1

   .equ EOF, -1

   .global main
main:

// prolog
sub sp, sp, MAIN_STACK_BYTECOUNT
str x30, [sp]


// epilog
mov w0, 0
ldr x30, [sp]
add sp, sp, MAIN_STACK_BYTECOUNT
ret
.size main, (. - main)