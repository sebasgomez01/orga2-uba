global maximosYMinimos_asm

section .data

mascara_eliminar_alpha: DD 0x00FFFFFF, DD 0x00FFFFFF, DD 0x00FFFFFF, DD 0x00FFFFFF  

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Signatura de la función:
; void maximosYMinimos_asm(uint8_t *src, uint8_t *dst, uint32_t width, uint32_t height)

; Mapeo de parámetros a registros:
; rdi[src], rsi[dst], rdx[width], rcx[height]

maximosYMinimos_asm:
    ; prologo
    push rbp
    mov rbp, rsp

    ; cuerpo
    ; Calculo la cantidad de píxeles a pintar, asumo que la cantidad de píxeles de la imagen es par
    mov r10, rdx  ; r10 = width
    imul r10, rcx ; r10 = r10*rcx = #pixeles
    shl r10, 1    ; r10 = #pixeles/2, pues voy a pintar de a 2 píxeles

    ; Ahora en r10 tengo la cantidad de píxeles a pintar

    ; ¿cómo puedo saber el número de columna de un píxel?
    ; puedo tener un contador de filas y uno de columnas, los voy contando, cuando el contador de columnas es igual al de columnas seteo ambos en 
    ; cero para la próxima iteración

    xor r15, r15 ; contador de columna
    mov r15, 1   
    xor r14, r14 ; contador de fila
    
    

    .bucle:
        ; me cargo 2 píxeles 
        movq xmm0, [rdi] ; xmm0 = | B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | X | X | X | X | X | X | X | X |
        movdqu xmm1, [mascara_eliminar_alpha]
        pand xmm0, xmm1 ; elimino las componentes alpha de los píxeles

        ; 


        cmp r15, rdx            ; comparo con el ancho
        jne .incrementar_columna     
        inc r14                 ; incremento el contador de fila, pues terminamos una fila
        mov r15, 1              ; vuelvo a la columna 1, esta vez de la siguiente fila
        jmp .avanzar_pixeles
                           
        .incrementar_columna: 
            add r15, 2          ; incremento el contador de columna en 2, pues todavía no terminé la fila 


        .avanzar_pixeles:
            ; falta cargar los píxeles
            add rdi, 8
            add rsi, 8
            dec rdx 
            cmp rdx, 0
            je .fin 
            jmp .bucle

    call 



    .fin:
    ; epílogo
    pop rbp
    ret