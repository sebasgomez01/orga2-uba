section .text

global contar_pagos_aprobados_asm
global contar_pagos_rechazados_asm
global split_pagos_usuario_asm

extern malloc
extern free
extern strcmp
extern contar_pagos_aprobados
extern contar_pagos_rechazados

%define OFFSET_MONTO 0
%define OFFSET_APROBADO 1 
%define OFFSET_PAGADOR 8
%define OFFSET_COBRADOR 16

%define OFFSET_DATA 0
%define OFFSET_NEXT 8
%define OFFSET_LAST 16

%define OFFSET_FIRST 0
%define OFFSET_LAST 8

%define OFFSET_CANT_APROBADOS 0
%define OFFSET_CANT_RECHAZADOS 1
%define OFFSET_APROBADOS 8
%define OFFSET_RECHAZADOS 16


;########### SECCION DE TEXTO (PROGRAMA)


; Signatura de la función:
; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
; Mapeo de parámetros a registros:
; pList[rdi], usuario[rsi]

; La idea es chequear si un pago está aprobado, en ese caso chequear que usuario sea igual a cobrador
; y si ambas condiciones se cumplen, incrementar en uno rax para contar el pago

contar_pagos_aprobados_asm:
	; prólogo
	push rbp
	mov rbp, rsp

	; cuerpo
	xor rax, rax         					; pongo rax en 0 para guardar el resultado a devolver
	mov rdx, [rdi]       					; me guardo en rdx el puntero al primer nodo de la lista
	cmp rdx, 0                              ; comparo el puntero al nodo actual con el puntero al último elemento
	je fin

	loop_start:
	mov rcx, [rdx]       					; me guardo en rcx el puntero al pago
	mov r9b, BYTE [rcx + OFFSET_APROBADO]   ; me guardo en r9b el valor de aprobado del struct pago
	cmp r9b, 0 								; comparo aprobado con cero
	je avanzar_nodo  						; si son iguales salto a avanzar_nodo, pues el pago no está aprobado

	; en el caso de que el pago esté aprobado, quiero chequear si el cobrador es igual al usuario
	mov r10, [rcx + OFFSET_COBRADOR]        ; me guardo en r10 el puntero al cobrador
	cmp r10, rsi                            ; comparo el puntero al usuario con el puntero al cobrador
	jne avanzar_nodo						; si no son iguales, salto a avanzar_nodo
	inc rax 								; si son iguales, incremento el contador de pagos aprobados

	avanzar_nodo:
	mov r8, [rdx + OFFSET_NEXT]             ; me guardo en r8 el puntero al siguiente nodo
	mov rdx, r8                             ; me guardo en rdx el puntero al siguiente nodo
	cmp rdx, 0 					            ; comparo el puntero al nodo actual con el puntero al último elemento
	je fin   								; si son iguales, estoy en el último nodo de la lista, entonces salto a fin
	jmp loop_start 							; salto a loop_start para seguir iterando

	fin:
	; epílogo
	pop rbp
	ret


; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);


contar_pagos_rechazados_asm:
	; prólogo
	push rbp
	mov rbp, rsp

	; cuerpo
	xor rax, rax         					; pongo rax en 0 para guardar el resultado a devolver
	mov rdx, [rdi]       					; me guardo en rdx el puntero al primer nodo de la lista
	cmp rdx, 0                              ; comparo el puntero al nodo actual con el puntero al último elemento
	je fin_d

	loop_start_d:
	mov rcx, [rdx]       					; me guardo en rcx el puntero al pago
	mov r9b, BYTE [rcx + OFFSET_APROBADO]   ; me guardo en r9b el valor de aprobado del struct pago
	cmp r9b, 0 								; comparo aprobado con cero
	jne avanzar_nodo_d  					; si no son iguales salto a avanzar_nodo_d, pues el pago está aprobado

	; en el caso de que el pago esté desaprobado, quiero chequear si el cobrador es igual al usuario
	mov r10, [rcx + OFFSET_COBRADOR]        ; me guardo en r10 el puntero al cobrador
	cmp r10, rsi                            ; comparo el puntero al usuario con el puntero al cobrador
	jne avanzar_nodo_d						; si no son iguales, salto a avanzar_nodo_d
	inc rax 								; si son iguales, incremento el contador de pagos desaprobados

	avanzar_nodo_d:
	mov r8, [rdx + OFFSET_NEXT]             ; me guardo en r8 el puntero al siguiente nodo
	mov rdx, r8                             ; me guardo en rdx el puntero al siguiente nodo
	cmp rdx, 0 					            ; chequeo que el puntero no sea nulo
	je fin_d   								; si es nulo, estoy en el último nodo de la lista, entonces salto a fin
	jmp loop_start_d 						; si no es nulo, salto a loop_start para seguir iterando

	fin_d:
	; epílogo
	pop rbp
	ret


; Signatura de la función:
; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);
; Mapeo de parámetros a registros: 
; pList[rdi], usuario[rsi]

; IDEA: primero llamar a las funciones para obtener la cantidad de pagos rechazados y aprobados 
; y guardar dichos resultados, luego llamar malloc para reservar memoria para el array de aprobados 
; y desaprobados utilizando la información obtenida en las funciones (la cantidad de cada uno),
; por último iterar a través de la lista de pagos, chequear si está aprobado/desaprobado
; y si pertenece al usuario en cuestión, en tal caso guardarlo en el array correspondiente

split_pagos_usuario_asm:
	; prólogo
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15

	; cuerpo
	; Primero tengo que reservar memoria para el struct pagoSplitted_t que ocupa 24 bytes 

	; me guardo los parámtros originales de la función, pues necesito rdi y rsi para hacer calls
	mov r15, rdi 
	mov r14, rsi 

	mov rdi, 24  ; guardo en rdi la cantidad de bytes a reservar
	call malloc  ; llamo a la función malloc, me devuelve en rax el puntero a la posición de memoria reservada
	mov r13, rax ; me guardo en r13 el valor de rax, pues voy a llamar 2 funciones más y perder el resultado 

	; Ahora tengo que llamar a uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
	mov rdi, r15
	call contar_pagos_aprobados
	; ahora tengo en rax la cantidad de pagos aprobados
	mov byte [r13], al ; me lo guardo en la posición correspondiente de pagoSplitted

	; Tengo que reservar memoria para los pagos aprobados:
	mov rdi, 8     ; guardo en rdi el valor 8
	mul rdi        ; multiplico cantidad_pagos_aprobados * 8 y guardo el resultado en rax 
	mov rdi, rax   ; guardo en rdi la cantidad de bytes a reservar
	call malloc    ; llamo a malloc, me devuelve en rax el puntero a la memoria reservada
	mov qword [r13 + OFFSET_APROBADOS], rax ; me guardo el puntero en la posición correspondiente en el struct

	; Ahora llamo a uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);
	mov rdi, r15
	mov rsi, r14
	call contar_pagos_rechazados
	; ahora tengo en rax la cantidad de pagos rechazados
	mov byte [r13 + OFFSET_CANT_RECHAZADOS], al ; me lo guardo en la posición correspondiente de pagoSplitted 

	; Tengo que reservar memoria para los pagos rechazados
	mov rdi, 8     ; guardo en rdi el valor 8
	mul rdi        ; multiplico cantidad_pagos_aprobados * 8 y guardo el resultado en rax 
	mov rdi, rax   ; guardo en rdi la cantidad de bytes a reservar
	call malloc    ; llamo a malloc, me devuelve en rax el puntero a la memoria reservada
	mov qword [r13 + OFFSET_RECHAZADOS], rax ; me guardo el puntero en la posición correspondiente en el struct

	; Ahora ya tengo reservada la memoria necesaria, tengo que iterar a través de los pagos, y de acuerdo
	; a si están aprobados ó rechazados y si pertenecen al usuario, ir guardándolos

	; Vuelvo a guardar los parámetros originales en rdi, rsi
	mov rdi, r15
	mov rsi, r14

	; Me guardo en r12 el puntero a aprobados y en r11 el puntero a rechazados
	mov r12, [r13 + OFFSET_APROBADOS]
	mov r11, [r13 + OFFSET_RECHAZADOS]

	mov rdx, [rdi]       					; me guardo en rdx el puntero al primer nodo de la lista
	cmp rdx, 0                              ; comparo el puntero al nodo actual con el puntero al último elemento
	je fin_split

	loop_start_split:
	mov rcx, [rdx]       					; me guardo en rcx el puntero al pago

	; chequeo si el usuario es el cobrador, si no lo es salto al siguiente nodo
	mov r10, [rcx + OFFSET_COBRADOR]        ; me guardo en r10 el puntero al cobrador
	cmp r10, rsi                            ; comparo el puntero al usuario con el puntero al cobrador
	jne avanzar_nodo_split					; si no son iguales, salto a avanzar_nodo_split
	
	mov r9b, BYTE [rcx + OFFSET_APROBADO]   ; me guardo en r9b el valor de aprobado del struct pago
	cmp r9b, 0 								; comparo aprobado con cero
	je pago_desaprobado  					; si son iguales salto a pago_desaprobado, pues el pago no está aprobado
	jne pago_aprobado

	pago_desaprobado:
	mov [r11], rcx   ; me guardo el pago rechazado
	add r11, 8       ; le sumo 8 bytes al puntero para que apunte a la siguiente posición del array
	jmp avanzar_nodo_split

	pago_aprobado:
	mov [r12], rcx   ; me guardo el pago aprobado
	add r12, 8       ; le sumo 8 bytes al puntero para que apunte a la siguiente posición del array

	avanzar_nodo_split:
	mov r8, [rdx + OFFSET_NEXT]             ; me guardo en r8 el puntero al siguiente nodo
	mov rdx, r8                             ; me guardo en rdx el puntero al siguiente nodo
	cmp rdx, 0 					            ; comparo el puntero al nodo actual con el puntero al último elemento
	je fin_split  							; si son iguales, estoy en el último nodo de la lista, entonces salto a fin
	jmp loop_start_split 					; salto a loop_start para seguir iterando

	fin_split:
	mov rax, r13
	; epílogo
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

