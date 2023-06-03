#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define HEADER_SIZE 54
#define PIXEL_SIZE 3

int  GetTamanhoFile(FILE* grrOriginalFile);
int  WriteHeader(FILE* grrFinalFile, char* buffer, int size);
void OpenFiles(FILE** grrOriginalFile, FILE** grrFinalFile, int* fileSize);
void ReadColors(int* color, int* colorValue);
void ChangeColor(char* data, int color, int colorValue);

int main()
{
    FILE* grrOriginalFile = NULL;
    FILE* grrFinalFile    = NULL;
    int   fileSize        = 0;
    char* buffer          = NULL;
    char* afterHeader     = NULL;
    int   color           = 0;
    int   colorValue      = 0x00;

    OpenFiles(&grrOriginalFile, &grrFinalFile, &fileSize);

    printf("File size: %d\n", fileSize);
    buffer = (char*) malloc(fileSize);
    
    if(!buffer)
    {
        printf("Error MALLOC");
        return 1;
    }
    
    fread(buffer, fileSize, 1, grrOriginalFile);
    if(!WriteHeader(grrFinalFile, buffer, HEADER_SIZE))
    {
        printf("Error write header");
        return 1;
    }

    afterHeader = (buffer+HEADER_SIZE);
    ReadColors(&color, &colorValue);
    printf("color = %d e colorValue = %d\n", color, colorValue);

    for(int i = 0; i < (fileSize - HEADER_SIZE); i+=PIXEL_SIZE)
    {
        ChangeColor((afterHeader+i), color, colorValue);
        fwrite(afterHeader+i, 1, PIXEL_SIZE, grrFinalFile);
    }

    return 0;
}

int GetTamanhoFile(FILE* grrOriginalFile)
{
    int aux = 0;
    fseek(grrOriginalFile, 0, SEEK_END);
    aux = ftell(grrOriginalFile);
    fseek(grrOriginalFile, 0, SEEK_SET);

    return aux;
}

void OpenFiles(FILE** grrOriginalFile, FILE** grrFinalFile, int* fileSize)
{
    *grrOriginalFile = fopen("grr748.bmp", "rb");
    if(!*grrOriginalFile) printf("Error: Couldn't open'");

    *grrFinalFile = fopen("grr7482.bmp", "wb");
    if(!*grrFinalFile) printf("Error: Couldn't open'");

    *fileSize = GetTamanhoFile(*grrOriginalFile);
}

int WriteHeader(FILE* grrFinalFile, char* buffer, int size)
{
   return (fwrite(buffer, 1, size, grrFinalFile) == size);
}

void ReadColors(int* color, int* colorValue)
{
    printf("0 - Blue | 1 - Grenn | 2 - Red -> ");
    scanf("%d", color);
    printf("Color value [ 0 - 255 ]: ");
    scanf("%d", colorValue);
}

void ChangeColor(char* data, int color, int colorValue)
{
    int aux = 0x00;
    aux     = data[color] + colorValue;
    
    if(aux > 0xFF)  aux = 0xFF;

    data[color] = aux;
}