   // if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif3; /* Check for overflow. */
    
    
    
    
    
    
    
    
    
    
    
    
         ulCarry = 1;
      endif3:

      oSum->aulDigits[lIndex] = ulSum;
      lIndex++;
      goto startfor1;
   endfor1: