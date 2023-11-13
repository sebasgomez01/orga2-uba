#include "ejercicios.h"

uint32_t sumarElementosVector(uint32_t* vector) {
	uint32_t result = 0;
	for (int i = 0; i < 16; ++i) {
		result += *vector;
		vector++;
	}
	return result;
}