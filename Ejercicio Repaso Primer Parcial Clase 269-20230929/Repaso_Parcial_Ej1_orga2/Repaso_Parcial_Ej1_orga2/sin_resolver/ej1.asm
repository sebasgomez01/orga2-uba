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

acumuladoPorCliente_asm:
	; prólogo
	PUSH RBP
	MOV RBP, RSP

	; cuerpo
	MOV RDX, RDI  ; guardo cantidadDePagos en RDX porque quiero usar RDI para el primer parámetro de malloc
	MOV RDI, 4    ; guardo en RDI el tamaño en bytes del tipo uint32_t (4 bytes)
	MOV RCX, 10   ; guardo en RCX la cantidad de posiciones para uint32_t que quiero reservar
	IMUL RDI, RCX ; multiplico el size_of(uint32_t) * 10
	; Hago el llamado a malloc: void* malloc(size_t size);
	CALL malloc WRT ..plt
	; Tengo el puntero a la posición de memoria que reservé en RAX
	MOV R9, RAX    ; hago una copia de la posición de memoria almacenada en RAX en R9, para poder moverme
	MOV R10, 0     ; guardo un cero en R10 para setear las posiciones de memoria en cero
	MOV R11, 5     ; guardo un 5 en R11 que me va a servir como contador del loop
	; Tengo que poner las posiciones de memoria reservadas en cero para evitar comportamientos inesperados
	loop_start: 
		MOV [R9], QWORD R10 ; pongo 64 bits (8 bytes) en cero
		ADD R9, 8           ; avanzo 8 bytes la posición de memoria de R9
		DEC R11             ; decremento en uno el contador
		TEST R11, R11       ; veo si R11 es cero
		JNZ loop_star

	ADD RDX, 3     ; le sumo 3 bytes a RDX para obtener la posición de memoria de aprobado dentro del struct
	MOV R8B, BYTE [RDX] ; me guardo en R8B el valor de aprobado (entero de 1 byte que representa un bool)
	TEST R8B, R8B       ; veo si el valor en R8B es cero
	JNZ .pago_aprobado  , si el valor de R8B no es cero, osea es true, salto a la etiqute .pago_aprobado


	.pago_aprobado: 
	SUB RDX, 1 ; le resto un byte a RDX para obtener la posición de memoria de cliente del struct
	MOV R10, [RDX] ; me guardo en R10 el número de cliente
	IMUL R10, RDI  ; multiplico el número de cliente por 4 para saber en qué posición del array debo acumunlar el monto
	ADD R9, R10    ; me muevo en R9 a la posición de memoria en la cual quiero acumular el monto del cliente


	;<<<REMOVE>>>
    	jmp acumuladoPorCliente
	;<<<REMOVE END>>>

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
