;########### LISTA DE FUNCIONES IMPORTADAS
extern strPrint
extern strDelete
extern strClone

extern malloc
extern free
extern fprintf

global countVowels
global createLettersQuantityArray
global getMaxVowels
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text


%define LQ_SIZE 24

%define LETTER_A 0x61
%define LETTER_E 0x65
%define LETTER_I 0x69
%define LETTER_O 0x6F
%define LETTER_U 0x75
; rdi, rsi, rdx, rcx, r8, and r9.

; Signatura de la función:
; uint8_t countVowels(char* word);
; Dada una palabra retorna la cantidad de vocales

; Mapeo de parámetros a registros:
; rdi[word] 

; Idea de la implementación:
; me voy trayendo de a un char y comparo con los valores ascii de las vocales, en el caso de que coicida con alguno, aumento el contador

countVowels:
    ; prólogo
    push rbp
    mov rbp, rsp


    ; cuerpo
    xor rax, rax ; limpio rax
    xor r10, r10 ; limpio r10
    mov r10b, [rdi] ; me traigo el primer char
    ; Chequeo que no sea nulo:
    cmp r10b, 0
    je .fin
    
    .bucle:
        ; Ya tengo el char en r10b, entonces comparo con las vocales:
        .letra_a:
            xor r9, r9 ; limpio r9
            mov r9b, 0x61 
            cmp r10b, r9b
            jne .letra_e
            inc rax
        .letra_e:
            xor r9, r9 ; limpio r9
            mov r9b, 0x65 
            cmp r10b, r9b
            jne .letra_i
            inc rax
        .letra_i:
            xor r9, r9 ; limpio r9
            mov r9b, 0x69 
            cmp r10b, r9b
            jne .letra_o
            inc rax
        .letra_o:
            xor r9, r9 ; limpio r9
            mov r9b, 0x6F
            cmp r10b, r9b
            jne .letra_u
            inc rax
        .letra_u:
            xor r9, r9 ; limpio r9
            mov r9b, 0x75 
            cmp r10b, r9b
            jne .avanzar_char
            inc rax 

        .avanzar_char:
            add rdi, 1 ; avanzo al siguiente char 
            mov r10b, [rdi] ; me traigo el char a r10b
            ; Chequeo que no sea nulo:
            cmp r10b, 0
            jne .bucle

    .fin:
    ; epílogo
    push rbp
    ret 
    ; COMPLETAR


;letters_quantity_t* createLettersQuantityArray(uint8_t size);
createLettersQuantityArray:
    ; COMPLETAR

; char* getMaxVowels(letters_quantity_t* wq_array, uint8_t array_size);
getMaxVowels:
    ; COMPLETAR
