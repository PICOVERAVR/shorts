// A program to discover as many things as possible about the host environment
// using nothing more than the C standard library.
// Written in C11.

#include <stdlib.h>
#include <stdio.h>
#include <limits.h> // for type size checking
#include <stdint.h> // for checking fast integer types
#include <math.h> // for FP_FAST_FMA*

#include <stddef.h> // for alignment checking
#include <stdalign.h>
#include <setjmp.h> // for querying jmp_buf

#include <signal.h> // for catching runtime errors
#include <time.h>

#if __STDC_VERSION__ < 201112L
#error standard revisions before C11 are not supported!
#endif

#if __STDC_HOSTED__ != 1
#warning implementation is not hosted - some standard headers may not be available
#endif

#ifndef __STDC_NO_THREADS__
#include <threads.h>
#endif

#ifndef __STDC_NO_ATOMICS__
#include <stdatomic.h>

void atomics() {
	const char* lock_ans[] = {
		"never",
		"sometimes",
		"always"
	};

	printf("bool is lock-free: %s\n", lock_ans[ATOMIC_BOOL_LOCK_FREE]);
	printf("char is lock-free: %s\n", lock_ans[ATOMIC_CHAR_LOCK_FREE]);
	printf("char16_t is lock-free: %s\n", lock_ans[ATOMIC_CHAR16_T_LOCK_FREE]);
	printf("char32_t is lock-free: %s\n", lock_ans[ATOMIC_CHAR32_T_LOCK_FREE]);
	printf("wchar_t is lock-free: %s\n", lock_ans[ATOMIC_WCHAR_T_LOCK_FREE]);
	printf("short is lock-free: %s\n", lock_ans[ATOMIC_SHORT_LOCK_FREE]);
	printf("int is lock-free: %s\n", lock_ans[ATOMIC_INT_LOCK_FREE]);
	printf("long is lock-free: %s\n", lock_ans[ATOMIC_LONG_LOCK_FREE]);
	printf("long long is lock-free: %s\n", lock_ans[ATOMIC_LLONG_LOCK_FREE]);
	printf("pointer is lock-free: %s\n", lock_ans[ATOMIC_POINTER_LOCK_FREE]);

	printf("\n");
}
#endif

#ifndef __STDC_NO_COMPLEX__
#include <complex.h>
#endif

void c_types() {
	printf("char: %d bits, [%d, %d]\n", CHAR_BIT, CHAR_MIN, CHAR_MAX);
	printf("short: %ld bytes, [%d, %d]\n", sizeof(short), SHRT_MIN, SHRT_MAX);
	printf("unsigned short: %ld bytes, [0, %u]\n", sizeof(unsigned short), USHRT_MAX);
	printf("int: %ld bytes, [%d, %d]\n", sizeof(int), INT_MIN, INT_MAX);
	printf("unsigned int: %ld bytes, [0, %u]\n", sizeof(unsigned int), UINT_MAX);
	printf("long: %ld bytes, [%ld, %ld]\n", sizeof(long), LONG_MIN, LONG_MAX);
	printf("unsigned long: %ld bytes, [0, %lu]\n", sizeof(unsigned long), ULONG_MAX);
	printf("long long: %ld bytes, [%lld, %lld]\n", sizeof(long long), LLONG_MIN, LLONG_MAX);
	printf("unsigned long long: %ld bytes, [0, %llu]\n", sizeof(unsigned long long), ULLONG_MAX);

	printf("\n");
}

void std_types() {
	printf("int_fast8_t: %ld bytes, %ld byte aligned\n", sizeof(int_fast8_t), alignof(int_fast8_t));
	printf("uint_fast8_t: %ld bytes, %ld byte aligned\n", sizeof(uint_fast8_t), alignof(uint_fast8_t));
	printf("int_fast16_t: %ld bytes, %ld byte aligned\n", sizeof(int_fast16_t), alignof(int_fast16_t));
	printf("uint_fast16_t: %ld bytes, %ld byte aligned\n", sizeof(uint_fast16_t), alignof(uint_fast16_t));
	printf("int_fast32_t: %ld bytes, %ld byte aligned\n", sizeof(int_fast32_t), alignof(int_fast32_t));
	printf("uint_fast32_t: %ld bytes, %ld byte aligned\n", sizeof(uint_fast32_t), alignof(uint_fast32_t));
	printf("int_fast64_t: %ld bytes, %ld byte aligned\n", sizeof(int_fast64_t), alignof(int_fast64_t));
	printf("uint_fast64_t: %ld bytes, %ld byte aligned\n\n", sizeof(uint_fast64_t), alignof(uint_fast64_t));

	printf("int_least8_t: %ld bytes, %ld byte aligned\n", sizeof(int_least8_t), alignof(int_least8_t));
	printf("uint_least8_t: %ld bytes, %ld byte aligned\n", sizeof(uint_least8_t), alignof(uint_least8_t));
	printf("int_least16_t: %ld bytes, %ld byte aligned\n", sizeof(int_least16_t), alignof(int_least16_t));
	printf("uint_least16_t: %ld bytes, %ld byte aligned\n", sizeof(uint_least16_t), alignof(uint_least16_t));
	printf("int_least32_t: %ld bytes, %ld byte aligned\n", sizeof(int_least32_t), alignof(int_least32_t));
	printf("uint_least32_t: %ld bytes, %ld byte aligned\n", sizeof(uint_least32_t), alignof(uint_least32_t));
	printf("int_least64_t: %ld bytes, %ld byte aligned\n", sizeof(int_least64_t), alignof(int_least64_t));
	printf("uint_least64_t: %ld bytes, %ld byte aligned\n\n", sizeof(uint_least64_t), alignof(uint_least64_t));

	printf("intptr_t: %ld bytes, %ld byte aligned\n", sizeof(intptr_t), alignof(intptr_t));
	printf("uintptr_t: %ld bytes, %ld byte aligned\n\n", sizeof(uintptr_t), alignof(uintptr_t));

	printf("ptrdiff_t: %ld bytes, %ld byte aligned\n", sizeof(ptrdiff_t), alignof(ptrdiff_t));
	printf("intmax_t: %ld bytes\n", sizeof(intmax_t));
	printf("uintmax_t: %ld bytes\n", sizeof(uintmax_t));
	printf("max_align_t: %ld bytes\n", alignof(max_align_t));
	printf("size_t: %ld bytes\n", sizeof(size_t));
	printf("wchar_t: %ld bytes, %ld byte aligned\n", sizeof(wchar_t), alignof(wchar_t));

	printf("\n");
}

void comptime() {

	// optional language features

#ifdef __STDC_NO_VLA__
	printf("variable length arrays not supported\n");
#endif

#ifndef __STDC_NO_THREADS__
	printf("threads.h is present\n");
#else
	printf("threads.h is not present\n");
#endif

	// math features

#ifdef FP_FAST_FMAF
	printf("float fma(x, y, z) possibly faster than x * y + z\n");
#else
	printf("float fma(x, y, z) possibly slower than x * y + z\n");
#endif

#ifdef FP_FAST_FMA
	printf("double fma(x, y, z) possibly faster than x * y + z\n");
#else
	printf("double fma(x, y, z) possibly slower than x * y + z\n");
#endif

#ifdef FP_FAST_FMAL
	printf("long double fma(x, y, z) possibly faster than x * y + z\n");
#else
	printf("long double fma(x, y, z) possibly slower than x * y + z\n");
#endif

	// encoding features

#ifdef __STDC_UTF_16__
	printf("char16_t is UTF-16 encoded\n");
#endif

#ifdef __STDC_UTF_32__
	printf("char32_t is UTF-32 encoded\n");
#endif

	// misc features

#ifdef __cplusplus
	printf("compiled with a c++ compiler\n");
#else
	printf("compiled with a c compiler\n");
#endif

#ifdef NDEBUG
	printf("assertions disabled (release build?)\n");
#else
	printf("assertions enabled (debug build?)\n");
#endif

	printf("\n");
}

#ifdef __GNUC__
// non-standard macros available on GCC and Clang
void gcc_compat() {
	printf("compiler version: \"%s\"\n", __VERSION__);

#if __PIC__ == 1
	printf("pic: on (with GOT limits)\n");
#elif __PIC__ == 2
	printf("pic: on (without GOT limits)\n");
#else
	printf("pic: off\n");
#endif

	printf("\n");
}
#endif

void host() {

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

	printf("__FILE__: %s\n", __FILE__);
	printf("__DATE__: %s\n", __DATE__);
	printf("__TIME__: %s\n", __TIME__);

	// host specific information

	printf("max rand() return value: %d\n", RAND_MAX);

	printf("min number of concurrent open files: %d\n", FOPEN_MAX);
	printf("max filename length: %d bytes\n", FILENAME_MAX);

	// may want to set locale here

	printf("max bytes in mb char (current locale): %ld\n", MB_CUR_MAX);
	printf("max bytes in mb char (any locale): %d\n", MB_LEN_MAX);

	clock_t t1 = clock();
	clock_t t2 = clock();

	clock_t clocks = t2 - t1;
	double sec = ((double)clocks) / CLOCKS_PER_SEC;
	//double ms = ((double)(t2 - t1)) / CLOCKS_PER_SEC * 1000.0;
	//double us = ((double)(t2 - t1)) / CLOCKS_PER_SEC * 1000000.0;
	//double ns = ((double)(t2 - t1)) / CLOCKS_PER_SEC * 1000000000.0;
	printf("empty statement took %f sec\n", sec);

	printf("\n");
}

void hacks() {
	typedef union {
		uint32_t u32;
		uint8_t u8[4];
	} end_t;

	char *end;
	end_t impl;
	impl.u32 = 0xFF;
	if (impl.u8[0] == 0xFF) {
		end = "little";
	} else if (impl.u8[3] == 0xFF) {
		end = "big";
	} else {
		end = "?";
	}

	// static_assert(offsetof(end_t, u8[3]) == 3, "little endian")
	printf("endianness: %s\n", end);

	printf("jmp_buf size: %ld bytes\n", sizeof(jmp_buf));

	printf("\n");
}

void signal_handler(int signal) {
	char* sig_str;
	switch (signal) {
		case SIGABRT:
			sig_str = "SIGABRT";
			break;
		case SIGFPE:
			sig_str = "SIGFPE";
			break;
		case SIGILL:
			sig_str = "SIGILL";
			break;
		case SIGINT:
			sig_str = "SIGINT";
			break;
		case SIGSEGV:
			sig_str = "SIGSEGV";
			break;
		case SIGTERM:
			sig_str = "SIGTERM";
			break;
		default:
			sig_str = "??";
	}

	printf("caught signal %d (%s)\n", signal, sig_str);
}

int main(int argc, char **argv) {
	// register all signals with our handler in case things go wrong
	signal(SIGABRT, signal_handler);
	signal(SIGFPE, signal_handler);
	signal(SIGILL, signal_handler);
	signal(SIGINT, signal_handler);
	signal(SIGSEGV, signal_handler);
	signal(SIGTERM, signal_handler);

	std_types();

	comptime();

#ifndef __STDC_NO_ATOMICS__
	printf("atomic.h is present\n");
	atomics();
#else
	printf("atomic.h is not present\n");
#endif

	gcc_compat();

	printf("%d arg(s):\n", argc);
	for (int i = 0; i < argc; i++) {
		printf("    \"%s\"\n", argv[i]);
	}
	printf("\n");
	host();

	hacks();

	return EXIT_SUCCESS;
}

