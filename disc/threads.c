#include <stdio.h>

#include "threads.h"

#ifndef __STDC_NO_THREADS__
void threads() {
	printf("threads.h is present\n");

	printf("\n");
}
#else
void threads() {
	printf("threads.h is not present\n");
}
#endif

