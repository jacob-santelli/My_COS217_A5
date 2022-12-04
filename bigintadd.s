   .section .rodata
   
   .section .data

   .section .bss

   .section .text

   // Must be a multiple of 16
    .equ    LARGER_STACK_BYTECOUNT, 32
    .equ    ADD_STACK_BYTECOUNT, 64
        
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








   .equ    MAIN_STACK_BYTECOUNT, 16

   // enum {FALSE, TRUE};
   .equ FALSE, 0
   .equ TRUE, 1

   .equ EOF, -1

   .global main

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