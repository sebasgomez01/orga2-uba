global mezclarColores


section .data
    align 16
    mascara_shuf_r0: DB	2,	0xFF,	0xFF,	0xFF,	6,	0xFF,	0xFF,	0xFF,	  0xA,	0xFF,	0xFF,	0xFF,	0xE,	0xFF,	0xFF,	0xFF
    mascara_shuf_r1: DB	1,	0xFF,	0xFF,	0xFF,	5,	0xFF,	0xFF,	0xFF,	    9,	0xFF,	0xFF,	0xFF,	0xD,	0xFF,	0xFF,	0xFF
    mascara_shuf_r2: DB	0,	0xFF,	0xFF,	0xFF,	4,	0xFF,	0xFF,	0xFF,	    8,	0xFF,	0xFF,	0xFF,	0xC,	0xFF,	0xFF,	0xFF

    mascara_shuf_caso_1: DB	1,	2,	0,	0xFF,	5,	6,	4,	0xFF,	  9,	0xA,	8,	0xFF,	0xD,	0xE,	0xC,	0xFF
    mascara_shuf_caso_2: DB	2,	0,	1,	0xFF,	6,	4,	5,	0xFF,	0xA,	  8,	9,	0xFF,	0xE,	0xC,	0xD,	0xFF

    mascara_unos: times 4 DD 0xFFFFFFFF ; 128 bits con unos
    mascara_eliminar_alpha: times 4 DD 0x00FFFFFF


;########### SECCION DE TEXTO (PROGRAMA)
section .text

; void mezclarColores( uint8_t* X, uint8_t* Y, uint32_t width, uint32_t height);
; uint8_t* X      --> RDI
; uint8_t* Y      --> RSI
; uint32_t width  --> RDX
; uint32_t height --> RCX
mezclarColores:
    ; prólogo
    PUSH rbp
    MOV rbp, rsp
    ; cuerpo
	; 1. Busco la cantidad de pixeles a pintar: width * height
    MOV RAX, RDX  ; Me traigo el ancho
    MUL RCX       ; Multiplico el ancho x alto

    .pintar_pixeles:
        ; 2. Cargo 4 pixeles a registros, para luego verificar a que caso pertenecen y pintarlos de esa manera en el destino
        MOVDQU XMM1, [RDI] ; XMM = B1 G1 R1 A1 B2 G2 R2 A2 B3 G3 R3 A3 B4 G4 R4 A4 (128 bits)
        ; Armo 4 enteros de 32 bits para comparar los canales con shuffles
        MOVDQU XMM13, [mascara_shuf_r0]
        MOVDQU XMM14, [mascara_shuf_r1]
        MOVDQU XMM15, [mascara_shuf_r2]

        MOVDQU XMM2, XMM1
        MOVDQU XMM3, XMM1
        MOVDQU XMM4, XMM1

        PSHUFB XMM2, XMM13
        PSHUFB XMM3, XMM14
        PSHUFB XMM4, XMM15
        ; Ahora tengo en el primer byte de cada segmento de 32 bits los canales B, G, R de forma correspondiente a cada registro
        ; Registros ocupados: XMM1 (Pixeles originales), XMM2/XMM3/XMM4 (Canales)




        ; ------------------------------------------------------------------------------------------------
        ; 2.1 - Caso R > G > B
        ; 2.1.1 Copio los registros con los canales a comprar
        MOVDQU XMM5, XMM2
        MOVDQU XMM6, XMM3
        MOVDQU XMM7, XMM4

        MOVDQU XMM8, XMM1
        MOVDQU XMM15, [mascara_shuf_caso_1]

        ; 2.1.2.a Realizo la comparacion
        PCMPGTD XMM5, XMM6 ; R > G
        PCMPGTD XMM6, XMM7 ; G > B

        PAND XMM5, XMM6    ; Junto ambas condiciones R > G && G > B

        ; 2.1.2.b Genero el resultado para este caso
        PSHUFB XMM8, XMM15

        ; 2.1.3 - Descarto los valores que no cumplieron la condición
        MOVDQU XMM12, XMM5 ; Me guardo el resultado de la condicion (uso este registro para no reescribir codigo)
        PAND XMM5, XMM8

        ; Registros ocupados: XMM1 (Pixeles originales), XMM2/XMM3/XMM4 (Canales), XMM5 (Resultado caso 1)




        ; ------------------------------------------------------------------------------------------------
        ; 2.2 - Caso R < G < B
        MOVDQU XMM6, XMM2
        MOVDQU XMM7, XMM3
        MOVDQU XMM8, XMM4

        MOVDQU XMM9, XMM1
        MOVDQU XMM14, [mascara_unos]
        MOVDQU XMM15, [mascara_shuf_caso_2]

        ; 2.2.2.a Realizo la comparacion
        PCMPGTD XMM6, XMM7 ; R > G
        PXOR XMM6, XMM14   ; Ahora la negación de lo que hay en el registro, osea invierto los bits

        PCMPGTD XMM7, XMM8 ; G > B
        PXOR XMM7, XMM14   ; Ahora la negación de lo que hay en el registro, osea invierto los bits

        PAND XMM6, XMM7    ; Junto ambas condiciones R < G && G < B

        ; 2.2.2.b Genero el resultado para este caso
        PSHUFB XMM9, XMM15

        ; 2.2.3 - Descarto los valores que no cumplieron la condición
        MOVDQU XMM11, XMM6 ; Me guardo el resultado de la condicion (uso este registro para no reescribir codigo)
        PAND XMM6, XMM9

        ; Registros ocupados: XMM1 (Pixeles originales), XMM2/XMM3/XMM4 (Canales), XMM5 (Resultado caso 1), XMM6 (Resultado caso 2)


        ; ------------------------------------------------------------------------------------------------
        ; 2.3 - No se cumplieron los anteriores
        ; 2.3 - Caso !((R > G > B) || (R < G < B))
        MOVDQU XMM14, [mascara_eliminar_alpha]
        MOVDQU XMM15, [mascara_unos]

        ; 2.3.2.a Realizo la comparacion
        POR XMM12, XMM11  ; (R > G > B) || (R < G < B)
        PXOR XMM12, XMM15 ; Ahora la negación de lo que hay en el registro, osea invierto los bits

        ; 2.3.2.b Genero el resultado para este caso
        ; Este caso ya esta resuelto en XMM1 :)

        ; 2.3.3 - Descarto los valores que no cumplieron la condición
        PAND XMM1, XMM12
        PAND XMM1, XMM14 ; Le borro el alpha a todos los pixeles

        ; Registros ocupados: XMM1 (Resultado caso 3), XMM2/XMM3/XMM4 (Canales), XMM5 (Resultado caso 1), XMM6 (Resultado caso 2)


        ; ------------------------------------------------------------------------------------------------

        ; 3. Ahora tengo los píxeles con todas las opciones procesadas
        ; 3.1 Dejo el resultado en un registro
        POR XMM1, XMM5
        POR XMM1, XMM6


        ; 4. Ahora tengo los píxeles finales a guardar en el destino
        MOVDQU [RSI], XMM1
        ; 4.2 Avanzo a los siguientes
        ADD RDI, 16
        ADD RSI, 16     ; avanzo el RSI 8 bytes (4 píxeles)

        SUB RAX, 4
        JNZ .pintar_pixeles

    XOR rax, rax

    ; epílogo
    POP rbp
    RET