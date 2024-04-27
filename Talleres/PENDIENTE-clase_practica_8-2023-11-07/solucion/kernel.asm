; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

%include "print.mac"

global start


; COMPLETAR - Agreguen declaraciones extern según vayan necesitando
extern A20_check
extern A20_enable
extern GDT_DESC
extern screen_draw_layout

extern idt_init ; TALLER 6
extern IDT_DESC ; TALLER 6
extern pic_reset ; TALLER 6
extern pic_enable ; TALLER 6

extern mmu_init_kernel_dir ; TALLER 7
extern mmu_init_task_dir ; TALLER 7

extern tss_init ; TALLER 8
extern tasks_screen_draw ; TALLER 8
extern sched_init ; TALLER 8
%define GDT_IDX_TASK_INITIAL 11
%define GDT_IDX_TASK_IDLE    12

; TALLER 8
%define TSS_SELECTOR(INDEX_GDT) (INDEX_GDT << 3)
%define TSS_SELECTOR_TASK_IDLE (GDT_IDX_TASK_IDLE << 3)


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
    ;; print_text_rm:
    ;;  Parametros:
    ;;      %1: Puntero al mensaje
    ;;      %2: Longitud del mensaje
    ;;      %3: Color
    ;;      %4: Fila
    ;;      %5: Columna
    print_text_rm start_rm_msg, start_rm_len, 0xF, 0, 0

    ; COMPLETAR - Habilitar A20
    ; (revisar las funciones definidas en a20.asm)
    CALL A20_check ; Si falla el chequeo devuelve 0 --> Hay que habilitar a20

    TEST ax, ax
    JNZ .a20_ya_habilitado

    .habilitar_a20:
        CALL A20_enable

    .a20_ya_habilitado:
    ; COMPLETAR - Cargar la GDT
    LGDT [GDT_DESC]

    ; COMPLETAR - Setear el bit PE del registro CR0
    MOV eax, cr0
    OR eax, 0x1 ; Cambio el flag PE a 1
    MOV cr0, eax

    ; COMPLETAR - Saltar a modo protegido (far jump)
    ; (recuerden que un far jmp se especifica como jmp CS_selector:address)
    ; Pueden usar la constante CS_RING_0_SEL definida en este archivo
    JMP CS_RING_0_SEL:modo_protegido

BITS 32
modo_protegido: ;tasks_screen_draw
    ; COMPLETAR - A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0
    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo
    MOV eax, DS_RING_0_SEL

    MOV ds, eax ; Register selector para Data segment
    MOV ss, eax ; Register selector para Stack segment
    MOV es, eax 
    MOV fs, eax
    MOV gs, eax

    ; COMPLETAR - Establecer el tope y la base de la pila
    MOV ebp, KERNEL_STACK_BASE
    MOV esp, KERNEL_STACK_BASE

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO PROTEGIDO
    ;; print_text_pm:
    ;;  Parametros:
    ;;      %1: Puntero al mensaje
    ;;      %2: Longitud del mensaje
    ;;      %3: Color
    ;;      %4: Fila
    ;;      %5: Columna
    print_text_pm start_pm_msg, start_pm_len, 0xF, 1, 0

    ; COMPLETAR - Inicializar pantalla
    CALL screen_draw_layout

    ;; -------------------------------------------------------------------------- ;;

    ; TALLER 7
    CALL mmu_init_kernel_dir
    MOV cr3, eax

    MOV eax, cr0
    OR eax, 0x80000000 ; Activo los flags PG (Paging)
    MOV cr0, eax

    ; TALLER 8, cargo los descriptores de TSS a la GDT con la función tss_init
    CALL tss_init

    ; llamo sched_init 
    CALL sched_init

    ; llamo la función tasks_screen_draw
    CALL tasks_screen_draw

    ; Cargo en CR3 el selector de la tarea inicial
    mov ax, TSS_SELECTOR(GDT_IDX_TASK_INITIAL)  
    ltr ax

    ; Hago el salto a la tarea idle
    jmp TSS_SELECTOR_TASK_IDLE:0

    

    XOR EDI, EDI
    MOV EDI, 0x18000
    CALL mmu_init_task_dir



    ;; -------------------------------------------------------------------------- ;;

    ; TALLER 6
    ; Inicializar IDT con interrupciones definidas en C
    CALL idt_init

    ; Cargar IDT
    LIDT [IDT_DESC]

    ; Código para activar interrupciones externas:
    CALL pic_reset ; remapear PIC
    CALL pic_enable ; habilitar PIC
    STI ; habilitar interrupciones

    ; Llamo a las interrupciones de sistema definidas en este taller
    INT 88
    INT 98

    ; TALLER 8 //
    

    ;; -------------------------------------------------------------------------- ;;

    ; Ciclar infinitamente 
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
