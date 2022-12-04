   .section .rodata
   
   .section .data

   .section .bss

   .section .text

   // Must be a multiple of 16
    .equ    LARGER_STACK_BYTECOUNT, 32
        
    // Local variable stack offsets:
    .equ LLARGER, 8

    // Parameter stack offsets:
    .equ LLENGTH1, 16
    .equ LLENGTH2, 24

BigInt_larger:

    // Prolog
    sub sp, sp, LARGER_STACK_BYTECOUNT
    str x30, [sp]
    str x0, [sp, LLENGTH1]
    str x1, [sp, LLENGTH2]

    // long lLarger
    





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