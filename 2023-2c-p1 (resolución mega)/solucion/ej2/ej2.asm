section .rodata
align 16
menor_a_mayor: db 1, 2, 0, 0xFF, 5, 6, 4, 0xFF,  9, 10, 8, 0xFF, 13, 14, 12, 0xFF
mayor_a_menor: db 2, 0, 1, 0xFF, 6, 4, 5, 0xFF, 10,  8, 9, 0xFF, 14, 12, 13, 0xFF
s8_correction: times 4 db 0x80, 0x80, 0x80, 0

section .text

global mezclarColores
mezclarColores:
	movdqa xmm0, [menor_a_mayor]
	movdqa xmm1, [mayor_a_menor]
	movdqa xmm2, [s8_correction]

	imul rcx, rdx
	shr rcx, 2
.loop:
	; Leer los píxeles
	;   El registro va a quedar así:
	;     xmm3 = |A|R|G|B| cada dword
	movdqu xmm3, [rdi]

	; Borrar los alpha
	;   El registro va a quedar así:
	;     xmm3 = |0|R|G|B| cada dword
	pcmpeqd xmm7, xmm7 ; Hago que el registro sea todo unos
	psrld xmm7, 8      ; Meto 8 ceros en el alpha de cada dword
	pand xmm3, xmm7    ; Aplico la máscara

	; Ajusto el valor para poder compararlos como si tuvieran signo
	;   El truco es que queremos que 255 (el uint8 más grande) "se comporte
	;   como" 127 y que 0 (el uint8 más chico) "se comporte como: -128.
	;
	;   Si miramos eso con un poco de cariño entonces lo que queremos es
	;   restar 128 a cada canal. Queda como ejercicio el ver por qué
	;   podemos sumar 0x80 (-128 si lo pensamos como int8, 128 si lo
	;   pensamos como uint8) funciona.
	paddb xmm3, xmm2

	; Armo un registro para hacer las comparaciones
	;   Los registros van a quedar así:
	;     xmm3 = |0|R|G|B| cada dword
	;     xmm4 = |R|G|B|0| cada dword
	movdqa xmm4, xmm3
	psllq xmm4, 8

	; Hago ambas comparaciones
	;   Los registros van a quedar así:
	;     xmm5 = |?|R>G|G>B|?| cada dword
	;     xmm4 = |?|G>R|B>G|?| cada dword
	vpcmpgtb xmm5, xmm4, xmm3 ; |?|R>G|G>B|?|
	vpcmpgtb xmm4, xmm3, xmm4 ; |?|G>R|B>G|?|

	; Borrar la basura de nuestras comparaciones
	;   Los registros van a quedar así, es importante tener en cuenta que
	;   el shift a la derecha es con signo, por lo que copia la "condición"
	;   que habíamos guardado en ese bit.
	;     xmm5 = |R>G|R>G|R>G|G>B| cada dword
	;     xmm4 = |G>R|G>R|G>R|B>G| cada dword
	pslld xmm5, 8
	pslld xmm4, 8
	psrad xmm5, 16
	psrad xmm4, 16

	; Armar las máscaras para el primer y segundo caso
	;   Lo queremos que los registros tengan esta pinta:
	;     xmm5 = |R>G && G>B| cada byte de cada dword
	;     xmm5 = |G>B && B>G| cada byte de cada dword
	;   Sabemos que R>G vale o bien 0 o bien 255 y lo mismo para el resto
	;   de las comparaciones. Entonces podemos comparar con un registro que
        ;   todos los bytes sean 255 (la igualdad va a ocurrir sí y sólo sí
	;   ambas condiciones pasan).
	;   Los registros van a quedar así:
	;     xmm5 = |R>G && G>B| cada dword
	;     xmm4 = |G>R && B>G| cada dword
	pcmpeqd xmm6, xmm6
	pcmpeqd xmm5, xmm6
	pcmpeqd xmm4, xmm6

	; Restaurar los valores pre-comparación deshaciendo el truquito de
	; sumar -128
	paddb xmm3, xmm2

	; Calcular los resultados para el primer y segundo caso
	;   Los registros van a quedar así:
	;     xmm6 = |0|G|B|R| cada dword
	;     xmm7 = |0|B|R|G| cada dword
	vpshufb xmm6, xmm3, xmm1
	vpshufb xmm7, xmm3, xmm0

	; Calcular los píxeles del primer y segundo caso en base a las máscaras
	;   Los registros van a quedar así:
	;     xmm6 = |0|G|B|R| en los dwords dónde R>G && G>B, sino |0|0|0|0|
	;     xmm7 = |0|B|R|G| en los dowrds dónde G>R && B>G, sino |0|0|0|0|
	pand xmm6, xmm5
	pand xmm7, xmm4

	; Calcular los píxeles del tercer caso negando la unión de las otras
	; dos máscaras
	;   El registro va a quedar así:
	;     xmm4 = |0|R|G|B| en los dwords dónde G no está en el medio,
	;                      sino |0|0|0|0|
	por xmm4, xmm5
	pandn xmm4, xmm3

	; Juntar todos los casos
	;   El truco es que como los casos son disjuntos nunca hay dos
	;   registros valores nonzero en el mismo dwords
	por xmm6, xmm7
	por xmm6, xmm4

	; Escribir el resultado
	movdqu [rsi], xmm6

	add rdi, 16
	add rsi, 16
	loop .loop
	ret
