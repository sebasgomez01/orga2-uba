section .text

global contar_pagos_aprobados_asm
global contar_pagos_rechazados_asm

global split_pagos_usuario_asm

extern malloc
extern free
extern strcmp


;########### SECCION DE TEXTO (PROGRAMA)

; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
contar_pagos_aprobados_asm:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	sub rsp, 8

	; r12 = current, r13 = usuario, r14 = contador
	mov r12, rdi
	mov r13, rsi
	xor r14, r14

	; current = pList->first
	mov r12, [r12]
	jmp .loop_check

	.loop:
		; current->pago.aprobado?
		mov rdi, [r12]
		cmp byte [rdi+1], 0
		je .no_inc

		; current->pago.cobrador == usuario?
		mov rdi, [rdi+16]
		mov rsi, r13
		call strcmp
		test rax, rax
		jnz .no_inc

		; contador++
		inc r14
	.no_inc:
		; current = current->next
		mov r12, [r12+8]
	.loop_check:
		; current == NULL?
		test r12, r12
		jnz .loop

	mov rax, r14

	add rsp, 8
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);
contar_pagos_rechazados_asm:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	sub rsp, 8

	; r12 = current, r13 = usuario, r14 = contador
	mov r12, rdi
	mov r13, rsi
	xor r14, r14

	; current = pList->first
	mov r12, [r12]
	jmp .loop_check

	.loop:
		; current->pago.aprobado?
		mov rdi, [r12]
		cmp byte [rdi+1], 0
		jne .no_inc

		; current->pago.cobrador == usuario?
		mov rdi, [rdi+16]
		mov rsi, r13
		call strcmp
		test rax, rax
		jnz .no_inc

		; contador++
		inc r14
	.no_inc:
		; current = current->next
		mov r12, [r12+8]
	.loop_check:
		; current == NULL?
		test r12, r12
		jnz .loop

	mov rax, r14

	add rsp, 8
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);
split_pagos_usuario_asm:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8

	; r12 = current, r13 = usuario, r14 = splitted, r15 = aprobado_out, rbx = rechazado_out
	mov r12, rdi
	mov r13, rsi

	; splitted = malloc(sizeof(pagoSplitted_t))
	mov rdi, 24
	call malloc
	mov r14, rax

	; splitted->cant_aprobados = contar_pagos_aprobados(pList, usuario)
	mov rdi, r12
	mov rsi, r13
	call contar_pagos_aprobados_asm
	mov [r14], al

	; aprobado_out = splitted->aprobados = malloc(splitted->cant_aprobados * sizeof(pago_t*))
	lea rdi, [rax*8]
	call malloc
	mov [r14 + 8], rax
	mov r15, rax

	; splitted->cant_rechazados = contar_pagos_rechazados(pList, usuario)
	mov rdi, r12
	mov rsi, r13
	call contar_pagos_rechazados_asm
	mov [r14 + 1], al

	; rechazado_out = splitted->rechazados = malloc(splitted->cant_rechazados * sizeof(pago_t*))
	lea rdi, [rax*8]
	call malloc
	mov [r14 + 16], rax
	mov rbx, rax

	; current = pList->first
	mov r12, [r12]
	jmp .loop_check

	.loop:
		; current->data->cobrador == usuario?
		mov rdi, [r12]
		mov rdi, [rdi+16]
		mov rsi, r13
		call strcmp
		test rax, rax
		jnz .after_add

		; current->data->aprobado?
		mov rdi, [r12]
		cmp byte [rdi+1], 0
		je .es_rechazado

		.es_aceptado:
			; *aprobado_out = current->data
			mov [r15], rdi
			; aprobado_out++
			add r15, 8
			jmp .after_add

		.es_rechazado:
			; *rechazado_out = current->data
			mov [rbx], rdi
			; rechazado_out++
			add rbx, 8

	.after_add:
		; current = current->next
		mov r12, [r12+8]
	.loop_check:
		; current == NULL?
		test r12, r12
		jnz .loop

	mov rax, r14

	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r14
	pop r12
	pop rbp
	ret
