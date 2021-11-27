#include <stdio.h>
#ifndef __STDC_NO_COMPLEX__
#include <complex.h>
#endif

#include <fenv.h>

#include "floats.h"

#ifdef __STDC_NO_COMPLEX__
void imag() {
	printf("complex.h does not exist\n\n");
}
#else
void imag() {

#ifdef __STDC_IEC_559__
	printf("\t__STDC_IEC_559__ is defined\n");
#endif

	// this doesn't mean imaginary numbers are supported!
#ifdef __STDC_IEC_559_COMPLEX__
	printf("\t__STDC_IEC_559_COMPLEX__ is defined\n");
#endif

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
    printf("\tlong double fma(x, y, z) possibly slower than x * y + z\n\n");
#endif

	printf("\trounding method: ");
    switch (fegetround()) {
        case FE_TONEAREST:
            printf("FE_TONEAREST (rounding towards nearest representable value)\n");
            break;
        case FE_DOWNWARD:
            printf("FE_DOWNWARD (rounding towards negative infinity)\n");
            break;
        case FE_UPWARD:
            printf("FE_UPWARD (rounding towards positive infinity)\n");
            break;
        case FE_TOWARDZERO:
            printf("FE_TOWARDZERO (rounding towards zero)\n");
            break;
        default:
            printf("unknown\n");
    };

    printf("\n");
}

