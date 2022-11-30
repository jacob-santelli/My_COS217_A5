   // enum {FALSE, TRUE};
   .equ FALSE, 0
   .equ TRUE, 1

   .equ EOF, -1

   .section .data
// static long lLineCount = 0;
lLineCount: .quad 0
// static long lWordCount = 0;
lWordCount: .quad 0
// static long lCharCount = 0;
lCharCount: .quad 0
// static int iInWord = FALSE;
iINWord: .word FALSE

   .section .bss
// static int iChar;
iChar: .skip 4

   .global main
main:
loop1:
   // if ((iChar = getchar()) == EOF) goto endloop1;
   bl getchar
   adr x1, iChar
   str w0, [x1]
   ldr x1, [x1]
   cmp x1, EOF
   beq endloop1

   // lCharCount++;
   adr x0, lCharCount
   add [x0], [x0], 1

   // if (!isspace(iChar)) goto else1;
   adr x0, iChar
   ldr x0, [x0]
   bl isspace
   cmp x0, FALSE
   beq else1

   // if (!iInWord) goto endif1;
   adr x0, iInWord
   ldr x0, [x0]
   cmp x0, FALSE
   beq endif1

   // lWordCount++;
   adr x0, lWordCount
   add [x0], [x0], 1

   // iInWord = FALSE;
   adr x0, iInWord
   str FALSE, [x0]

   // goto endif1;
   b endif1

else1:
   // if (iInWord) goto endif2;
   adr x0, iInWord
   cmp [x0], TRUE
   beq endif2

   // iInWord = TRUE;
   adr x1, TRUE
   str [x1], x0

endif2:
endif1:

   // if (iChar != '\n') goto endif3; 
   adr x0, iChar
   ldr x0, [x0]
   cmp x0, '\n'
   bne endif3

   // lLineCount++;
   adr x1, lLineCount;
   add [x1], [x1], 1

endif3:

   // goto loop1;
   b loop1

endloop1:

if (!iInWord) goto endif4;
   lWordCount++;
endif4:

printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
return 0;


