#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <assert.h>
#include <errno.h>
#include "ej2.h"

#define H 20
#define W 12

static bgra_t a[H][W];
static bgra_t b[H][W];
static bgra_t c[H][W];

void shuffle(uint32_t max){
	for (int i = 0; i < H; i++) {
        for (int j = 0; j < W; j++){
            uint8_t n= (uint8_t) rand() % max;
            a[i][j].r = n;
            a[i][j].g = n+1;
            a[i][j].b = n+2;
            a[i][j].a = 255;
            
            b[i][j].r = n;
            b[i][j].g = n-1;
            b[i][j].b = n-2;
            a[i][j].a = 255;
                
            c[i][j].r = (uint8_t) rand() % max;
            c[i][j].g = (uint8_t) rand() % max;
            c[i][j].b = (uint8_t) rand() % max;
            a[i][j].a = 255;
        }
	}
}

char *filename_ej2 =  "salida.propios.ej2.txt";
void test_ej2(char* filename);

int main() {
    srand(0);
    remove(filename_ej2);
    test_ej2(filename_ej2);
    return 0;
}

void print_res(FILE* pfile, uint8_t* res) {
    for (int i = 0; i < H; ++i) {
        for (int j = 0; j < W; ++j) {
            fprintf(pfile, "%3d ", res[(i * W + j) * 4 + 0]); // Blue
            fprintf(pfile, "%3d ", res[(i * W + j) * 4 + 1]); // Green
            fprintf(pfile, "%3d ", res[(i * W + j) * 4 + 2]); // Red
            fprintf(pfile, "%3d ", res[(i * W + j) * 4 + 3]); // Alpha
        }
        fprintf(pfile, "\n");
    }
}

void test_ej2(char* filename) {

    uint8_t* res = malloc(H * W * 4);
    
    void (*func_mezclarColores)(uint8_t*, uint8_t*, uint32_t, uint32_t);
    if (USE_ASM_IMPL) {
        func_mezclarColores = mezclarColores;
    } else {
        func_mezclarColores = mezclarColores_c;
    }

    FILE* pfile = fopen(filename, "a");;
    shuffle(INT32_MAX);
    fprintf(pfile, "== Ejercicio 2 ==\n\n");

    fprintf(pfile, "== Creciente ==\n\n");
    func_mezclarColores((uint8_t*)a, res, W, H);
    print_res(pfile, res);


    fprintf(pfile, "\n== Random ==\n\n");
    func_mezclarColores((uint8_t*)c, res, W, H);
    print_res(pfile, res);

    fprintf(pfile, "\n== Decreciente==\n\n");
    func_mezclarColores((uint8_t*)c, res, W, H);
    print_res(pfile, res);

    fclose(pfile);
    free(res);
}

