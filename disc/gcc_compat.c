#include <stdio.h>

#include "gcc_compat.h"

#ifdef __GNUC__
// non-standard macros available on GCC and Clang
void gcc_compat() {
	printf("gcc (or compatible) settings:\n");

	printf("\tcompiler version: \"%s\"\n", __VERSION__);

	printf("\tpic: ");
#if __PIC__ == 1
	printf("on (with GOT limits)\n");
#elif __PIC__ == 2
	printf("on (without GOT limits)\n");
#else
	printf("off\n");
#endif

	printf("\n");
}
#else
void gcc_compat() {}
#endif

