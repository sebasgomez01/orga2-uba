global mezclarColores


; Cada píxel ocupa 32 bits, y los registros xmmn tienen 256, así que voy a trabajar de a 4 píxeles
; La idea es aplicar cada caso de la función y guardarme el resultado en distintos registros
; y finalmente combinarlos utilizando un AND
; Primero tengo que desacherme de los alphas ya que quiero que la transparencia sea 0 para todos los píxeles
; Puedo deshacerme de los alphas haciendo un AND con el valor | 1 | 1 | 1 | 0 |, osea 0x
; Necesito hacer unos shuffles para poder comparar los componentes de los píxeles de acuerdo a la función
; El orden dado de los componentes es | B | G | R | A | 

; Caso 1 de la función: R > G > B
; Quiero que el los píxeles con los que voy a comparar tengan la siguiente forma: | G | R | R | A 
; Para poder hacer | G | R | R | A | > | B | G | R | A |


;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Mapeo de parámtros a registros:
;void mezclarColores( uint8_t *X, uint8_t *Y, uint32_t width, uint32_t height);
;rdi[X], rsi[Y], rdx[width], rcx[height]


mezclarColores:
    movdq xmm0, [rdi] ; me traigo 4 píxeles a xmm0





