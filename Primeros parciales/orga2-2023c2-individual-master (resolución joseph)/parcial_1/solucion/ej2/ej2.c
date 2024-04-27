#include "ej2.h"

void mezclarColores_c(uint8_t* X, uint8_t* Y, uint32_t width, uint32_t height) {
    uint32_t row_size = width * height;
    unsigned char (*src_matrix)[row_size] = (unsigned char (*)[row_size]) X;
    unsigned char (*dst_matrix)[row_size] = (unsigned char (*)[row_size]) Y;

    for (uint32_t i_d = 0, i_s = 0; i_d < height; i_d++, i_s++) {
        for (uint32_t j_d = 0, j_s = 0; j_d < width; j_d++, j_s++) {

            bgra_t* p_d = (bgra_t*) &dst_matrix[i_d][j_d*4];
            bgra_t* p_s = (bgra_t*) &src_matrix[i_s][j_s*4];

            if((p_s)->r > (p_s)->g && (p_s)->g > (p_s)->b) {
                (p_d)->r = (p_s)->b;
                (p_d)->g = (p_s)->r;
                (p_d)->b = (p_s)->g;

            } else if ((p_s)->r < (p_s)->g && (p_s)->g < (p_s)->b) {
                (p_d)->r = (p_s)->g;
                (p_d)->g = (p_s)->b;
                (p_d)->b = (p_s)->r;

            } else {
                *p_d = *p_s;
            }

            (p_d)->a = 0;

        }
    }


}
