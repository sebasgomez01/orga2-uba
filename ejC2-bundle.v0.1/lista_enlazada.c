#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

// malloc me reserva memoria para la lista y me devuelve un puntero al lugar de memoria reservado
// o un puntero nulo en el caso de que no se puede reservar memoria, por eso chequeo si es null
lista_t* nueva_lista(void) {
    lista_t* lista = (lista_t*)malloc(sizeof(lista_t));
    if (lista != NULL) {
        lista->head = NULL;  // Inicializar el puntero head a NULL
    }
    return lista;
}

uint32_t longitud(lista_t* lista) {
	if(lista->head == NULL) {
		return 0;
	} else {
		uint32_t longitud = 1;
		nodo_t nodoActual = *lista->head;
		while(nodoActual.next != NULL) {
			longitud++;
			nodoActual = *nodoActual.next;
		}
		return longitud;
	}
}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {
	nodo_t nodoNuevo;
	nodoNuevo.next = NULL;
	nodoNuevo.longitud = longitud;
	nodoNuevo.arreglo = arreglo;
	if(lista->head == NULL) {
		lista->head = &nodoNuevo;
	} else {
		nodo_t nodoActual = *lista->head;
		while(nodoActual.next != NULL) {
			nodoActual = *nodoActual.next;
		}
		nodoActual.next = &nodoNuevo;
	}
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {
	uint32_t contador = 0;
	nodo_t nodoActual = *lista->head;
	while(contador != i) {
		contador++;
		nodoActual = *nodoActual.next;
	}
	nodo_t* result = &nodoActual;
	return result;
}


uint64_t cantidad_total_de_elementos(lista_t* lista) {
	if(lista->head == NULL) {
		return 0;
	} else {
		nodo_t nodoActual = *lista->head;
		uint64_t result = nodoActual.longitud;
		while(nodoActual.next != NULL) {
			nodoActual = *nodoActual.next;
			result += nodoActual.longitud;
		}
		return result;
	}
	
}

void imprimir_lista(lista_t* lista) {
}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {
	uint64_t i = 0;
	while(i < size_of_array) {
		if(*array == elemento_a_buscar) {
			return 1;
		}
		array++;
		i++;
	}
	return 0;
}

int lista_contiene_elemento(lista_t* lista, uint32_t elemento_a_buscar) {
	if(lista->head != NULL) {
		nodo_t nodoActual = *lista->head;
		if(array_contiene_elemento(nodoActual.arreglo, nodoActual.longitud, elemento_a_buscar)) {
			return 1;
		}
		while(nodoActual.next != NULL) {
			nodoActual = *nodoActual.next;
			if(array_contiene_elemento(nodoActual.arreglo, nodoActual.longitud, elemento_a_buscar)) {
			return 1;
			}
		}
		return 0;

	} else {
		return 0;
	}
}


// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t* lista) {
}