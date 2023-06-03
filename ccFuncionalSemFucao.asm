.686
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data
    newLine 				db 0Ah
    messageColor 			db "0 - BLUE | 1 - GREEN | 2 - RED: ", 0h
    messageColorVal 		db "Color value [0 - 255]: ", 0h
    messageArquivoEntrada 	db "Qual o nome do arquivo principal?(max 10 caracteres): ", 0h
    messageArquivoSaida 	db "Qual o nome do arquivo de saida?(max 11 caracteres): ", 0h
    
    color 					dd 0 ; cor a ser trocada
    colorValue 				dd 0 ; valor a ser incrementado
    
    imgName 				db 12 dup(0) ; nome da imagem no diretorio
    newImgName 				db 13 dup(0) ; nome da imagem a ser gerada
    
    fileBuffer 				dd 814140 dup(0)
    tamanhoArqOriginal 		dd 814134 ; sera o tamanho do arquivo
	tamanhoAux 				dd 0
	headerSize 				dd 54
	pixelSize 				dd 3
	pixelArray 				db 3 dup(0)
	
    imgEntradaHandle 		dd 0 ; handle do arquivo original
    imgSaidaHandle			dd 0 ; handle do arquivo novo
    
    inputHandle 			dd 0
    outputHandle 			dd 0
    consoleCount 			dd 0
    
    inputString 			db 12 dup(0)
    
    msg 					db "valor digitado eh: ", 0h  
	msg2 					db 10 dup(0)
	
.code
start:
    ;------------------------------------- pegando handles de IO
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax 
    ;-------------------------------------

    ;------------------------------------- pegando valores
    ;		COR A SER TROCADA
    invoke WriteConsole, outputHandle, addr messageColor, sizeof messageColor, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL
    mov esi, offset inputString
    proximo:
        mov al, [esi]
        inc esi
        cmp al, 48
        jl terminar
        cmp al, 58
        jl proximo
    terminar:
        dec esi
        xor al, al
        mov [esi], al
   
    invoke atodw, addr inputString
    mov color, eax
    invoke dwtoa, color, addr inputString
    invoke StrLen, addr inputString
    mov tamanhoAux, eax
    
    invoke WriteConsole, outputHandle, addr msg, sizeof msg, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr inputString, tamanhoAux, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL
	
    ;		VALOR A SER INCREMENTADO
    invoke WriteConsole, outputHandle, addr messageColorVal, sizeof messageColorVal, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL
    mov esi, offset inputString
    proximo2:
        mov al, [esi]
        inc esi
        cmp al, 48
        jl terminar2
        cmp al, 58
        jl proximo2
    terminar2:
        dec esi
        xor al, al
        mov [esi], al

    invoke atodw, addr inputString
    mov colorValue, eax
    invoke dwtoa, colorValue, addr inputString
    invoke StrLen, addr inputString
    mov tamanhoAux, eax
    
    invoke WriteConsole, outputHandle, addr msg, sizeof msg, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr inputString, tamanhoAux, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL
	
    ; 		NOME DO ARQUIVO PRINCIPAL
	invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL 
    invoke WriteConsole, outputHandle, addr messageArquivoEntrada, sizeof messageArquivoEntrada, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr imgName, sizeof imgName, addr consoleCount, NULL
	
	mov esi, offset imgName ; Armazenar apontador da string em esi
	proximo3:
	mov al, [esi] ; Mover caractere atual para al
	inc esi ; Apontar para o proximo caractere
	cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
	jne proximo3
	dec esi ; Apontar para caractere anterior
	xor al, al ; ASCII 0
	mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR
	
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr msg, sizeof msg, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr imgName, 11, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL 

    ; 		NOME DO ARQUIVO DE SAIDA
	invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL 
    invoke WriteConsole, outputHandle, addr messageArquivoSaida, sizeof messageArquivoSaida, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr newImgName, sizeof newImgName, addr consoleCount, NULL
	
	mov esi, offset newImgName ; Armazenar apontador da string em esi
	proximo4:
	mov al, [esi] ; Mover caractere atual para al
	inc esi ; Apontar para o proximo caractere
	cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
	jne proximo4
	dec esi ; Apontar para caractere anterior
	xor al, al ; ASCII 0
	mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR
	
    invoke WriteConsole, outputHandle, addr msg, sizeof msg, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newImgName, 12, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL 
    ;-------------------------------------
    
    ;------------------------------------ abrindo arquivo original
    invoke CreateFile, addr imgName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov imgEntradaHandle, eax
    ;------------------------------------- 

    ;------------------------------------- criando novo arquivo
    invoke CreateFile, addr newImgName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov imgSaidaHandle, eax
    ;------------------------------------- 

	;------------------------------------- lendo o arquivo original e gravando header no novo arquivo
    invoke ReadFile, imgEntradaHandle, addr fileBuffer, headerSize, addr consoleCount, NULL
    invoke WriteFile, imgSaidaHandle, addr fileBuffer, headerSize, addr consoleCount, NULL 
	;-------------------------------------
	
	;------------------------------------- trocando cor (tamanho original - header = 814080)
	mov ebx, 0
	porra:
	invoke ReadFile, imgEntradaHandle, addr pixelArray, 3, addr consoleCount, NULL
	xor eax, eax
	mov edx, color
	mov al, pixelArray[edx]
	add eax, colorValue
	cmp eax, 255
	jg maior
	mov pixelArray[edx], al
	invoke WriteFile, imgSaidaHandle, addr pixelArray, 3, addr consoleCount, NULL
	add ebx, 3
	cmp ebx, 814080
	je fim
	jmp porra	
	maior:
	mov pixelArray[edx], 255
	invoke WriteFile, imgSaidaHandle, addr pixelArray, 3, addr consoleCount, NULL
	add ebx, 3
	cmp ebx, 814080
	je fim
	jmp porra
	fim:
	;-------------------------------------
	
    ;------------------------------------ fechando arquivos
    invoke CloseHandle, imgEntradaHandle
    invoke CloseHandle, imgSaidaHandle
    ;------------------------------------

    invoke ExitProcess, 0
end start
	; escrever no novo arquivo
	;invoke WriteFile, imgSaidaHandle, addr fileBuffer, tamanhoArqOriginal, addr consoleCount, NULL
	
	; ver retorno
	;invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL 
	;invoke dwtoa, eax, addr msg2
    ;invoke WriteConsole, outputHandle, addr msg2, 1, addr consoleCount, NULL
	;invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL 
	
	; tentativa de pegar o tamanho do arquivo
	;invoke StrLen, addr fileBuffer
	;mov tamanhoArqOriginal, eax
	;invoke dwtoa, tamanhoArqOriginal, addr msg2
    ;invoke WriteConsole, outputHandle, addr msg2, 4, addr consoleCount, NULL