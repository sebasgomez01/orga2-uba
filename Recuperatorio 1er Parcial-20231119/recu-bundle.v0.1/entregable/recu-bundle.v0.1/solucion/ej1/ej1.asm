global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm
extern calloc
extern strcmp
extern pagosAComerciosEnBlacklist


section .data
OFFSET_APROBADO equ 17
OFFSET_CLIENTE equ 16
OFFSET_MONTO equ 0
OFFSET_COMERCIO equ 8 
PAGO_STRUCT_SIZE equ 24

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Signatura de la función 
; uint32_t* acumuladoPorCliente_asm(uint8_t cantidadDePagos, pago_t* arr_pagos);
; Mapeo de parámetros a registros:
; rdi[cantidadDePagos], rsi[arr_pagos]

; Idea de la resolución: 
; Primero tengo que reservar memoria para el arreglo de uint32_t que quiero devolver
; Para esto tengo que llamar a malloc o a calloc
; Voy usar calloc ya que me inicaliza todas las posiciones en 0, y como quiero usarlas de contador, messirve
; La aridad de calloc es:
; void *calloc(size_t num_items, size_t item_size);
; Quiero llamarla con los valores num_items = 10 y item_size = 4

; Luego lo que tengo que hacer es ir recorriendo el array de pagos y chequear que el pago haya sido aprobado,
; si el pago fue aprobado me fijo el número de cliente e incremento en 1 la posición del arreglo correspondiente
; en caso de que el pago no fue aprobado, salto a la siguiente pago

acumuladoPorCliente_asm:
	; prólogo
	push rbp
	mov rbp, rsp
	push r15
	push r14 
	push r13 
	push r12


	; cuerpo
	mov r12, rdi ; me guardo en r12, un registro no volátil, cantidadDePagos
	mov r13, rsi ; me guardo en r13, un registro no volátil, arr_pagos
	mov rdi, 10  ; me guardo en rd1 la cantidad de elemento del arreglo
	mov rsi, 4   ; me guardo en rsi el tamaño de cada elemento del arreglo en bytes, 32 bits = 4 bytes
	call calloc  ; llamo a calloc, me va a devolver en rax el puntero al bloque de memoria reservada
	mov r14, rax ; me guardo en r14, un registro no volátil, el puntero al bloque de memoria reservada

	mov rcx, r12
	.bucle:
		mov r10b, byte [r13 + OFFSET_APROBADO] ; me guardo en r10b el booleano aprobado                       
		mov r9b, 0                             ; me guardo en r9b un 0, para chequear si el pago está aprobado
		cmp r10b, r9b					
		je .incrementar_contador 			   ; si el pago no está aprobado salto a incrementar_contador

		; Si el pago está aprobado quiero ver qué número de cliente es y sumar el monto el la posición
		; correspondiente del arreglo, la cual es  [r14 + cliente * 4]
		xor r10, r10
		xor r9, r9
		mov r10b, byte [r13 + OFFSET_CLIENTE] ; me guardo el número de cliente en r10b
		mov r9b, byte [r13 + OFFSET_MONTO]    ; me guardo el monto en r9b
		add byte [r14 + r10*4], r9b

		.incrementar_contador:
			add r13, 24  ; paso al siguiente pago
			loop .bucle


	.fin:
	mov rax, r14

	; epílogo
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbp

	ret



; Signatura de la función:
; uint8_t en_blacklist_asm(char* comercio, char** lista_comercios, uint8_t n);
; Mapeo de parámetros a registros:
; rdi[comecio], rsi[lista_comercios], rdx[n]

; Idea de la implementación:
; Tengo que comprar el nombre de comercio con cada uno de los elementos de la lista 
; en el caso de que coincidan simplemente tengo que devolver 1 en rax
; si no coincide ninguno devuelvo 0 en rax

en_blacklist_asm:
	; prólogo
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15

	; cuerpo
	mov r15, rdi   ; me guardo en r15 el nombre del comercio
	mov r14, rsi   ; me guardo en r14 lista_comercios
	mov r13, rdx   ; me guardo en r14 la longitud de lista_comercios

	.bucle:
		mov rdi, r15 ; cargo en rdi el puntero al nombre del comercio
		mov rsi, r14 ; cargo en rsi el elemento de la lista lista_comericios
		call strcmp    ; llamo strcmp, me va a devolver 0 si en rax si los strings son iguales
		test rax, rax 
		jz .aparece_en_la_lista
		sub r13, 1
		test r13, r13
		jz .no_aparece_en_la_lista

		.avanzar_string:
			inc r14
			mov r12b, [r14]  ; me traigo un char
			test r12b, r12b  ; chequeo si el char es cero, esto me indica que termino la palabra
 			jnz .avanzar_string
 			inc r14
 			jmp .bucle

		.aparece_en_la_lista:
			mov rax, 1
			jmp .fin

		.no_aparece_en_la_lista:
			mov rax, 0

	.fin:
	; epílogo
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp

	ret



; Signatura de la función:
; pago_t** blacklistComercios(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios){}

; Mapeo de parámetros a registros:
; rdi[cantidad_pagos], rsi[arr_pagos], rdx[arr_comercios], rcx[size_comercios]

; Idea de la implementación:
; Lo primero que tengo que hacer es reservar memoria para el arreglo de pagos, para esto necesito saber
; cuántos pagos del arreglo arr_pagos son de comercios pertenecientes a arr_comercios
; Osea tengo que ir recorriendo la lista de pagos, agarrando el campo comercio,
; y aplicarle en_blacklist_asm(comercio, arr_comercios, size_comercios)  


blacklistComercios_asm:
	; prólogo
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8

	; cuerpo
	; Primero me guardo una copia de los parámetros de la función original en registros no volátiles
	mov r15, rdi ; cantidad_pagos
	mov r14, rsi ; arr_pagos
	mov r13, rdx ; arr_comercios
	mov r12, rcx ; size_comercios

	; Llamo a la función uint8_t pagosAComerciosEnBlacklist(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios);
	; que recibe los mismos parámetros que la original
	call pagosAComerciosEnBlacklist
	; Ahora tengo en rax la cantidad de pagos que corresponden a comercios en Blacklist
	; Llamo a calloc para reservar memoria
	;  void *calloc(size_t num_items, size_t item_size);

	mov rdi, rax 				; rdi = #pagosAComerciosEnBlacklist
	mov rsi, 8 ; rsi = 8 (tamaño del puntero al struct pago en bytes) 
	call calloc 
	; Ahora tengo en rax el puntero a la dirección de memoria reservada
	; me lo guardo en un registro no volátil
	mov rbx, rax
	push rbx ; esto después lo voy a popear en rax
	sub rsp, 8 ; dejé desalineada la pila con el push anterior, vuelvo a alinearla

	; ¿qué informacíón necesito tener al hacer el loop?
	; 1) Necesito tener un contador de pagos para iterar(r15)
	; 2) Necesito tener un puntero a la posición del arreglo en la cual guardar el siguiente pago (rbx)
	; 3) Necesito tener el puntero al nombre del comercio, esto cambia en cada iteración, no necesito un no volátil
	; 4) Necesito tener el puntero al arreglo de comercios   (r13)
	; 5) Necesito tener la longitud del arreglo de comercios (r12)
	; 6) Necesito un puntero a la posición actual de arr_pagos (r14)
 
	.bucle:
		mov r10b, [r14 + OFFSET_APROBADO] ; r10b = pago.aprobado
		cmp r10b, 0
		je .loopear
		mov rdi, [r14 + OFFSET_COMERCIO] ; rdi = pago.comercio 
		mov rsi, r13                     ; rsi = arr_comercios
		mov rdx, r12                     ; rdx = size_comercios
		call en_blacklist_asm
		; ahora tengo en rax 1 si el pago pertenece a la lista y cero si no
		cmp rax, 0
		je .loopear
		mov qword [rbx], r14 
		add rbx, 8

		.loopear:
			add r14, 3 ; paso al siguiente pago de arr_pagos      
			dec r15
			test r15, r15
			jz .fin
			jmp .bucle


	.fin:
	add rsp, 8
	pop rax
	; epílogo
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
