#include <stdio.h>

int main()
{
   int i;
    char *filename = "mywcBoundary5.txt";


    FILE *fp = fopen(filename, "w");
    if (fp == NULL)
    {
        printf("Error opening the file %s", filename);
        return -1;
    }

    for (i = 32; i < 127; i++) {
        fputc(i, fp);
    }


    fclose(fp);

    return 0;
}