#include <stdio.h>

void comptime() {

	printf("compile-time macros:\n");

#ifdef __STDC_NO_VLA__
	printf("\tvariable length arrays not supported\n");
#endif

#ifdef __cplusplus
	printf("\tcompiled with a c++ compiler\n");
#else
	printf("\tcompiled with a c compiler\n");
#endif

#ifdef NDEBUG
	printf("\tassertions disabled (release build?)\n");
#else
	printf("\tassertions enabled (debug build?)\n");
#endif

#ifdef __STDC_UTF_16__
	printf("\tchar16_t is UTF-16 encoded\n");
#endif

#ifdef __STDC_UTF_32__
	printf("\tchar32_t is UTF-32 encoded\n");
#endif

	printf("\n");
}

