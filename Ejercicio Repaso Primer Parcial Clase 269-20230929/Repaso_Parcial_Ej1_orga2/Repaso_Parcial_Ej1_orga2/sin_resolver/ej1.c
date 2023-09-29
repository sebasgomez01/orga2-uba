#include "ej1.h"

uint32_t* acumuladoPorCliente(uint8_t cantidadDePagos, pago_t* arr_pagos){
//<<<REMOVE>>>
  uint32_t* res=(uint32_t*)malloc(10*sizeof(uint32_t));
  for(int i=0;i<10;i++)res[i]=0;

  for(int i = 0;i<cantidadDePagos;i++){
    if(arr_pagos[i].aprobado==1){
      res[arr_pagos[i].cliente]+=arr_pagos[i].monto;
    }
  }
  return res;
//<<<REMOVE END>>>
}

uint8_t en_blacklist(char* comercio, char** lista_comercios, uint8_t n){
//<<<REMOVE>>>
  for(int i = 0; i<n; i++){
    if(strcmp(comercio, lista_comercios[i])==0) return 1;
  }
  return 0;
//<<<REMOVE END>>>
}

pago_t** blacklistComercios(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios){
//<<<REMOVE>>>
  int total = 0;
	for(int i=0;i<cantidad_pagos;i++){
    total += en_blacklist(arr_pagos[i].comercio,arr_comercios, size_comercios);
  }
  pago_t** res = (pago_t**) malloc(total * sizeof(pago_t*));
  uint8_t j=0;
  for(int i=0;i<cantidad_pagos;i++){
    uint8_t a = en_blacklist(arr_pagos[i].comercio,arr_comercios, size_comercios);
    if(a==1){
      res[j]=&arr_pagos[i];
      j++;
    }
  }
  return res;
//<<<REMOVE END>>>
}


