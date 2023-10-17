#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "ejs.h"




int main (void){
	/* Acá pueden realizar sus propias pruebas */

	/* Test para strArrayNew */
	str_array_t* pointerStruct = strArrayNew(8);
	uint8_t realValue = pointerStruct->capacity;
	uint8_t expectedValue = 8;
	if(realValue == expectedValue) {
		printf("strArrayNew paso el test\n");
	} else {
		printf("strArrayNew no paso el test\n");
	}
	

	/* Test para strArrayGetSize y strArrayAddLast */
	expectedValue = 0;
	realValue = strArrayGetSize(pointerStruct);
	if(realValue == expectedValue) {
		printf("strArrayGetSize paso el test\n");
	} else {
		printf("strArrayGetSize no paso el test\n");
	}


	char* string1 = "Durazno Sangrando";
	char* string2 = "El jardín de los presentes";
	strArrayAddLast(pointerStruct, string1);
	strArrayAddLast(pointerStruct, string2);
	expectedValue = 2;
	realValue = strArrayGetSize(pointerStruct);
	if(realValue == expectedValue /* && pointerStruct->data[0] == string1 && pointerStruct->data[1] == string2 */) {
		printf("strArrayGetSize y strArrayAddLast pasaron el test\n");
	} else {
		printf("strArrayGetSize y strArrayAddLast no pasaron el test\n");
	}
	strArrayPrint(pointerStruct, stdout);

	/* Test para strArraySwap */



	return 0;    
}



