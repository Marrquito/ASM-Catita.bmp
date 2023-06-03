.686
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data   
    imgName db "a.txt", 0h ; nome da imagem no diretorio
    newImgName db "b.txt" ; nome da imagem a ser gerada
    
    fileBuffer dd 10 dup(0)
    tamanhoArq dd 0 ; sera o tamanho do arquivo
    
    imgEntradaHandle dd 0 ; handle do arquivo original
    imgSaidaHandle dd 0 ; handle do arquivo novo
    
    inputHandle dd 0
    outputHandle dd 0
    consoleCount dd 0
    
    inputString db 12 dup(0)
    msg db 10 dup(0)
.code
start:
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax

    invoke CreateFile, addr imgName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov imgEntradaHandle, eax

    invoke CreateFile, addr newImgName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov imgSaidaHandle, eax


    invoke ReadFile, imgEntradaHandle, addr fileBuffer, 10, addr consoleCount, NULL 
    ;invoke ReadFile, imgEntradaHandle, addr fileBuffer, sizeof fileBuffer, addr consoleCount, NULL
    invoke dwtoa, eax, addr msg
    invoke WriteConsole, outputHandle, addr msg, 1, addr consoleCount, NULL
    
    invoke StrLen, addr fileBuffer
    mov tamanhoArq, eax
    invoke dwtoa, tamanhoArq, addr msg
    invoke WriteConsole, outputHandle, addr msg, 1, addr consoleCount, NULL

    invoke WriteFile, imgSaidaHandle, addr fileBuffer, sizeof tamanhoArq, addr consoleCount, NULL 
    invoke dwtoa, eax, addr msg
    invoke WriteConsole, outputHandle, addr msg, 1, addr consoleCount, NULL

 
    invoke CloseHandle, imgEntradaHandle
    invoke CloseHandle, imgSaidaHandle
 

    invoke ExitProcess, 0
end start