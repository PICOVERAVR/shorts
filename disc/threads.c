#include <stdio.h>

#include "threads.h"

#ifndef __STDC_NO_THREADS__
void threads() {
	printf("C11 threads are supported\n");

	printf("\n");
}
#else
void threads() {
	printf("C11 threads are not supported\n");
}
#endif

