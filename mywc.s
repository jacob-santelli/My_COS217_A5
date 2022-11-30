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
   beq endloop1

   // lCharCount++;
   adr x0, lCharCount
   ldr x0, [x0]
   add x0, x0, 1

   if (!isspace(iChar)) goto else1;
      if (!iInWord) goto endif1;
         lWordCount++;
         iInWord = FALSE;
      goto endif1;

   else1:
      if (iInWord) goto endif2;
         iInWord = TRUE;
      endif2:
   endif1:

   if (!iChar == '\n') goto endif3; 
      lLineCount++;
   endif3:

   goto loop1;
endloop1:


