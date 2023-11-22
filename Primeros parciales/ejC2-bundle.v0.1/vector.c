#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


vector_t* nuevo_vector(void) {
	vector_t* vector = (vector_t*)malloc(sizeof(vector_t));
	if(vector != NULL) {
		vector->size = 0;
		vector->capacity = 2;
		uint32_t* array = (uint32_t*)malloc(sizeof(uint32_t) * 2);
		vector->array = array;
	}
	return vector;
}

uint64_t get_size(vector_t* vector) {
	if(vector != NULL) {
		return vector->size;
	}
	return 0;
}

void push_back(vector_t* vector, uint32_t elemento) {
	if(vector->size == vector->capacity) {
		uint32_t* nuevaPosicion = reallocarray(vector->array, 2*vector->capacity, sizeof(uint32_t)); 
		vector->array = nuevaPosicion;
		vector->capacity = 2*vector->capacity;
	}	

	*(vector->array + vector->size) = elemento;
	vector->size++;
}

int son_iguales(vector_t* v1, vector_t* v2) {
	if(v1->size == v2->size) {
		int result = 1;
		for(uint64_t i = 0; i < v1->size; i++) {
			if(iesimo(v1, i) != iesimo(v2, i)) {
				return 0;
			}
		}
		return result;
	}
	return 0;

}

uint32_t iesimo(vector_t* vector, size_t index) {
	if(index < vector->size) {
		uint32_t result = *(vector->array + index);
		return result;
	}
	return 0;
}

void copiar_iesimo(vector_t* vector, size_t index, uint32_t* out) {
	uint32_t elemACopiar = iesimo(vector, index);
	*out = elemACopiar;  
}


// Dado un array de vectores, devuelve un puntero a aquel con mayor longitud.
vector_t* vector_mas_grande(vector_t** array_de_vectores, size_t longitud_del_array) {
	if(longitud_del_array == 0) {
		return NULL;
	}

	vector_t* result = array_de_vectores[0];
	for(size_t i = 1; i < longitud_del_array; i++) {
		if(result->size < array_de_vectores[i]->size) {
			result = array_de_vectores[i];
		} 
	}	
	return result;
}

/* Primera versión de vector_mas_grande, preguntar por qué no funciona

vector_t* vector_mas_grande(vector_t** array_de_vectores, size_t longitud_del_array) {
	if(longitud_del_array == 0) {
		return NULL;
	}

	vector_t* result = *array_de_vectores;
	for(size_t i = 1; i < longitud_del_array; i++) {
		if(result->size < (result + i)->size) {
			result = result + i;
		} 
	}	
	return result;
}

*/