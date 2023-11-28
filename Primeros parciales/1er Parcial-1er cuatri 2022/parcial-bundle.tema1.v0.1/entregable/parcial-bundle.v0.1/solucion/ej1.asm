
global strArrayNew
global strArrayGetSize
global strArrayAddLast
global strArraySwap
global strArrayDelete

extern calloc
extern strClone

;########### SECCION DE DATOS
section .data

%define OFFSET_SIZE 0
%define OFFSET_CAPACITY 1
%define OFFSET_DATA 8
%define SIZE_STRUCT_ARRAY 16

;########### SECCION DE TEXTO (PROGRAMA)
section .text



; Signatura de la función:
; str_array_t* strArrayNew(uint8_t capacity)
; Crea un array de strings nuevo con capacidad indicada por capacity .

; Mapeo de parámetros a registros:
; rdi[capacity]

; Idea de la implementación:
; Primero tengo que reservar memoria para la estructura, el tamaño de la estructura es 16 bytes
; Después tengo que asignar el valor capacity al campo de la estructura
; También tengo reservar memoria para el arreglo, este va a tener numElems = capacity y sizeElems = 8, pues son punteros

strArrayNew:
    ; prólogo
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14 
    push r15

    xor r15, r15 ; limpio r15
    xor r14, r14 ; limpio r14
    ; cuerpo 
    ; Primero me guardo los parámetros en registros no volátiles para no perderlos al llamar al calloc
    mov r15, rdi ; r15 = capacity
    ; Quiero llamar a calloc para reservar memoria para el arreglo data, guardo los parámetros:
    ; rdi = capacity
    mov rsi, 8 
    call calloc
    ; ahora tengo en rax el puntero que quiero guardar en el campo data de la estructura
    ; me lo guardo en un registro no volátil
    mov r14, rax ; r14 = data

    ; Quiero llamar a calloc para reservar memoria para la estructura, cargo los parámetros:
    mov rdi, 1
    mov rsi, 16
    call calloc
    ; ahora tengo en rax el puntero a la estructura, osea lo que tengo que devolver 
    ; le asigno el valor correspondiente a capacity:
    mov byte [rax + OFFSET_CAPACITY], r15b
    mov qword [rax + OFFSET_DATA], r14

    ; epílogo 
    pop r15 
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

; Signatura de la función:
; uint8_t  strArrayGetSize(str_array_t* a)

; Mapeo de parámetros a registros
; rdi[a]

; Idea de la implementación:
; Me traigo el campo size de la estructura
strArrayGetSize:
    ; prólogo
    push rbp
    mov rbp, rsp

    ; cuerpo
    xor rax, rax ; limpio rax
    mov al, [rdi + OFFSET_SIZE]

    ; epílogo
    pop rbp
    ret 

; Signatura de la función:
; void  strArrayAddLast(str_array_t* a, char* data)

; Mapeo de parámetros a registros
; rdi[a], rsi[data]

; Idea de la implementación:
; Primero tengo que chequear que size sea menor a capacity,
; en el caso de que sea menor a capactity, tengo que sumarle a data 8*size para saber en qué posición agregar el arreglo
strArrayAddLast:
    ; prólogo
    push rbp 
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    ; cuerpo
    ; Primero me guardo los parámetros originales de la función en registros no volátiles, para no perderlos al llamar funciones
    mov r15, rdi ; r15 = a
    mov r14, rsi ; r14 = data

    ; Veo si size < capacity
    mov r10b, [r15 + OFFSET_SIZE]     ; r10b = str_array.size
    mov r11b, [r15 + OFFSET_CAPACITY] ; r11b = str_array.capacity
    cmp r10b, r11b
    jge .fin

    ; Tengo que hacerme una copia del string, entonces quiero usar char* strClone(char* a);
    ; me cargo los parámetros:
    mov rdi, r14 ; rdi = data
    call strClone
    ; ahora tengo en rax el string que debo guardar
    mov r13, [r15 + OFFSET_DATA] ; r15 = str_array.data
    mov r12, 8
    xor r11, r11
    mov r11b, [r15 + OFFSET_SIZE]
    imul r12, r11
    add r13, r12
    mov qword [r13], rax

    .fin
    ; epílogo
    pop r15
    pop r14
    pop r13
    pop r12 
    pop rbp
    ret


; void  strArraySwap(str_array_t* a, uint8_t i, uint8_t j)
strArraySwap:


; void  strArrayDelete(str_array_t* a)
strArrayDelete:


