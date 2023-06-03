#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int getTamanhoFile(FILE* grrOriginalFile)
{
    int aux = 0;
    fseek(grrOriginalFile, 0, SEEK_END);
    aux = ftell(grrOriginalFile);
    fseek(grrOriginalFile, 0, SEEK_SET);

    return aux;
}

void openFiles(FILE** grrOriginalFile, FILE** grrFinalFile, int* fileSize)
{
    *grrOriginalFile = fopen("catita.bmp", "rb");
    if(!*grrOriginalFile) printf("Error: Couldn't open'");

    *grrFinalFile = fopen("catita2.bmp", "wb");
    if(!*grrFinalFile) printf("Error: Couldn't open'");

    *fileSize = getTamanhoFile(*grrOriginalFile);
}

int main()
{
    FILE* grrOriginalFile = NULL;
    FILE* grrFinalFile    = NULL;
    int fileSize = 0;
    char* buffer = NULL;
    char* afterHeader = NULL;

    openFiles(&grrOriginalFile, &grrFinalFile, &fileSize);

    printf("File size: %d\n", fileSize);
    buffer = (char*) malloc(fileSize);
    
    if(!buffer)
    {
        printf("Error MALLOC");
        return 1;
    }
    
    fread(buffer, fileSize, 1, grrOriginalFile);

    afterHeader = (buffer+54);
    
    printf("%hx\n", *(afterHeader+2));

    for(int i = 0; i < (fileSize -54); i+=3)
    {
        //afterHeader[i] = 0xff;
        //afterHeader[i+1] = 0xff;
        afterHeader[i+2] = 0xff;
    }

    if(!memcpy(buffer+54, afterHeader, fileSize-54))
    {
        printf("Error MEMCMY");
        return 1;
    }

    fwrite(buffer, 1, fileSize, grrFinalFile);

    return 0;
}