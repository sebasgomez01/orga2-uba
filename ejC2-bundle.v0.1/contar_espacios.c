#include "contar_espacios.h"
#include <stdio.h>

uint32_t longitud_de_string(char* string) {
    if(string == NULL) {
        return 0;
    } else {
        uint32_t longitud = 0;
        while(*string != 0) {
            longitud++;
            string++;
        }
        return longitud;
    }
}

uint32_t contar_espacios(char* string) {
     if(string == NULL || *string == '\0') {
        return 0;
    } else {
        uint32_t espacios = 0;
        while(*string != 0) {
            if(*string == ' ') {
                espacios++;
            }
            string++;
        }
        return espacios;
    }
}

// Pueden probar acá su código (recuerden comentarlo antes de ejecutar los tests!)
/*
int main() {

    printf("1. %d\n", contar_espacios("hola como andas?"));

    printf("2. %d\n", contar_espacios("holaaaa orga2"));
}
*/