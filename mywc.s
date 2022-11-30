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
   cmp [x1], EOF
   bhi 


