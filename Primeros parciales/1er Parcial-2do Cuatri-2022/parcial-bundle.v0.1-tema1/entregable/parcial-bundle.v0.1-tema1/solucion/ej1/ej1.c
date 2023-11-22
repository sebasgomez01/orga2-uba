#include "ej1.h"


/* Idea de la implemetación
    Lo primero que tengo que hacer es reservar memoria para el arreglo a devolver, este arreglo tendrá MAX_TAGS número de elementos,
    y cada elemento va a tener un tamaño de 8 bytes, pues son punteros a punteros de char
    
*/
char** agrupar_c(msg_t* msgArr, size_t msgArr_len){
    char** result = calloc(MAX_TAGS, 8);
    char** copyResult = result;
    size_t tamañoAReservarPorTag[MAX_TAGS] = {0};

    // Obtengo el tamaño de la concatenación de los text para cada tag
    for (size_t i = 0; i < msgArr_len; i++)
    {
        tamañoAReservarPorTag[msgArr[i].tag] += msgArr[i].text_len + 1; // le sumo 1 porque el tamaño no cuenta el caracter nulo 
    }
    
    // Pido memoria para cada uno de los arreglos que voy a formar con la concatenación de los text  de igual tag, y guardo los punteros en el arreglo a devolver
    for (size_t i = 0; i < MAX_TAGS; i++)
    {
        char* pointer = calloc(tamañoAReservarPorTag[i], 1);
        result[0] = pointer;
    }

    // Ahora tengo que concatenar los strings en la posición de memoria correspondiente

    for (size_t i = 0; i < msgArr_len; i++)
    {
        result[msgArr[i].tag] += msgArr[i].text_len + 1; // le sumo 1 porque el tamaño no cuenta el caracter nulo 
    }

    

    
}
