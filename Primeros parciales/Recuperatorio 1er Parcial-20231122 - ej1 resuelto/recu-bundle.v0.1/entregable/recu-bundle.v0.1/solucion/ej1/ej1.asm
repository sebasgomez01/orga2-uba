global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm

extern calloc
extern strcmp

section .data

%define OFFSET_MONTO 0
%define OFFSET_COMERCIO 8
%define OFFSET_CLIENTE 16
%define OFFSET_APROBADO 17

;########### SECCION DE TEXTO (PROGRAMA)
section .text


; Signatura de la función:
; uint32_t* acumuladoPorCliente_asm(uint8_t cantidadDePagos, pago_t* arr_pagos);

; Mapeo de parámetros a registros:
; rdi[cantidadDePagos], rsi[arr_pagos]

; Idea de la implementación:
; Primero tengo que reservar memoria para el arreglo a devolver, este tiene 10 elementos y cada elemento tiene 32 bits (4 bytes)
; Entonces tengo que llamar calloc(cantElem = 010, sizeElem = 4);
; Una vez reservada reservada la memoria tengo que recorrer arr_pagos, traerme el booleano aprobado
; Si el pago está aprobado, me fijo a qué cliente corresponde y lo guardo en la posición del arreglo correspondiente
; Si el pago no está aprobado, paso al siguiente pago

acumuladoPorCliente_asm:
	; prólogo
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15

	; cuerpo
	; Primero me guardo los parámetros originales de la función en registros no volátiles, para no perderlos al llamar a calloc  
	mov r15, rdi ; r15 = cantidadDePagos
	mov r14, rsi ; r14 = arr_pagos
	; Me cargo los parámetros para calloc
	mov rdi, 10 
	mov rsi, 4
	call calloc
	; Ahora tengo en rax el puntero al inicio del bloque de memoria reservado, me lo guardo en un registro no volátil
	mov r13, rax 

	mov rcx, r15 ; inicializo el contador 

	.bucle:
		xor r10, r10 ; limpio r10
		xor r9, r9   ; limpio r9
		mov r13, rax ; me cargo en r13 el puntero al inicio del arreglo
		mov r10b, [r14 + OFFSET_APROBADO] ; r10b = pago.aprobado
		cmp r10b, 0 ; chequeo si el pago fue aprobado
		je .avanzar_pago
		
		; Si el pago fue aprobado, quiero ver el número de cliente para saber en qué posición del arreglo sumarl, y quiero obtener el monto
		mov r9b, [r14 + OFFSET_MONTO]     ; r9b = pago.monto
		mov r10b, [r14 + OFFSET_CLIENTE]  ; r10b = pago.cliente

		; Quiero sumar el pago en la posición 4*cliente del arreglo
		shl r10b, 2 ; r10b = r10b * 4
		add r13, r10
		add dword [r13], r9d

		.avanzar_pago:
			add r14, 24 ; avanzo al siguiente pago

		loop .bucle

	; epílogo
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret


; Signatura de la función
; uint8_t en_blacklist_asm(char* comercio, char** lista_comercios, uint8_t n);

; Mapeo de parámetros a registros:
; rdi[comercio], rsi[lista_comercios], rdx[n]

; Idea de la implementación
; Uso la función strcmp(comercio, lista_comercios), en el caso de que el valor de retorno sea 0, que quiere decir que ambos strings coinciden
; me cargo 1 en rax y retorno
; en el caso de que el valor de retorno sea distinto de cero, sigo iterando hasta encontrar uno que coincida o terminar el arreglo
; si termino de iterar a través del arreglo y ninguno coincide, devuelvo 0
en_blacklist_asm:
	; prólogo
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15

	; cuerpo 
	; Primero me guardo los parámetros originales de la función en registros no volátiles, pues voy a llamar otras funciones
	mov r15, rdi ; r15 = comercio
	mov r14, rsi ; r14 = lista_comercios
	mov r13, rdx ; r13 = n

	; voy a usar r13 como el contador del bucle 
	cmp r13, 0
	je .fin

	.bucle: 
		; Quiero llamar a strcmp, me cargo los parámetros:
		mov rdi, r15 ; rdi = comercio
		mov rsi, [r14] ; rsi = elemento de lista comercios (un puntero a string) 

	 	; ---------------------------------------------------------------------------------------------------------------------------------------------------------
		; ¡¡¡MUY IMPORTANTE!!! 
		; EL ERROR ESTABA EN LA LÍNEA 118, YO ESTABA HACIENDO:
		; mov rsi, r14 ; COMO R14 ERA DE TIṔO char**. entonces estaba haciendo strcmp(char*, char**)
		; POR LO TANTO ESTABA HACIENDO CUALQUIER COSA 
		; COMO r14 ES DE TIPO char**. ENTONCES [r14] ES DE TIPO char*, y ahí sí tipa correcto
		; ¡¡¡¡¡¡¡TENERLO EN CUENTA EN EL PARCIAL, CUANDO TENGAS UN char**!!!!!!!
		; ----------------------------------------------------------------------------------------------------------------------------------------------------------

		call strcmp
		; Ahora tengo en rax 0 si los string coinciden
		cmp rax, 0 
		je .nombre_coinciden
		mov rax, 0 ; si el nombre del comercio no coincide me pongo un 0 en rax

		.avanzar_comercio:
			dec r13 
			cmp r13, 0
			je .fin
			add r14, 8 ; avanzo al siguiente comercio en la lista
			jmp .bucle

		.nombre_coinciden:
			mov rax, 1 ; me cargo en rax 1, pues el comercio está en la lista

	.fin:
	; epílogo
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret


; Signatura de la función:
; pago_t** blacklistComercios_asm(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios); 

; Mapeo de parámetros a registros
; rdi[cantidad_pagos], rsi[arr_pagos], rdx[arr_comercios], rcx[size_comericios]

; Idea de la implementación
; Primero tengo que reservar un bloque de memoria para el arreglo de pagos, donde cada elemento va a tener 8 bytes, pues son punteros
; Para saber cuántos elementos son, lo que tengo que hacer es recorrer el arreglo de pagos, y para cada pago: 
; Traerme el valor de comercio, usar la función en_blacklist_asm(char* comercio, char** lista_comercios, uint8_t n);
; Esta función me va a devolver 1 en rax si el comercio se encuentra en la lista, y cero en caso contrario
; Entonces una vez que apliqué esta función en el valor comercio de cada pago, ya se cuánta memoria tengo que reservar

blacklistComercios_asm:
	; prólogo
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8 ; para mantener alineada la pila, pues voy a llamar funciones dentro

	; cuerpo
	; Primero me guardo los parámetros originales en la pila, pues voy a necesitar los registros no volátiles para guardar otras cosas
	mov r15, rdi ; r15 = cantidad_pagos
	mov r14, rsi ; r14 = arr_pagos
	mov r13, rdx ; r13 = arr_comercios
	mov r12, rcx ; r12 = size_comercios
	mov rbx, 0   ; rbx = 0, voy a usar rbx como contador de pagos cuyos comercios pertenecen a 

	push r15
	push r14 
	push r13 
	push r12
	; La pila se mantiene alineada
	; voy a usar r15 como contador para recorrer el arr_pagos

	; chequeo si la lista de pagos no es vacía
	cmp r15, 0 
	je .fin_memoria_a_reservar

	.memoria_a_reservar:
		; Quiero llamar a la función: en_blacklist_asm(char* comercio, char** lista_comercios, uint8_t n); para cada pago de arr_pagos
		; Primero me tengo que traer el campo comercio del struct pago:
		mov rdi, [r14 + OFFSET_COMERCIO] ; rdi = pago.comercio
		; cargo los otros parámetros:
		mov rsi, r13 ; rsi = arr_comercios
		mov rdx, r12 ; rdx = size_comercios
		call en_blacklist_asm
		; Ahora tengo en rax 1 si el comercio se encuentra en arr_comercios y 0 en el caso contrario, lo sumo al contador:
		add rbx, rax
		add r14, 24 ; avanzo al siguiente pago de la lista
		dec r15 
		cmp r15, 0 
		je .fin_memoria_a_reservar
		jmp .memoria_a_reservar

	.fin_memoria_a_reservar:

	; Restituyo en los registros no volátiles el valor de los parámetros originales de la función
	pop r12
	pop r13
	pop r14
	pop r15

	; Se supone que ahora en rbx tengo la cantidad de pagos de arr_pagos que pertenecen a algún comercio de arr_comecios 
	; Así que reservo memoria para el arreglo de punteros a pagos, llamo a calloc(cantElems = rbx, sizeElems = 8)
	mov rdi, rbx 
	mov rsi, 8
	call calloc
	; Ahora tengo en rax el puntero al bloque de memoria reservado
	; Me lo guardo en un registro no volátil
	mov rbx, rax

	; Ahora lo que quiero hacer es recorrer la lista de pagos, y si el pago pertenece a alguno de los comercios, guardar su puntero en el arreglo a devolver
	; ¿qué tengo en cada registro no volátil?
	; rbx = puntero a la dirección de memoria reservada
	; r12 = size_comercios
	; r13 = arr_comercios
	; r14 = arr_pagos
	; r15 = cantidad_pagos

	push rbx ; esto después lo voy a popear en rax, pues es lo que tengo que devolver
	; y necesito poder incrementar rbx para moverme a través de las posiciones de la lista

	; chequeo si el arreglo de pagos no está vacío
	cmp r15, 0
	je .fin

	.guardar_pagos: 
		xor rax, rax ; limpio rax
		; Quiero llamar a la función: en_blacklist_asm(char* comercio, char** lista_comercios, uint8_t n); para cada pago de arr_pagos
		; Primero me tengo que traer el campo comercio del struct pago:
		mov rdi, [r14 + OFFSET_COMERCIO] ; rdi = pago.comercio
		; cargo los otros parámetros:
		mov rsi, r13 ; rsi = arr_comercios
		mov rdx, r12 ; rdx = size_comercios
		call en_blacklist_asm
		; Ahora tengo en rax 1 si el comercio se encuentra en arr_comercios y 0 en el caso contrario
		cmp rax, 0
		je .avanzar_pago
		; Si rax = 1 entonces el comercio del pago pertenece a la lista arr_comercios, lo guardo en el arreglo a devolver
		mov qword [rbx], r14
		add rbx, 8 ; avanzo rbx para que apunte a la siguiente posición de la lista

		.avanzar_pago:
			add r14, 24 ; avanzo al siguiente pago de la lista
			dec r15 
			cmp r15, 0 
			je .fin
			jmp .guardar_pagos


	
	.fin: 
	pop rax 
	; epílogo
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret
