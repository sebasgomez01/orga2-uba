section .text

global contar_pagos_aprobados_asm
global contar_pagos_rechazados_asm

global split_pagos_usuario_asm

extern malloc
extern free
extern strcmp

%define LISTA_OFFSET_FIRST 0
%define LISTA_OFFSET_LAST  8

%define ELEMENTO_LISTA_OFFSET_DATA  0
%define ELEMENTO_LISTA_OFFSET_NEXT  8
%define ELEMENTO_LISTA_OFFSET_PREV 16

%define PAGO_OFFSET_MONTO 	  0
%define PAGO_OFFSET_APROBADO  1
%define PAGO_OFFSET_PAGADOR   8
%define PAGO_OFFSET_COBRADOR 16

%define SPLITTED_OFFSET_CANT_APROBADOS    0
%define SPLITTED_OFFSET_CANT_RECHAZADOS   1
%define SPLITTED_OFFSET_APROBADOS         8
%define SPLITTED_OFFSET_RECHAZADOS       16


%define SIZE_LISTA_T          16
%define SIZE_ELEMENTO_LISTA_T 24
%define SIZE_PAGO_T	          24
%define SIZE_PAGO_SPLLITED_T  24
%define SIZE_POINTER           8

%define NULL		  0

section .data
    SIZE_PTR: DB 8

section .text
;########### SECCION DE TEXTO (PROGRAMA)

; El usuario es el COBRADOR
; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
; RDI -> list_t* pList
; RSI -> char* usuario
contar_pagos_aprobados_asm:
    ; Prologo
    PUSH rbp
    MOV rbp, rsp
    PUSH r12
    PUSH r13
    PUSH r14
    PUSH r15
    ; Cuerpo
    ; 1. Guardo los parametros originales de la funcion
    MOV r15, rdi ; list_t* pList
    MOV r14, RSI ; char* usuario

    ; 2. Inicializo el contador del resultado
    XOR r13, r13

    ; 3. Me traigo el primer elemento de la lista enlazada
    MOV r12, [rdi + LISTA_OFFSET_FIRST] ; Cargo en r12 algo del tipo listElem_t

    ; Reviso que no sea nulo
    TEST r12, r12
    JZ .fin

    .revisarPago:
        ; Me traigo el cobrador del pago asociado a este elemento
        MOV r8, [r12 + ELEMENTO_LISTA_OFFSET_DATA]
        MOV r9, [r8 + PAGO_OFFSET_APROBADO]

        TEST r9b, r9b
        JZ .continuarRevisando ; Si el pago esta desaprobado continuo con el siguiente

        ; Reviso si pertenece al usuario solicitado

        ; int strcmp(const char* s1, const char* s2);
        MOV rdi, r14                                                       ; char* usuario
        MOV rsi, [r8 + PAGO_OFFSET_COBRADOR] ; char* cobrador del pago
        CALL strcmp ; Devuelve 0 si coinciden los strings

        TEST rax, rax
        JNZ .continuarRevisando

        INC r13 ; Si dio 0, este pago pertenecia al usuario, incremento el contador

        .continuarRevisando:
         MOV r12, [r12 + ELEMENTO_LISTA_OFFSET_NEXT]

        ; Reviso que el siguiente nodo no sea nulo
        TEST r12, r12
        JNZ .revisarPago

    .fin:

    XOR rax, rax
    MOV al, r13b

    ; Epilogo
    POP r15
    POP r14
    POP r13
    POP r12
    POP rbp
    RET

; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);
; RDI -> list_t* pList
; RSI -> char* usuario
contar_pagos_rechazados_asm:
   ; Prologo
    PUSH rbp
    MOV rbp, rsp
    PUSH r12
    PUSH r13
    PUSH r14
    PUSH r15
    ; Cuerpo
    ; 1. Guardo los parametros originales de la funcion
    MOV r15, rdi ; list_t* pList
    MOV r14, RSI ; char* usuario

    ; 2. Inicializo el contador del resultado
    XOR r13, r13

    ; 3. Me traigo el primer elemento de la lista enlazada
    MOV r12, [rdi + LISTA_OFFSET_FIRST] ; Cargo en r12 algo del tipo listElem_t

    ; Reviso que no sea nulo
    TEST r12, r12
    JZ .fin

    .revisarPago:
        ; Me traigo el cobrador del pago asociado a este elemento
        MOV r8, [r12 + ELEMENTO_LISTA_OFFSET_DATA]
        MOV r9, [r8 + PAGO_OFFSET_APROBADO]

        TEST r9b, r9b
        JNZ .continuarRevisando ; Si el pago esta aprobado continuo con el siguiente

        ; Reviso si pertenece al usuario solicitado

        ; int strcmp(const char* s1, const char* s2);
        MOV rdi, r14                                                       ; char* usuario
        MOV rsi, [r8 + PAGO_OFFSET_COBRADOR] ; char* cobrador del pago
        CALL strcmp ; Devuelve 0 si coinciden los strings

        TEST rax, rax
        JNZ .continuarRevisando

        INC r13 ; Si dio 0, este pago pertenecia al usuario, incremento el contador

        .continuarRevisando:
         MOV r12, [r12 + ELEMENTO_LISTA_OFFSET_NEXT]

        ; Reviso que el siguiente nodo no sea nulo
        TEST r12, r12
        JNZ .revisarPago

    .fin:
    XOR rax, rax
    MOV al, r13b

    ; Epilogo
    POP r15
    POP r14
    POP r13
    POP r12
    POP rbp
    RET


; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);
split_pagos_usuario_asm:
   ; Prologo
    PUSH rbp
    MOV rbp, rsp
    PUSH r12
    PUSH r13
    PUSH r14
    PUSH r15
    ; Cuerpo
    ; 1. Guardo los parametros originales de la funcion
    MOV r15, rdi ; list_t* pList
    MOV r14, rsi ; char* usuario

    ; Tengo que reservar memoria para la estructura final
    ; void* malloc(size_t size);
    MOV rdi, SIZE_PAGO_SPLLITED_T
    CALL malloc

    MOV r13, rax ; Guardo en registro no volatil el puntero

    ; Tengo que contar cuantos pagos aprobados tengo
    ; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
    MOV rdi, r15 ; list_t* pList
    MOV rsi, r14 ; char* usuario
    CALL contar_pagos_aprobados_asm

    MOV BYTE [r13 + SPLITTED_OFFSET_CANT_APROBADOS], al ; Guardo en la estrucura la cantidad de aprobados

    ; Tengo que alocar memoria para los pagos aprobados
    ; void* malloc(size_t size);
    XOR r8, r8
    MOV r8, SIZE_POINTER
    MUL r8 ; CANT_APROBADOS * 8 bytes
    MOV rdi, rax
    CALL malloc

    MOV QWORD [r13 + SPLITTED_OFFSET_APROBADOS], rax ; Guardo en la estrucura el puntero a los pagos aprobados
    MOV r12, rax

    ; Tengo que contar cuantos pagos rechazados
    ; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);
    MOV rdi, r15 ; list_t* pList
    MOV rsi, r14 ; char* usuario
    CALL contar_pagos_rechazados_asm

    MOV BYTE [r13 + SPLITTED_OFFSET_CANT_RECHAZADOS], al ; Guardo en la estrucura la cantidad de rechazados

    ; Tengo que alocar memoria para los pagos rechazados
    XOR r8, r8
    MOV r8, SIZE_POINTER
    MUL r8 ; CANT_RECHAZADOS * 8 bytes
    MOV rdi, rax
    CALL malloc

    MOV QWORD [r13 + SPLITTED_OFFSET_RECHAZADOS], rax ; Guardo en la estrucura el puntero a los pagos rechazados
    PUSH r13      ; ESTO LUEGO LO VOY A POPEAR EN rax
    MOV r13, rax  ; Ya no necesito el puntero a la estructura, pero si a la lista de rechazado

    ; Tengo que escribir cada pago en la lista correspondiente
    ; Me traigo el primer elemento de la lista enlazada
    MOV r15, [r15 + LISTA_OFFSET_FIRST] ; Cargo en r12 algo del tipo listElem_t

    ; Reviso que no sea nulo
    TEST r15, r15
    JZ .fin

    .revisarPago:
        ; Me traigo el cobrador del pago asociado a este elemento
        MOV r8, [r15 + ELEMENTO_LISTA_OFFSET_DATA]
        MOV r9, [r8 + PAGO_OFFSET_APROBADO]

        ; Reviso si pertenece al usuario solicitado
        ; int strcmp(const char* s1, const char* s2);
        MOV rdi, r14                                                       ; char* usuario
        MOV rsi, [r8 + PAGO_OFFSET_COBRADOR] ; char* cobrador del pago
        CALL strcmp ; Devuelve 0 si coinciden los strings

        TEST rax, rax
        JNZ .continuarRevisando

        ;  Reviso a que lista pertenece
        MOV r8, [r15 + ELEMENTO_LISTA_OFFSET_DATA]
        MOV r9, [r8 + PAGO_OFFSET_APROBADO]

        TEST r9b, r9b
        JZ .pagoDesaprobado ; Si el pago esta desaprobado

        ; Si el pago esta aprobado:
        MOV QWORD [r12], r15 + ELEMENTO_LISTA_OFFSET_DATA
        ADD r12, SIZE_POINTER
        JMP .continuarRevisando

        .pagoDesaprobado:
        MOV QWORD [r13], r15 + ELEMENTO_LISTA_OFFSET_DATA
        ADD r13, SIZE_POINTER

        .continuarRevisando:
         MOV r15, [r15 + ELEMENTO_LISTA_OFFSET_NEXT]

        ; Reviso que el siguiente nodo no sea nulo
        TEST r15, r15
        JNZ .revisarPago

    POP rax

    .fin:
    ; Epilogo
    POP r15
    POP r14
    POP r13
    POP r12
    POP rbp
    RET