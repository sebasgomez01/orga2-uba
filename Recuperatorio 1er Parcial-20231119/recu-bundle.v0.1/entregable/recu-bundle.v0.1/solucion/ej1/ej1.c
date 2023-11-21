#include "ej1.h"

uint32_t* acumuladoPorCliente(uint8_t cantidadDePagos, pago_t* arr_pagos){
}

uint8_t en_blacklist(char* comercio, char** lista_comercios, uint8_t n){
	uint8_t result = 0;
	for (uint8_t i = 0; i < n; ++i)
	{
		if(lista_comercios[i] == comercio) {
			result = 1;
			return result;
		}
	}
	return result;
}

pago_t** blacklistComercios(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios){
}

uint8_t pagosAComerciosEnBlacklist(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios) {
	uint8_t result = 0;
	for(uint8_t i = 0; i < cantidad_pagos; i++) {
		result += en_blacklist(arr_pagos[i].comercio, arr_comercios, size_comercios);
	}
	return result;
}
