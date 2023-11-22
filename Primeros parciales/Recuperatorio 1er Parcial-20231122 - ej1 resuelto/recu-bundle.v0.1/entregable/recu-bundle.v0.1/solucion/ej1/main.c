#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "ej1.h"

int main (void){
    char* comercio = "adidas";
    char** comercios = (char**)malloc(6*sizeof(char*));
    comercios[0]="adidas";
    comercios[1]="dia";
    comercios[2]="coto";
    comercios[3]="nike";
    comercios[4]="carrefour";
    comercios[5]="zara";
    uint8_t n = 6;

    uint8_t result = en_blacklist(comercio, comercios, n);
    printf("El valor de la variable 'numero' es: %d\n", result);
    free(comercios);


}


