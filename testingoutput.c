#include <stdio.h>

int main()
{
   int i;
   int j;
    char *filename = "mywcStress2.txt";


    FILE *fp = fopen(filename, "w");
    if (fp == NULL)
    {
        printf("Error opening the file %s", filename);
        return -1;
    }

    for (i = 0; i < 50000; i++) {
        j = rand() % 127;
        if ((j == 9) || (j == 10) || ((j >= 32) && (j <= 126)))
            fputc(j, fp);
        else i--;
    }


    fclose(fp);

    return 0;
}