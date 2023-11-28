global templosClasicos
global cuantosTemplosClasicos
extern calloc
extern malloc

; La relación entre la cantidad de columnas es 2N+1=M, con M el lado largo y N el lado corto
; Entonces M = 2N + 1, y N = (M - 1)/2
section .data

%define STRUCT_TEMPLO_SIZE 24
%define OFFSET_COLUM_LARGO 0
%define NOMBRE 8
%define OFFSET_COLUM_CORTO 16

;########### SECCION DE TEXTO (PROGRAMA)
section .text


; Signatura de la función:
; uint32_t cuantosTemplosClasicos(templo *temploArr, size_t temploArr_len);

; Mapeo de parámetros a registros: 
; rdi[temploArr], rsi[temploArr_len]

; Idea de la implementación:
; Lo que tengo que hacer es agarrar el templo, calcular la cantidad de columnas largo y ancho y comparar
; Como no voy a llamar ninguna función en el mdeio no me interesa lo de los registros no volátiles

cuantosTemplosClasicos:
	; prólogo 
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15

	; cuerpo
	mov r15, rdi
	mov r14, rsi
	 
	xor rax, rax ; limpio rax
	mov rcx, rsi
	.bucle:
		mov r12, [r15 + OFFSET_COLUM_LARGO] ; r12 = colum_largo
		mov r13, [r15 + OFFSET_COLUM_CORTO] ; r13 = colum_corto = N
		shl r13, 1                          ; r13 = 2*colum_corto = 2*N
		inc r13                             ; r13 = 2*colum_corto + 1 = 2*N + 1		
		cmp r12, r13                        ; chequeo si cumple que M = 2*N + 1
		jne .avanzar_templo			        ; ERROR EN ESTA LÍNEA ¿¿POR QUÉ??
		;mov r12, [r15 + OFFSET_COLUM_LARGO] ; r12 = colum_largo = M
		;mov r13, [r15 + OFFSET_COLUM_CORTO] ; r13 = colum_corto = N
		;dec r12                             ; r12 = colum_largo - 1 = M - 1		
		;shr r12, 1                          ; r12 = (colum_largo - 1)/2 = (M - 1)/2
		;cmp r12, r13
		;jne .avanzar_templo
		inc rax

		.avanzar_templo:
			add r15, 24 ; avanzo al siguiente templo de la lista
		loop .bucle

	; epílogo
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret 

; Signatura de la función:
; templo* templosClasicos(templo *temploArr, size_t temploArr_len);

; Mapeo de parámetros a registros:
; rdi[temploArr], rsi[temploArr_len]

; Idea de la implementación:
; Primero tengo que pedir memoria para el arreglo de templos clásicos,
; Para esto necesito usar la función del ítem a para saber cuántos templos de la lista son clásicos
; y así llamo calloc(#templosClásicos, size_struct_templo = 24 bytes)

templosClasicos:
	; prólogo 
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15

	; cuerpo
	; Primero me guardo los parámetros originales en registros no volátiles, para no perderlos al llamar calloc
	mov r15, rdi ; r15 = temploArr
	mov r14, rsi ; r14 = temploArr_len

	; quiero llamar la función:
	; uint32_t cuantosTemplosClasicos(templo *temploArr, size_t temploArr_len);
	; que recibe los mismos parámetros que la original, por lo tanto ya se encuentran cargados en rdi y rsi

	call cuantosTemplosClasicos
	; ahora tengo en rax la cantidad de templos clásicos de la lista
	; quiero llamar calloc(#templosClásicos, size_pointer_struct_templo = 8 bytes)
	; cargo los parámetros
	mov rdi, rax ; rdi = #templosClásicos
	mov rsi, 24  ; rsi = 24
	call calloc  ; LA PRIMERA VEZ QUE LLAMO A CALLOC EL PROGRAMA TERMINA ¿¿¿POR QUÉ???
	; ahora tengo en rax el puntero al inicio del bloque de memoria reservada
	; me guardo una copia en r10 para poder avanzar cuando tengo que ir guardando los templos
	mov r10, rax

	mov rcx, r14 ; rcx = temploArr_len
	cmp rcx, 0
	je .fin
	.bucle:
		mov r12, [r15 + OFFSET_COLUM_LARGO] ; r12 = colum_largo
		mov r13, [r15 + OFFSET_COLUM_CORTO] ; r13 = colum_corto = N
		shl r13, 1                          ; r13 = 2*colum_corto = 2*N
		inc r13                             ; r13 = 2*colum_corto + 1 = 2*N + 1		
		cmp r12, r13                        ; chequeo si cumple que M = 2*N + 1
		jne .avanzar_templo                 ; ERROR EN ESTA LÍNEA ¿¿POR QUÉ?? 

		mov r9, 3
		.guardar_templo:
			mov r8, [r15]
			mov [r10], r8
			add r10, 8
			add r15, 8
			dec r9
			cmp r9, 0
			jne .guardar_templo
			dec rcx
			cmp rcx, 0
			je .fin
			jmp .bucle

		.avanzar_templo:
			add r15, 24 ; avanzo al siguiente templo de la lista
			dec rcx
			cmp rcx, 0
			je .fin
			jmp .bucle
		loop .bucle

	.fin:
	; epílogo
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret


