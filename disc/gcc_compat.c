#include <stdio.h>

#include "gcc_compat.h"

#ifdef __GNUC__
// non-standard macros available on gcc (or possibly on other gcc-compatible compilers)
void gcc_compat() {
	printf("gcc (or compatible) settings:\n");

	printf("\tcompiler version: \"%s\"\n", __VERSION__);

	printf("\t64-bit pointers: %s\n", _LP64 ? "yes" : "no");

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
void gcc_compat() {
	printf("probably not a gcc compatible compiler\n\n");
}
#endif

