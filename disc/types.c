#include <stdint.h>
#include <limits.h>
#include <stdalign.h>
#include <stddef.h>
#include <stdio.h>

#include "types.h"

void c_types() {
	printf("traditional C types:\n");

	printf("\tchar: %d bits, [%d, %d]\n", CHAR_BIT, CHAR_MIN, CHAR_MAX);
	printf("\tshort: %ld bytes, [%d, %d]\n", sizeof(short), SHRT_MIN, SHRT_MAX);
	printf("\tunsigned short: %ld bytes, [0, %u]\n", sizeof(unsigned short), USHRT_MAX);
	printf("\tint: %ld bytes, [%d, %d]\n", sizeof(int), INT_MIN, INT_MAX);
	printf("\tunsigned int: %ld bytes, [0, %u]\n", sizeof(unsigned int), UINT_MAX);
	printf("\tlong: %ld bytes, [%ld, %ld]\n", sizeof(long), LONG_MIN, LONG_MAX);
	printf("\tunsigned long: %ld bytes, [0, %lu]\n", sizeof(unsigned long), ULONG_MAX);
	printf("\tlong long: %ld bytes, [%lld, %lld]\n", sizeof(long long), LLONG_MIN, LLONG_MAX);
	printf("\tunsigned long long: %ld bytes, [0, %llu]\n", sizeof(unsigned long long), ULLONG_MAX);

	printf("\n");
}

#define PRINT_SZ_ALN(T, name) printf("\t%s: %ld bytes, %ld byte aligned\n", name, sizeof(T), alignof(T))

void std_types() {
	printf("standard C types:\n");

	PRINT_SZ_ALN(int_fast8_t, "int_fast8_t");
	PRINT_SZ_ALN(uint_fast8_t, "uint_fast8_t");
	PRINT_SZ_ALN(int_fast16_t, "int_fast16_t");
	PRINT_SZ_ALN(uint_fast16_t, "uint_fast16_t");
	PRINT_SZ_ALN(int_fast32_t, "int_fast32_t");
	PRINT_SZ_ALN(uint_fast32_t, "uint_fast32_t");
	PRINT_SZ_ALN(int_fast64_t, "int_fast64_t");
	PRINT_SZ_ALN(uint_fast64_t, "uint_fast64_t");
	printf("\n");

	PRINT_SZ_ALN(int_least8_t, "int_least8_t");
	PRINT_SZ_ALN(uint_least8_t, "uint_least8_t");
	PRINT_SZ_ALN(int_least16_t, "int_least16_t");
	PRINT_SZ_ALN(uint_least16_t, "uint_least16_t");
	PRINT_SZ_ALN(int_least32_t, "int_least32_t");
	PRINT_SZ_ALN(uint_least32_t, "uint_least32_t");
	PRINT_SZ_ALN(int_least64_t, "int_least64_t");
	PRINT_SZ_ALN(uint_least64_t, "uint_least64_t");
	printf("\n");

	PRINT_SZ_ALN(intmax_t, "intmax_t");
	PRINT_SZ_ALN(uintmax_t, "uintmax_t");
	PRINT_SZ_ALN(max_align_t, "max_align_t");
	PRINT_SZ_ALN(size_t, "size_t");
	PRINT_SZ_ALN(wchar_t, "wchar_t");
	PRINT_SZ_ALN(intptr_t, "intptr_t");
	PRINT_SZ_ALN(uintptr_t, "uintptr_t");
	PRINT_SZ_ALN(ptrdiff_t, "ptrdiff_t");

	printf("\n");
}

