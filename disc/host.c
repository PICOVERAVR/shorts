#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <time.h>

#include "host.h"

void c_rev() {
	char* version;
	if (__STDC_VERSION__ == 199409L) {
		version = "C89";
	} else if (__STDC_VERSION__ == 199901L) {
		version = "C99";
	} else if (__STDC_VERSION__ == 201112L) {
		version = "C11";
	} else if (__STDC_VERSION__ == 201710L) {
		version = "C17";
	} else {
		version = "C2x or C++xx?";
	}

	printf("C standard revision: %s (%ld)\n", version, __STDC_VERSION__);
}

void host() {

	printf("host settings:\n");

	printf("\t__FILE__: %s\n", __FILE__);
	printf("\t__DATE__: %s\n", __DATE__);
	printf("\t__TIME__: %s\n", __TIME__);

	// host specific information

	printf("\tmax rand() return value: %d\n", RAND_MAX);

	printf("\tmin number of concurrent open files: %d\n", FOPEN_MAX);
	printf("\tmax filename length: %d bytes\n", FILENAME_MAX);

	// may want to set locale here

	printf("\tmax bytes in mb char (current locale): %ld\n", MB_CUR_MAX);
	printf("\tmax bytes in mb char (any locale): %d\n", MB_LEN_MAX);

	clock_t t1 = clock();
	clock_t t2 = clock();

	clock_t clocks = t2 - t1;
	double sec = ((double)clocks) / CLOCKS_PER_SEC;
	//double ms = ((double)(t2 - t1)) / CLOCKS_PER_SEC * 1000.0;
	//double us = ((double)(t2 - t1)) / CLOCKS_PER_SEC * 1000000.0;
	//double ns = ((double)(t2 - t1)) / CLOCKS_PER_SEC * 1000000000.0;
	printf("\tempty statement took %f sec\n", sec);

	printf("\n");
}

