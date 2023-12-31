; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

%include "print.mac"
;%include "a20.asm"

global start


; COMPLETAR - Agreguen declaraciones extern según vayan necesitando
extern A20_check
extern A20_enable
extern GDT_DESC
extern screen_draw_box


; COMPLETAR - Definan correctamente estas constantes cuando las necesiten
%define CS_RING_0_SEL (1 << 3)   
%define DS_RING_0_SEL (3 << 3)   
%define KERNEL_STACK_BASE 0x25000

BITS 16
;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;; -------------------------------------------------------------------------- ;;
start_rm_msg db     'Iniciando kernel en Modo Real'
start_rm_len equ    $ - start_rm_msg

start_pm_msg db     'Iniciando kernel en Modo Protegido'
start_pm_len equ    $ - start_pm_msg

;;
;; Seccion de código.
;; -------------------------------------------------------------------------- ;;

;; Punto de entrada del kernel.
BITS 16
start:
    ; COMPLETAR - Deshabilitar interrupciones
    CLI

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO REAL
    ; (revisar las funciones definidas en print.mac y los mensajes se encuentran en la
    ; sección de datos)
    print_text_rm start_rm_msg, start_rm_len, 00001111, 0x05, 0x02

    ; COMPLETAR - Habilitar A20
    ; (revisar las funciones definidas en a20.asm)
    CALL A20_check

    TEST ax, ax
    JNZ A20_habilitado
    CALL A20_enable

    A20_habilitado:
    ; COMPLETAR - Cargar la GDT
    lgdt [GDT_DESC]

    ; COMPLETAR - Setear el bit PE del registro CR0
    ; El registro CRO tiene 32 bits, y solamenente quiero setear en uno el primer bit, y dejar el resto como estaba,
    ; esto lo puedo lograr haciendo un or con el valor 0x0000001 (esto es un número 1 de 32 bits)
    ; Pero como a los registros de control solo los puedo modificar mediante las instrucciones MOV, 
    ; tengo que copiar el valor de CR0 a otro registro, realizar el or con ese registro y luego volver a cargar el valor en CR0
    MOV EAX, CR0
    MOV EBX, 0x01
    OR EAX, EBX
    MOV CR0, EAX

    ; COMPLETAR - Saltar a modo protegido (far jump)
    ; (recuerden que un far jmp se especifica como jmp CS_selector:address)
    ; Pueden usar la constante CS_RING_0_SEL definida en este archivo
    jmp CS_RING_0_SEL:modo_protegido ; esto lo hago para saltar al mismo segmento de código en el que me encuentro


BITS 32
modo_protegido:
    ; COMPLETAR - A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0
    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo
    MOV EAX, DS_RING_0_SEL
    MOV DS, EAX
    MOV ES, EAX
    MOV GS, EAX
    MOV FS, EAX
    MOV SS, EAX

    ; COMPLETAR - Establecer el tope y la base de la pila
    MOV EBP, KERNEL_STACK_BASE
    MOV ESP, KERNEL_STACK_BASE

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO PROTEGIDO
    ;print_text_rm start_pm_msg, start_pm_len, 00001111, 0x05, 0x02
    print_text_pm start_pm_msg, start_pm_len, 0xF, 1, 0

    ; COMPLETAR - Inicializar pantalla  
    CALL screen_draw_box
   
    ; Ciclar infinitamente 
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
