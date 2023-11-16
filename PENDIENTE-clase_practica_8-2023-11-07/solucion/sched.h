/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Declaracion de funciones del scheduler.
*/

#ifndef __SCHED_H__
#define __SCHED_H__

#include "types.h"
#include "task_defines.h"

// Un entero de 8 bits que me indica la tarea actual
extern int8_t current_task;

// Una función que agrega al scheduler una tarea, recibe como parámetro un selector de TSS
int8_t sched_add_task(uint16_t selector);

// Función que recibe un id de una tarea y la desactiva
void sched_disable_task(int8_t task_id);

// Función que recibe el id de una tarea y la activa 
void sched_enable_task(int8_t task_id);

void sched_init();

uint16_t sched_next_task();
#endif //  __SCHED_H__
