#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "ejercicios.h"
#include "ejercicios.c"

int main (void){
	/* Acá pueden realizar sus propias pruebas */
	int number = 42;
	fprintf(stdout, "El número es: %d\n", number);

	uint32_t* vector;
	vector = (uint32_t*)malloc(16 * sizeof(uint32_t));
	uint32_t* pointer = vector;
	for (uint32_t i = 0; i < 16; ++i) {
		*pointer = 2;
		pointer++;
	}
	uint32_t suma;
	suma = sumarElementosVector(vector);
	fprintf(stdout, "La suma es: %d\n", suma);

}

