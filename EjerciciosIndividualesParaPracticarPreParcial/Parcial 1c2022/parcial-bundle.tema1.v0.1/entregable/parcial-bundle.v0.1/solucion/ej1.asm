
global strArrayNew
global strArrayGetSize
global strArrayAddLast
global strArraySwap
global strArrayDelete




;########### SECCION DE DATOS
section .data

extern calloc
extern strClone

%define OFFSET_SIZE 0
%define OFFSET_CAPACITY 1
%define OFFSET_DATA 8

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Signatura de la función:
; str_array_t* strArrayNew(uint8_t capacity)
; Mapeo de parámetros a registros: 
; capacity[RDI]

strArrayNew:
	; prólogo 
	push rbp 
	mov rbp, rsp

	; cuerpo
	; Lo primero que tengo que hacer es reservar memoria para la estructura 
	; tengo que reservar 16 bytes, para esto uso calloc, que además de reservarme
	; la memoria me la setea toda en ceros 

	push rdi    ; pusheo rdi no perder su valor, pues lo necesito para guardar el primer parámetro de calloc
	mov rdi, 16 ; me guardo en rdi la cantidad de elementos 
	mov rsi, 8  ; me guardo en rsi el tamaño de cada elemento
	; llamo calloc:
	call calloc wrt ..plt
	; ahora tengo en rax el puntero que quiero devolver
	pop rdi     ; recupero el valor original de rdi (capacity)
	add [rax + OFFSET_CAPACITY], rdi ; le pongo el valor correspondiente a capacity


	; epílogo
	pop rbp
	ret


; Signatura de la función:
; uint8_t  strArrayGetSize(str_array_t* a)
; Mapeo de parámetros a registros: 
; a[rdi]

; uint8_t  strArrayGetSize(str_array_t* a)
strArrayGetSize:
	; prólogo 
	push rbp
	mov rbp, rsp

	; cuerpo
	xor rax, rax   ; pongo rax en cero por las dudas
	mov sil, BYTE [rdi + OFFSET_SIZE] ; me copio el valor de size en sil
	mov al, sil                  ; me copio el valor de sil en al (primer byte de rax)

	; epílogo
	pop rbp
	ret


; Signatura de la función:
; void strArrayAddLast(str_array_t* a, char* data)
; Mapeo de parámetros a registros: 
; a[rdi], data[rsi]

; void strArrayAddLast(str_array_t* a, char* data)
strArrayAddLast:
	; prólogo
	push rbp
	mov rbp, rsp

	; cuerpo
	xor rcx, rcx                    ; pongo rcx en cero
	mov cl, [rdi + OFFSET_SIZE]     ; me guardo size en cl
	mov dl, [rdi + OFFSET_CAPACITY] ; me guardo capacity en dl
	cmp cl, dl                      ; comparo dl y cl (size y capacity)
	jge fin                         ; if (size >= capacity) then (salto a fin)
	mov r8, rdi                     ; me guardo en r8 el puntero al array
	add r8, 8						; avanzo el puntero para obtener data dentro del struct
	xor r9, r9                      ; pongo el 0 el contador de strings
	loop_start:
		mov dl, BYTE [r8]           ; me guardo el char ubicado en la posición de memoria r8 en dl
		inc r8                      ; incremento en uno r8 para que apunte al siguiente char
		test dl, dl                 ; chequeo si no es cero para saber que terminó un string
		jnz loop_start
		inc r9                      ; si dl es cero, entonces el string terminó, aumento el contador de strings
		cmp r9, rcx                	; chequeo si r9 es igual al size
		jle loop_start              ; si no son iguales vuelvo al loop 
	; si son iguales tengo que salir del loop y copiar el string en la posición a la que apunta r8
		add cl, 1                   ; aumento size en 1
		mov [rdi], cl 				; lo guardo en la posición de memoria correspondiente
 	copiar_string:
		mov dl, BYTE [rsi]          ; me guardo en dl el primer char del string a copiar
		mov [r8], dl                ; copio el char
		inc rsi  					; incremento un byte para que apunte al siguiente char
 		inc r8          
 		mov cl, [rsi]
 		test cl, cl
 		jnz copiar_string

	fin:
	; epílogo
	pop rbp 


; Signatura de la función 
; void  strArraySwap(str_array_t* a, uint8_t i, uint8_t j)
; Mapeo de parámetros a registros:
; a[rdi], i[rsi], j[rdx]


strArraySwap:
	; prólogo
	push rbp
	mov rbp, rsp

	; cuerpo
	xor rbx, rbx
	xor rcx, rcx
	mov bl, BYTE [rsi] 				  	; me traigo i al registro bl
	mov cl, BYTE [rdx] 					; me traifo j al registro cl
	mov r8b, BYTE [rdi + OFFSET_SIZE]     ; me traigo el size al registro r8b
	; Chequeo si alguno de los dos índices se encuentra fuera de rango, en ese caso, salto a la etiqueta fin:
	cmp bl, r8b
	jge fin_strArraySwap
	cmp cl, r8b
	jge fin_strArraySwap
	; Si ninguno se encuentra fuera de rango, procedo a hacer el swap:
	mov r8, rdi                     ; me guardo en r8 el puntero al array
	add r8, 8						; avanzo el puntero para obtener data dentro del struct
	xor r10, r10                    ; pongo el 0 el contador de strings
	loop_start_i:
		mov r9b, BYTE [r8]           ; me guardo el char ubicado en la posición de memoria r9b en dl
		inc r8                       ; incremento en uno r8 para que apunte al siguiente char
		test r9b, r9b                ; chequeo si no es cero para saber que terminó un string
		jnz loop_start
		inc r10                     ; si dl es cero, entonces el string terminó, aumento el contador de strings
		cmp r10, rbx                	; chequeo si r10 es igual a i 
		je loop_start_i              ; si no son iguales vuelvo al loop 
	; Al finalizar este loop tengo en r8 la posición de memoria el elemento data[i]

	mov r9, rdi                     ; me guardo en r9 el puntero al array
	add r9, 8						; avanzo el puntero para obtener data dentro del struct
	xor r10, r10                    ; pongo en 0 el contador de strings
	loop_start_j:
		mov r11b, BYTE [r9]           ; me guardo el char ubicado en la posición de memoria r8 en r9b
		inc r9                       ; incremento en uno r8 para que apunte al siguiente char
		test r11b, r11b                ; chequeo si no es cero para saber que terminó un string
		jnz loop_start
		inc r10                      ; si r9b es cero, entonces el string terminó, aumento el contador de strings
		cmp r10, rcx                	 ; chequeo si r10 es igual a j
		je loop_start_j             ; si no son iguales vuelvo al loop 
	; Al finalizar este loop tengo en r9 la posición de memoria el elemento data[j] 


	fin_strArraySwap:
	; epílogo
	pop rbp


; void  strArrayDelete(str_array_t* a)
strArrayDelete:






;DUDAAAAA:
; uso la función strClone, cargo el parámetro en rdi:
	;push rdi
	;mov rdi, rsi
	;call 
	; creo que no me sirve porque strClone me reserva un nuevo valor en memoria y copia el string ahí
	; y yo lo que quiero es copiarlo a la posición de memoria a la que apunta r8