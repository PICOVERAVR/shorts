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

void std_types() {
	printf("standard C types:\n");

	printf("\tint_fast8_t: %ld bytes, %ld byte aligned\n", sizeof(int_fast8_t), alignof(int_fast8_t));
	printf("\tuint_fast8_t: %ld bytes, %ld byte aligned\n", sizeof(uint_fast8_t), alignof(uint_fast8_t));
	printf("\tint_fast16_t: %ld bytes, %ld byte aligned\n", sizeof(int_fast16_t), alignof(int_fast16_t));
	printf("\tuint_fast16_t: %ld bytes, %ld byte aligned\n", sizeof(uint_fast16_t), alignof(uint_fast16_t));
	printf("\tint_fast32_t: %ld bytes, %ld byte aligned\n", sizeof(int_fast32_t), alignof(int_fast32_t));
	printf("\tuint_fast32_t: %ld bytes, %ld byte aligned\n", sizeof(uint_fast32_t), alignof(uint_fast32_t));
	printf("\tint_fast64_t: %ld bytes, %ld byte aligned\n", sizeof(int_fast64_t), alignof(int_fast64_t));
	printf("\tuint_fast64_t: %ld bytes, %ld byte aligned\n\n", sizeof(uint_fast64_t), alignof(uint_fast64_t));

	printf("\tint_least8_t: %ld bytes, %ld byte aligned\n", sizeof(int_least8_t), alignof(int_least8_t));
	printf("\tuint_least8_t: %ld bytes, %ld byte aligned\n", sizeof(uint_least8_t), alignof(uint_least8_t));
	printf("\tint_least16_t: %ld bytes, %ld byte aligned\n", sizeof(int_least16_t), alignof(int_least16_t));
	printf("\tuint_least16_t: %ld bytes, %ld byte aligned\n", sizeof(uint_least16_t), alignof(uint_least16_t));
	printf("\tint_least32_t: %ld bytes, %ld byte aligned\n", sizeof(int_least32_t), alignof(int_least32_t));
	printf("\tuint_least32_t: %ld bytes, %ld byte aligned\n", sizeof(uint_least32_t), alignof(uint_least32_t));
	printf("\tint_least64_t: %ld bytes, %ld byte aligned\n", sizeof(int_least64_t), alignof(int_least64_t));
	printf("\tuint_least64_t: %ld bytes, %ld byte aligned\n\n", sizeof(uint_least64_t), alignof(uint_least64_t));

	printf("\tintmax_t: %ld bytes\n", sizeof(intmax_t));
	printf("\tuintmax_t: %ld bytes\n", sizeof(uintmax_t));
	printf("\tmax_align_t: %ld bytes\n", alignof(max_align_t));
	printf("\tsize_t: %ld bytes\n", sizeof(size_t));
	printf("\twchar_t: %ld bytes, %ld byte aligned\n\n", sizeof(wchar_t), alignof(wchar_t));

	printf("\tintptr_t: %ld bytes, %ld byte aligned\n", sizeof(intptr_t), alignof(intptr_t));
	printf("\tuintptr_t: %ld bytes, %ld byte aligned\n", sizeof(uintptr_t), alignof(uintptr_t));

	printf("\tptrdiff_t: %ld bytes, %ld byte aligned\n", sizeof(ptrdiff_t), alignof(ptrdiff_t));

	printf("\n");
}

