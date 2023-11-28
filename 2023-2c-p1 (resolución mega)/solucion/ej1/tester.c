#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <assert.h>
#include <errno.h>
#include "ej1.h"

char *filename_ej1 =  "salida.propios.ej1.txt";
void test_ej1a(char* filename);
void test_ej1b(char* filename);

int main() {
    srand(0);
    remove(filename_ej1);
    test_ej1a(filename_ej1);
    test_ej1b(filename_ej1);
    return 0;
}

#define LIST_SIZE 20
#define NUM_LIST 4
#define NUM_USERS 7

uint32_t shuffle_int(uint32_t min, uint32_t max){
	return (uint32_t) (rand() % (max + 1)) + min;
}

void test_ej1a(char* filename) {
    uint8_t (*func_contar_aprobados)(list_t*, char*);
    uint8_t (*func_contar_rechazados)(list_t*, char*);
    if (USE_ASM_IMPL) {
        func_contar_aprobados = contar_pagos_aprobados_asm;
        func_contar_rechazados = contar_pagos_rechazados_asm;
    } else {
        func_contar_aprobados = contar_pagos_aprobados;
        func_contar_rechazados = contar_pagos_rechazados;
    }

    FILE* pfile = fopen(filename, "a");

    fprintf(pfile, "== Ejercicio 1a ==\n\n");
    char clientes[NUM_USERS][10] = {"susan", "bob", "nicolas", "gabi", "tini", "orne", "fransa"};

    for (int j = 0; j < NUM_LIST; ++j) {
        list_t* list = listNew();
        
        pago_t p[20];
        for (int i = 0; i < LIST_SIZE; ++i) {
            uint8_t pagador_idx = shuffle_int(1, 1024) % NUM_USERS;
            uint8_t cobrador_idx = shuffle_int(1, 1024) % NUM_USERS;
            p[i].monto = shuffle_int(1, 10);
            p[i].aprobado = shuffle_int(1, 1024) % 2;
            p[i].pagador = clientes[pagador_idx];
            p[i].cobrador = clientes[cobrador_idx];
            listAddLast(list, &p[i]);
        }

        for (int i = 0; i < NUM_USERS; ++i) {
            uint8_t aprobados = func_contar_aprobados(list, clientes[i]);
            uint8_t rechazados = func_contar_rechazados(list, clientes[i]);
            fprintf(pfile, "Cliente %s: %d %d\n", clientes[i], aprobados, rechazados);
        }
        listDelete(list);
    }

    fclose(pfile);
}

void test_ej1b(char* filename) {
    pagoSplitted_t* (*func_split)(list_t*, char*);
    if (USE_ASM_IMPL) {
        func_split = split_pagos_usuario_asm;
    } else {
        func_split = split_pagos_usuario;
    }

    FILE* pfile = fopen(filename, "a");

    fprintf(pfile, "== Ejercicio 1b ==\n\n");
    char clientes[NUM_USERS][10] = {"susan", "bob", "nicolas", "gabi", "tini", "orne", "fransa"};

    for (int j = 0; j < NUM_LIST; ++j) {
        list_t* list = listNew();

        pago_t p[20];
        for (int i = 0; i < LIST_SIZE; ++i) {
            uint8_t pagador_idx = shuffle_int(1, 1024) % NUM_USERS;
            uint8_t cobrador_idx = shuffle_int(1, 1024) % NUM_USERS;
            p[i].monto = shuffle_int(1, 10);
            p[i].aprobado = shuffle_int(1, 1024) % 2;
            p[i].pagador = clientes[pagador_idx];
            p[i].cobrador = clientes[cobrador_idx];
            listAddLast(list, &p[i]);
        }

        for (int i = 0; i < NUM_USERS; ++i) {
            pagoSplitted_t* splitted = func_split(list, clientes[i]);
            fprintf(pfile, "Cliente %s: %d %d\n", clientes[i], splitted->cant_aprobados, splitted->cant_rechazados);

            fprintf(pfile, "  Aprobados: ");
            for (int j = 0; j < splitted->cant_aprobados; ++j) {
                fprintf(pfile, "%d %s ", splitted->aprobados[j]->monto, splitted->aprobados[j]->pagador);
            }
            fprintf(pfile, "\n");

            fprintf(pfile, "  Rechazados: ");
            for (int j = 0; j < splitted->cant_rechazados; ++j) {
                fprintf(pfile, "%d %s ", splitted->rechazados[j]->monto, splitted->rechazados[j]->pagador);
            }
            fprintf(pfile, "\n");

            free(splitted->aprobados);
            free(splitted->rechazados);
            free(splitted);
        }
        listDelete(list);
    }

    fclose(pfile);
}

