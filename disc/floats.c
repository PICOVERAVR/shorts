#include <stdio.h>
#ifndef __STDC_NO_COMPLEX__
#include <complex.h>
#endif

#include "floats.h"

#ifdef __STDC_NO_COMPLEX__
void imag() {
	printf("complex.h does not exist\n\n");
}
#else
void imag() {
#ifdef _Imaginary_I
	printf("imaginary numbers are supported\n");
#endif

	printf("\n");
}
#endif

void floats() {

	printf("floats:\n");

#ifdef FP_FAST_FMAF
    printf("\tfloat fma(x, y, z) possibly faster than x * y + z\n");
#else
    printf("\tfloat fma(x, y, z) possibly slower than x * y + z\n");
#endif

#ifdef FP_FAST_FMA
    printf("\tdouble fma(x, y, z) possibly faster than x * y + z\n");
#else
    printf("\tdouble fma(x, y, z) possibly slower than x * y + z\n");
#endif

#ifdef FP_FAST_FMAL
    printf("\tlong double fma(x, y, z) possibly faster than x * y + z\n");
#else
    printf("\tlong double fma(x, y, z) possibly slower than x * y + z\n");
#endif
}

