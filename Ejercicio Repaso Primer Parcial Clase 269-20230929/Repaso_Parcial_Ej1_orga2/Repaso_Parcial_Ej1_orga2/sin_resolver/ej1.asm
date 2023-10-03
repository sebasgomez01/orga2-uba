global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;<<<REMOVE>>>
extern malloc
extern free
extern acumuladoPorCliente
extern en_blacklist
extern blacklistComercios
;<<<REMOVE END>>>

; Mapeo de parámetros a registros:
; Signatura de la función: uint32_t* acumuladoPorCliente_asm(uint8_t cantidadDePagos, pago_t* arr_pagos);
; cantidadDePagos[RDI], arr_pagos[RSI]

acumuladoPorCliente_asm:
	; prólogo
	PUSH RBP
	MOV RBP, RSP

	; cuerpo
	;MOV RDX, RDI  ; guardo cantidadDePagos en RDX porque quiero usar RDI para el primer parámetro de malloc
	push rdi
	MOV RDI, 4    ; guardo en RDI el tamaño en bytes del tipo uint32_t (4 bytes)
	MOV RCX, 10   ; guardo en RCX la cantidad de posiciones para uint32_t que quiero reservar
	IMUL RDI, RCX ; multiplico el size_of(uint32_t) * 10
	; Hago el llamado a malloc: void* malloc(size_t size);
	CALL malloc WRT ..plt
	; Tengo el puntero a la posición de memoria que reservé en RAX
	;MOV RDI, RDX   ; vuelvo a poner cantidadDePagos en RDI
	pop rdi
	MOV R9, RAX    ; hago una copia de la posición de memoria almacenada en RAX en R9, para poder moverme
	; Tengo que poner las posiciones de memoria reservadas en cero para evitar comportamientos inesperados
	MOV R10, 0     ; guardo un cero en R10 para setear las posiciones de memoria en cero
	MOV R11, 5     ; guardo un 5 en R11 que me va a servir como contador del loop
	loop_start: 
		MOV [R9], QWORD R10 ; pongo 64 bits (8 bytes) en cero
		ADD R9, 8           ; avanzo 8 bytes la posición de memoria de R9
		DEC R11             ; decremento en uno el contador
		TEST R11, R11       ; veo si R11 es cero
		JNZ loop_start      ; salto a loop_start si no es cero
	; Ahora tengo todos ceros en las posiciones de memoria reservadas 

	MOV R10, RSI        ; me guardo una copia del puntero a arr_pagos en R10

	.chequeo_pago_aprobado:
		ADD R10, 17     		; le sumo 17 bytes a R10 para obtener la posición de memoria de aprobado dentro del struct
		MOV R8B, BYTE [R10] ; me guardo en R8B el valor de aprobado (entero de 1 byte que representa un bool)
		TEST R8B, R8B       ; veo si el valor en R8B es cero
		JNZ .pago_aprobado  ; si el valor de R8B no es cero, osea es true, salto a la etiquEtA .pago_aprobado
		ADD R10, 24 			; le sumo 24 bytes a R10 para que apunte al siguiente elemento de arr_pagos
		DEC RDI             ; decremento en uno el contador (la cantidad de pagos)
		TEST RDI, RDI       ; chequeo si el contador es cero
		JZ fin
		JMP .chequeo_pago_aprobado


	;.pago_desaprobado:
		

	.pago_aprobado: 
		MOV R9, RAX	   ; guardo nuevamente en R9 el puntero al inicio de la posición de memoria reservada 
		SUB R10, 1 	   ; le resto un byte a R10 para obtener la posición de memoria de cliente en el struct 
		MOV R11, [R10] ; me guardo en R11 el número de cliente
		MOV R8, 4      ; me guardo 4 en R8 para hacer el producto 
		IMUL R8, R11   ; multiplico el número de cliente por 4 para saber en qué posición del array debo acumular el monto
		ADD R9, R8     ; me muevo en R9 a la posición de memoria en la cual quiero acumular el monto del cliente
		SUB R10, 16     ; le resto 16 bytes a R10 para que me apunte al lugar donde está aalmacenado el monto en el struct
		MOV R11B, [R10] ; me guardo en R11 el monto 
		ADD BYTE [R9], BYTE R11B  ; acumulo en la posición de memoria correspondiente el monto
		ADD R10, 24    ; le sumo 24 bytes a R10 para que apunte al siguiente elemento de arr_pagos
		DEC RDI             ; decremento en uno el contador (la cantidad de pagos)
		TEST RDI, RDI       ; chequeo si el contador es cero
		JZ fin
		JMP .chequeo_pago_aprobado


	;<<<REMOVE>>>
    	jmp acumuladoPorCliente
	;<<<REMOVE END>>>
	fin: 
		; epílogo
		POP RBP
		ret

en_blacklist_asm:
;<<<REMOVE>>>
    jmp en_blacklist
;<<<REMOVE END>>>
	ret

blacklistComercios_asm:
;<<<REMOVE>>>
    jmp blacklistComercios
;<<<REMOVE END>>>
	ret
