   .section .rodata
printfFormatStr: .string "%7ld %7ld %7ld\n"
   
   .section .data
// static long lLineCount = 0;
lLineCount: .quad 0
// static long lWordCount = 0;
lWordCount: .quad 0
// static long lCharCount = 0;
lCharCount: .quad 0
// static int iInWord = FALSE;
iInWord: .word FALSE

   .section .bss
// static int iChar;
iChar: .skip 4

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

loop1:

   // if ((iChar = getchar()) == EOF) goto endloop1;
   bl getchar
   adr x1, iChar
   str w0, [x1]
   cmp w0, EOF
   beq endloop1

   // lCharCount++;
   adr x0, lCharCount
   ldr x1, [x0]
   add x1, x1, 1
   str x1, [x0]

   // if (!isspace(iChar)) goto else1;
   adr x0, iChar
   ldr w0, [x0]
   bl isspace
   cmp w0, FALSE
   beq else1

   // if (!iInWord) goto endif1;
   adr x0, iInWord
   ldr w0, [x0]
   cmp w0, FALSE
   beq endif1

   // lWordCount++;
   adr x0, lWordCount
   ldr x1, [x0]
   add x1, x1, 1
   str x1, [x0]

   // iInWord = FALSE;
   adr x0, iInWord
   mov w1, FALSE
   str w1, [x0]

   // goto endif1;
   b endif1

else1:

   // if (iInWord) goto endif2;
   adr x0, iInWord
   ldr w0, [x0]
   cmp w0, TRUE
   beq endif2

   // iInWord = TRUE;
   adr x0, iInWord
   mov w1, TRUE
   str w1, [x0]

endif2:

endif1:

   // if (iChar != '\n') goto endif3; 
   adr x0, iChar
   ldr x0, [x0]
   cmp x0, '\n'
   bne endif3

   // lLineCount++;
   adr x1, lLineCount;
   ldr x2, [x1]
   add x2, x2, 1
   str x2, [x1]

endif3:

   // goto loop1;
   b loop1

endloop1:

   // if (!iInWord) goto endif4;
   adr x0, iInWord
   ldr w0, [x0]
   cmp w0, FALSE
   beq endif4

   // lWordCount++;
   adr x0, lWordCount
   ldr x1, [x0]
   add x1, x1, 1
   str x1, [x0]

endif4:

   // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
   adr x0, printfFormatStr
   adr x1, lLineCount
   ldr x1, [x1]
   adr x2, lWordCount
   ldr x2, [x2]
   adr x3, lCharCount
   ldr x3, [x3]
   bl printf

// epilog
mov w0, 0
ldr x30, [sp]
add sp, sp, MAIN_STACK_BYTECOUNT
ret
.size main, (. - main)


