/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definiciones globales del sistema.
*/

#ifndef __DEFINES_H__
#define __DEFINES_H__

/* Misc */
/* -------------------------------------------------------------------------- */
// Y Filas
#define SIZE_N 40
#define ROWS   SIZE_N

// X Columnas
#define SIZE_M 80
#define COLS   SIZE_M

/* Indices en la gdt */
/* -------------------------------------------------------------------------- */
#define GDT_COUNT         35

#define GDT_IDX_NULL_DESC 0
#define GDT_IDX_CODE_0 1
#define GDT_IDX_CODE_3 2
#define GDT_IDX_DATA_0 3
#define GDT_IDX_DATA_3 4
#define GDT_IDX_VIDEO  5


/* Offsets en la gdt */
/* -------------------------------------------------------------------------- */
#define GDT_OFF_NULL_DESC (GDT_IDX_NULL_DESC << 3)
#define GDT_OFF_VIDEO  (GDT_IDX_VIDEO << 3)

/* COMPLETAR - Valores para los selectores de segmento de la GDT 
 * Definirlos a partir de los índices de la GDT, definidos más arriba 
 * Hint: usar operadores "<<" y "|" (shift y or) */

#define GDT_CODE_0_SEL (GDT_IDX_CODE_0 << 3)       // Tengo un 1, shifteo 3 veces para obtener: 0000000000001000
#define GDT_DATA_0_SEL (GDT_IDX_CODE_3 << 3)       // Tengo un 3 (11), lo shifteo 3 veces para obtener: 0000000000011000
#define GDT_CODE_3_SEL ((GDT_IDX_DATA_0 << 3) | 3) // Tengo un 2 (10), shifteo 3 veces y hago un or con un 3 (11) para obtener: 0000000000010011      
#define GDT_DATA_3_SEL ((GDT_IDX_DATA_3 << 3) | 3) // Tengo un 4 (100), lo shifteo 3 veces y hago un or con un 3 (11 )para obtener; 0000000000100011


// Macros para trabajar con segmentos de la GDT.

// SEGM_LIMIT_4KIB es el limite de segmento visto como bloques de 4KIB
// principio del ultimo bloque direccionable.

#define GDT_LIMIT_4KIB(X)  (((X) / 4096) - 1)
#define GDT_LIMIT_BYTES(X) ((X)-1)

#define GDT_LIMIT_LOW(limit)  (uint16_t)(((uint32_t)(limit)) & 0x0000FFFF)
#define GDT_LIMIT_HIGH(limit) (uint8_t)((((uint32_t)(limit)) >> 16) & 0x0F)

#define GDT_BASE_LOW(base)  (uint16_t)(((uint32_t)(base)) & 0x0000FFFF)
#define GDT_BASE_MID(base)  (uint8_t)((((uint32_t)(base)) >> 16) & 0xFF)
#define GDT_BASE_HIGH(base) (uint8_t)((((uint32_t)(base)) >> 24) & 0xFF)

/* COMPLETAR - Valores de atributos */ 
#define DESC_CODE_DATA 0x01   // defino el bit S como 1 para decir que el segmento es de código o de datos
#define DESC_SYSTEM 0x00      // define el bit S como 0 para decir que el segmento es system
#define DESC_TYPE_EXECUTE_READ 0x0a // defino el campo Type como 10 (a en hexa) para decir que el segmento de código es execute y read
#define DESC_TYPE_READ_WRITE 0x02 // defino el campo Type como 2 para decir que el segmento de datos es read y write

// Defines propios para los campos que faltan para el descriptor de segmento
#define DESC_G_ON 0x01
#define DESC_G_OFF 0x00
#define DESC_DPL_0 0x01
#define DESC_DPL_3 0x03
#define DESC_P_ON 0x01
#define FLAT_SEGM_BASE 0x0
#define DESC_DB_ON 0x01
#define DESC_L_OFF 0x00
#define DESC_AVL 0X00


/* COMPLETAR - Tamaños de segmentos */ 
#define FLAT_SEGM_SIZE (817 * 1024 * 1024) // Defino el tamaño de los segmentos como 817 MiB
#define VIDEO_SEGM_SIZE (80 * 50 * 2) // ¿Por qué este tamaño del segmento de video?




/* Direcciones de memoria */
/* -------------------------------------------------------------------------- */

// direccion fisica de comienzo del bootsector (copiado)
#define BOOTSECTOR 0x00001000
// direccion fisica de comienzo del kernel
#define KERNEL 0x00001200
// direccion fisica del buffer de video
#define VIDEO 0x000B8000


#endif //  __DEFINES_H__
