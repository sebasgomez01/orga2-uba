global mezclarColores


; Cada píxel ocupa 32 bits, y los registros xmmn tienen 256, así que voy a trabajar de a 4 píxeles
; La idea es aplicar cada caso de la función y guardarme el resultado en distintos registros
; y finalmente combinarlos utilizando un AND
; Primero tengo que desacherme de los alphas ya que quiero que la transparencia sea 0 para todos los píxeles
; Puedo deshacerme de los alphas haciendo un AND con el valor | 1 | 1 | 1 | 0 |, osea 0xFFFFFF00 ó 0x00FFFFFF
; Necesito hacer unos shuffles para poder comparar los componentes de los píxeles de acuerdo a la función
; El orden dado de los componentes es:
; | B | G | R | A | B | G | R | A | B | G | R | A | B | G | R | A | 
; | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 


; Caso 1 de la función: R > G > B
; Quiero que el los píxeles con los que voy a comparar tengan la siguiente forma: 
; | G | R | R | A | G | R | R | A | G | R | R | A | G | R | R | A |
; máscara

; Para poder hacer | G | R | R | A | > | B | G | R | A |
; como en este caso en la componente R al hacer la comparación R > R siempre me va a dar falso
; tengo que restituir ese valor con una máscara
; Si un píxel entra en el caso 1 quiero reacomodar sus componentes de la siguiente forma:
; | B | G | R | A | ----> | G | R | B | A |
; máscara:
; | 1 | 2 | 0 | 3 | 5 | 6 | 4 | 7 | 9 | 10 | 8 | 11 | 13 | 14 | 12 | 15 |

; Caso 2 de la función: B > G > R
; Quiero que los píxeles con los que voy a comprar tengan la siguiente forma:
; | B | B | G | A |
; Para poder hacer | B | B | G | A | > | B | G | R | A | 
; como en este caso en la componente B al hacer B > B me va a dar falso siempre,
; tengo que restituir el valor de BLUE una máscara

; Si un píxel entra en el caso 2 quiero reacomodar sus componentes de la siguiente manera: 
; | B | G | R | A | -----> | R | B | G | A |
; mascara: 
; | 2 | 0 | 1 | 3 | 6 | 4 | 5 | 7 | 10 | 8 | 9 | 11 | 14 | 12 | 13 | 15 

section .data

mascara_borrar_alpha: DD 0x00FFFFFF, 0x00FFFFFF, 0x00FFFFFF, 0x00FFFFFF ; (alpha, red, green, blue)
mascara_shuffle_caso_1_comparacion: DB 1, 2, 2, 3, 5, 6, 6, 7, 9, 10, 10, 11, 13, 14, 14, 15  
mascara_shuffle_caso_1: DB 1, 2, 0, 3, 5, 6, 4, 7, 9, 10, 8, 11, 13, 14, 12, 15 
mascara_restaurar_red: DD 0x00FF0000, 0x00FF0000, 0x00FF0000, 0x00FF0000 
mascara_shuffle_caso_2_comparacion: DB 0, 0, 1, 3, 4, 4, 5, 7, 8, 8, 9, 11, 12, 12, 13, 15 
mascara_shuffle_caso_2: DB 2, 0, 1 , 3, 6, 4, 5, 7, 10, 8, 9, 11, 14, 12, 13, 15
mascara_restaurar_blue: DD 0x000000FF, 0x000000FF, 0x000000FF, 0x000000FF 
mascara_invertir_bits: DD  0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
 

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Mapeo de parámetros a registros:
;void mezclarColores( uint8_t *X, uint8_t *Y, uint32_t width, uint32_t height);
;rdi[X], rsi[Y], rdx[width], rcx[height]


mezclarColores:

    ; prólogo
    PUSH RBP
    MOV RBP, RSP

    ; cuerpo

	; 1. Busco la cantidad de pixeles a pintar: width * height
    MOV RAX, RDX  ; Me traigo el ancho
    IMUL RAX, RCX ; Multiplico el ancho x alto
    mov rdx, 0  ; Limpia rdx
    mov rcx, 4  ; El divisor es 4
    idiv rcx    ; Divido rax por rcx (4)




    .bucle: 
        movdqu xmm0, [rdi]                   ; me traigo 4 píxeles a xmm0

        movdqu xmm1, [mascara_borrar_alpha]  ; cargo la máscara para borrar los alphas
        pand xmm0, xmm1                      ; elimino los alphas y guardo el resultado en xmm0
        movdqu xmm1, xmm0                    ; me guardo una copia en xmm1 para hacer el shuffle
        ; me guardo unas copias para los otros casos 
        movdqu xmm3, xmm0                    
        movdqu xmm4, xmm0
        movdqu xmm5, xmm0

        ; CASO 1: R > G > B
        movdqu xmm2, [mascara_shuffle_caso_1_comparacion]; me guardo en xmm2 la máscara para hacer el shuffle
        pshufb xmm1, xmm2                    ; realizo el shuffle byte a byte y guardo el resultado en xmm1
        pcmpgtb xmm1, xmm0                   ; realizo la compración para ver qué píxeles cumplen la condición del caso 1
        movdqu xmm2, [mascara_restaurar_red] ; cargo la máscara ṕara restaurar el red
        por xmm1, xmm2                       ; restauro el valor de red, dejando las otras componentes intactas
        pand xmm0, xmm1
        ; ahora tengo en xmm0 los píxeles que cumplen con la condición del primer caso
        movdqu xmm2, [mascara_shuffle_caso_1] 
        pshufb xmm4, xmm2                    ; reacomodo los componentes de acuerdo al caso 1 y lo guardo en xmm0
        pand xmm0, xmm1                      ; descarto los píxeles que no entran en este caso
        movdqu xmm2, [mascara_restaurar_red]
        movdqu xmm10, xmm1
        ; ahora tengo en xmm0 los píxeles que entran en el caso 1 con sus componentes reacomodadas como corresponde
        ; y listos para ser cargados en la nueva imagen


        ; CASO 2: B > G > R
        movdqu xmm1, xmm3
        movdqu xmm2, [mascara_shuffle_caso_2_comparacion]; me guardo en xmm2 la máscara para hacer el shuffle
        pshufb xmm1, xmm2                           ; realizo el shuffle byte a byte y guardo el resultado en xmm1
        pcmpgtb xmm1, xmm3                          ; realizo la compración para ver qué píxeles cumplen la condición del caso 2
        movdqu xmm2, [mascara_restaurar_blue] ; cargo la máscara ṕara restaurar el blue
        por xmm1, xmm2                        ; restauro el valor de blue, dejando las otras componentes intactas
        pand xmm3, xmm1
        ; ahora tengo en xmm1 los píxeles que cumplen con la condición del segundo caso
        movdqu xmm2, [mascara_shuffle_caso_2]
        pshufb xmm3, xmm2                     ; reacomodo los componentes de acuerdo al caso 2 y lo guardo en xmm3
        pand xmm3, xmm1                       ; descarto los píxeles que no entran en este caso
        movdqu xmm11, xmm1
        ; ahora tengo en xmm3 los píxeles que entran en el caso 2 con sus componentes reacomodadas como corresponde
        ; y listos para ser cargados en la nueva imagen

        ; CASO BLUE = GREEN = RED
        ; Me guardo copias de los píxeles para realizar las comparaciones
        MOVDQU XMM8, XMM5   
        MOVDQU XMM9, XMM5
        MOVDQU XMM5, XMM5

        ;PCMPEQB XMM8, XMM9 ; chequeo (blue = blue) and (green = green) and (red = red) and (alpha = alpha) y  guardo en resultado en xmm8 
        ; ahora tengo en xmm8 unos en los píxeles ques pertenecen a este caso y ceros en el resto
        ; Como los píxeles se mantienen iguales en este caso, simplemente descarto los píxeles que no corresponden a este caso
        ;PAND XMM5, XMM8 ; descarto los píxeles que no cumplieron la condición
        por xmm10, xmm11
        movdqu xmm12, [mascara_invertir_bits]
        pxor xmm10, xmm12
        pand xmm5, xmm10
        movdqu xmm13, [mascara_borrar_alpha]
        pand xmm5, xmm13
        ; ahora tengo en XMM3 los píxeles que entraron en el primer caso, en XMM4 los píxeles que entraron en el segundo caso y en xmm5 los que entraron en el tercero
        ; queda juntar los resultados


        por xmm0, xmm3
        por xmm0, xmm5
        ;ahora tengo en xmm0 los cuatro píxeles listos para ser cargados
        movdqu [rsi], xmm0
        add rsi, 16
        add rdi, 16
        SUB RAX, 1
        TEST RAX, RAX
        JNZ .bucle

    ; epílogo
    POP RBP
    ret





    ; CASO 3: 
        ; Para obtener los píxexes que no entran en el caso 1 ni en el caso 2, obtengo los píxeles que 
        ; entran en el caso 1 ó en el caso 2, y usa una negación
        ;movdqu xmm1, xmm4
        ;movdqu xmm2, [mascara_shuffle_caso_1_comparacion]; me guardo en xmm2 la máscara para hacer el shuffle
        ;pshufb xmm1, xmm2                           ; realizo el shuffle byte a byte y guardo el resultado en xmm1
        ;pcmpgtb xmm1, xmm4                          ; realizo la compración para ver qué píxeles cumplen la condición del caso 2
        ;movdqu xmm2, [mascara_restaurar_red] ; cargo la máscara ṕara restaurar el blue
        ;por xmm1, xmm2                        ; restauro el valor de blue, dejando las otras componentes intactas
        ; ahora tengo en xmm1 los píxeles que cumplen con la condición del segundo caso    
        ;movdqu xmm2, xmm4
        ;movdqu xmm5, [mascara_shuffle_caso_2_comparacion]; me guardo en xmm2 la máscara para hacer el shuffle
        ;pshufb xmm2, xmm5                           ; realizo el shuffle byte a byte y guardo el resultado en xmm1
        ;pcmpgtb xmm2, xmm4                          ; realizo la compración para ver qué píxeles cumplen la condición del caso 2
        ;movdqu xmm5, [mascara_restaurar_blue] ; cargo la máscara ṕara restaurar el blue
        ;por xmm2, xmm5                        ; restauro el valor de blue, dejando las otras componentes intactas
        ; ahora tengo en xmm1 los píxeles que cumplen con la condición del segundo caso    
        ; ahora obtento en xmm1  los que cumplen el caso 1 ó el caso 2
        ;por xmm1, xmm2
        ;movdqu xmm2, [mascara_invertir_bits]
        ;pxor xmm1, xmm2
        ; ahora tengo en xmm1 todos los píxeles que no entran en ningún caso, que deben permanecer iguales
        ; Entonces tengo en xmm0 los píxeles del caso 1, en xmm3 los píxeles del caso 2, y en xmm1 los que no entran en ninguno
        ; los uno con un or
