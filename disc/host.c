#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <time.h>

#include "host.h"

#if __STDC_HOSTED__ != 1
#warning implementation is not hosted - some standard headers may not be available
#endif

void host() {

	printf("host settings:\n");

	printf("\t__FILE__: %s\n", __FILE__);
	printf("\t__DATE__: %s\n", __DATE__);
	printf("\t__TIME__: %s\n", __TIME__);

	printf("\tmax rand() return value: %d\n", RAND_MAX);

	printf("\tmin number of concurrent open files: %d\n", FOPEN_MAX);
	printf("\tmax filename length: %d bytes\n", FILENAME_MAX);

	printf("\tmax bytes in mb char (current locale): %ld\n", MB_CUR_MAX);
	printf("\tmax bytes in mb char (any locale): %d\n", MB_LEN_MAX);

	printf("\n");
}

