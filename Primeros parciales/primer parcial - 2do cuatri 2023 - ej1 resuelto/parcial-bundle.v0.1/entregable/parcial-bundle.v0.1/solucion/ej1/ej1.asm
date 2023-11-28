section .data

%define OFFSET_MONTO 0
%define OFFSET_APROBADO 1
%define OFFSET_PAGADOR 8
%define OFFSET_COBRADOR 16

%define OFFSET_DATA 0
%define OFFSET_NEXT 8
%define OFFSET_PREV 16

%define OFFSET_FIRST 0
%define OFFSET_LAST 8

%define OFFSET_CANT_APROBADOS 0
%define OFFSET_CANT_RECHAZADOS 1
%define OFFSET_APROBADOS 8
%define OFFSET_RECHAZADOS 16

section .text

global contar_pagos_aprobados_asm
global contar_pagos_rechazados_asm

global split_pagos_usuario_asm

extern malloc
extern calloc
extern free
extern strcmp




;########### SECCION DE TEXTO (PROGRAMA)

; Signatura de la función
; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
; Mapeo de parámetros a registros:
; rdi[pList], rsi[usuario]

contar_pagos_aprobados_asm:
	; prólogo
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15 

	; cuerpo
	; Primero me guardo los parámteros originales en registros no volátiles:
	mov r15, rdi   ; r15 = pList
	mov r14, rsi   ; r14 = usuario
	mov r13, [r15] ; r13 = pList->first

	cmp r13, 0     ; chequeo si es un puntero nulo
	je .fin

	mov r15, 0 ; inicializo el contador de pagos aprobados en r15, ya no necesito pList

	.bucle:
		mov r12, [r13] ; r12 = listElem.data
		cmp r12, 0 ; chequeo si el puntero es nulo ¿tiene sentido hacerlo?
		je .avanzar_nodo
		xor r11, r11                      ; limpio r11
		mov r11b, [r12 + OFFSET_APROBADO] ; r11b = pago.aprobado
		cmp r11b, 0
		je .avanzar_nodo
		mov rdi, [r12 + OFFSET_COBRADOR]  ; rdi = pago.cobrador
		mov rsi, r14                      ; rsi = usuario
		call strcmp
		cmp rax, 0
		jne .avanzar_nodo
		inc r15

		.avanzar_nodo:
		mov r13, [r13 + OFFSET_NEXT] ; me traigo el puntero next
		cmp r13, 0
		je .fin
		jmp .bucle

	.fin:
	mov rax, r15
	; epílogo
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);


contar_pagos_rechazados_asm:
; prólogo
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15 

	; cuerpo
	; Primero me guardo los parámteros originales en registros no volátiles:
	mov r15, rdi   ; r15 = pList
	mov r14, rsi   ; r14 = usuario
	mov r13, [r15] ; r13 = pList->first

	cmp r13, 0     ; chequeo si es un puntero nulo
	je .fin

	mov r15, 0 ; inicializo el contador de pagos desaprobados en r15, ya no necesito pList

	.bucle:
		mov r12, [r13] ; r12 = listElem.data
		cmp r12, 0 ; chequeo si el puntero es nulo ¿tiene sentido hacerlo?
		je .avanzar_nodo
		xor r11, r11                      ; limpio r11
		mov r11b, [r12 + OFFSET_APROBADO] ; r11b = pago.aprobado
		cmp r11b, 0
		jne .avanzar_nodo
		mov rdi, [r12 + OFFSET_COBRADOR]  ; rdi = pago.cobrador
		mov rsi, r14                      ; rsi = usuario
		call strcmp
		cmp rax, 0
		jne .avanzar_nodo
		inc r15

		.avanzar_nodo:
		mov r13, [r13 + OFFSET_NEXT] ; me traigo el puntero next
		cmp r13, 0
		je .fin
		jmp .bucle

	.fin:
	mov rax, r15
	; epílogo
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret






; Signatura de la función:
; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);

; Mapeo de parámetros a registros:
; rdi[pList], rsi[usuario]


split_pagos_usuario_asm:
	; prólogo
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8

	; cuerpo
	; Primero guardo los parámetros originales en registros no volátiles
	; para no perderlos en las llamadas a funciones que voy a hacer:
	mov r15, rdi ; r15 = pList
	mov r14, rsi ; r14 = usuario

	; Ahora llamo calloc para reservar la memoria para la estructura pagoSplitted
	; void *calloc(1, 24);
	mov rdi, 1
	mov rsi, 24
	call calloc  
	; Tengo en rax el puntero a la estructura, me lo guardo en un registro no volátil
	mov r13, rax 

	; Ahora quiero llamar a las funciones:
	; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
	; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);

	; Cargo los parámetros
	xor rax, rax ; limpio rax
	mov rdi, r15
	mov rsi, r14
	call contar_pagos_aprobados_asm
	; Ahora tengo en rax la cantidad de pagos aprobados del usuario 
	; Lo cargo en la estructura 
	mov byte [r13 + OFFSET_CANT_APROBADOS], al ; (al es el primer byte de rax)

	; Ahora pido memoria para el arreglo de aprobados con calloc
	mov rdi, rax ; me cargo la cantidad de pagos aprobados
	xor rax, rax ; limpio rax
	mov rsi, 8   ; me cargo el tamaño de cada puntero a un pago, que es 8 bytes
	call calloc
	; Ahora tengo en rax el puntero a la posicion de memoria reservada para el arreglo de aprobados
	; Lo guardo en la estructura:
	mov qword [r13 + OFFSET_APROBADOS], rax

	; Ahora llamo a uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario); 
	; cargo los parámetros:
	xor rax, rax ; limpio rax	
	mov rdi, r15
	mov rsi, r14
	call contar_pagos_rechazados_asm
	; Ahora tengo en rax la cantidad de pagos rechazados del usuario 
	; Lo cargo en la estructura 
	mov byte [r13 + OFFSET_CANT_RECHAZADOS], al ; (al es el primer byte de rax)

	; Ahora pido memoria para el arreglo de rechazados con calloc
	mov rdi, rax ; me cargo la cantidad de pagos rechazados
	xor rax, rax ; limpio rax
	mov rsi, 8   ; me cargo el tamaño de cada puntero a un pago, que es 8 bytes
	call calloc
	; Ahora tengo en rax el puntero a la posicion de memoria reservada para el arreglo de rechazados
	; Lo guardo en la estructura:
	mov qword [r13 + OFFSET_RECHAZADOS], rax

	; Recapitulando: ya reserve memoria para la estructura pagoSplitted y tengo el puntero en r13
	; Ya reserve memoria para el arreglo de aprobados y ya guarde el puntero en la estructura 
	; Ya reserve memoria para el arreglo de rechazados y ya guarde el puntero en la estructura
	; ¿Qué tiene cada registro?
	; r15 = pList, r14 = usuario, r13 = puntero a pagoSplitted
	; Ahora quiero ir recorriendo pList, chequear si el pago tiene a usuario como cobrador
	; y si ese es el caso, guardar el puntero al pago en el arreglo correspondiente

	; Como voy a llamar strcmp necesito ver qué información voy a mantener en registros
	; no volátiles durante el bucle:
	; Necesito tener usuario (r12) 
	; Necesito tener la primera posición libre del arreglo aprobados (para guardar el pago)  (r13)
	; Necesito tener la primera posición libre del arreglo rechazados (para guardar el pago) (r14) 
	; Necesito tener el puntero al nodo actual de la lista enlazada (r15)
	; Necesito tener el puntero a la estructura, para cargarlo al final en rax (rbx)
	mov r12, r14                        ; r12 = usuario
	mov rbx, r13                        ; rbx = puntero a pagoSplitted
	mov r15, [r15 + OFFSET_FIRST]       ; r15 = pList.first (me guardo en r15 el puntero al primer nodo)
	mov r14, [r13 + OFFSET_RECHAZADOS]  ; r14 = pagoSplitted.rechazados
	mov r13, [r13 + OFFSET_APROBADOS]   ; r13 = pagoSplitted.aprobados

	cmp r15, 0     ; chequeo si es un puntero nulo
	je .fin_split

	.bucle_split:
		mov r11, [r15 + OFFSET_DATA] ; r11 = listElem.data
		cmp r11, 0 ; chequeo si el puntero es nulo ¿tiene sentido hacerlo?
		je .avanzar_nodo_split
		
		mov rdi, [r11 + OFFSET_COBRADOR] ; rdi = pago.cobrador
		mov rsi, r12                     ; rsi = usuario
		call strcmp
		; strcmp me devuelve 0 en rax en el caso de que usuario coincida con cobrador
		cmp rax, 0
		jne .avanzar_nodo_split
		; Si usuario == cobrador, entonces quiero ver si el pago es aprobado o rechazado

		xor r11, r11 						 ; limpio r11
		mov r11, [r15 + OFFSET_DATA]
		mov r11b, [r11 + OFFSET_APROBADO]    ; r11b = pago.aprobado
		cmp r11b, 0 
		je .pago_rechazado

		mov r10, [r15 + OFFSET_DATA]  ; r10 = puntero al pago actual
		mov qword [r13], r10 				  ; me guardo el puntero en pagoSplitted.aprobados
		add r13, 8                    ; avanzo a la siguiente posición del arreglo
		jmp .avanzar_nodo_split

		.pago_rechazado:
			mov r10, [r15 + OFFSET_DATA]  ; r10 = puntero al pago actual
			mov [r14], r10                ; me guardo el puntero en pagoSplitted.rechazados
			add r14, 8                    ; avanzo a la siguiente posición del arreglo

		.avanzar_nodo_split:
			mov r15, [r15 + OFFSET_NEXT] ; me traigo el puntero next
			cmp r15, 0
			je .fin_split
			jmp .bucle_split

	.fin_split:	
	mov rax, rbx
	; epílogo
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret 

; Idea de la implementación:
; Primero tengo que reservar memoria para la estructura pagoSplitted
; esto es llamar void *calloc(size_t num_items, size_t item_size);
; void *calloc(1, 24);
; Luego tengo que usar las funciones del punto (a) para saber cuánta memoria 
; reservar para cada arreglo: aprobados y rechazados
