#include <stdio.h>

#ifndef __STDC_NO_ATOMICS__
#include <stdatomic.h>

#include "atomics.h"

void atomics() {
	const char* lock_ans[] = {
		"never",
		"sometimes",
		"always"
	};

	printf("atomics:\n");
	printf("\tbool is lock-free: %s\n", lock_ans[ATOMIC_BOOL_LOCK_FREE]);
	printf("\tchar is lock-free: %s\n", lock_ans[ATOMIC_CHAR_LOCK_FREE]);
	printf("\tchar16_t is lock-free: %s\n", lock_ans[ATOMIC_CHAR16_T_LOCK_FREE]);
	printf("\tchar32_t is lock-free: %s\n", lock_ans[ATOMIC_CHAR32_T_LOCK_FREE]);
	printf("\twchar_t is lock-free: %s\n", lock_ans[ATOMIC_WCHAR_T_LOCK_FREE]);
	printf("\tshort is lock-free: %s\n", lock_ans[ATOMIC_SHORT_LOCK_FREE]);
	printf("\tint is lock-free: %s\n", lock_ans[ATOMIC_INT_LOCK_FREE]);
	printf("\tlong is lock-free: %s\n", lock_ans[ATOMIC_LONG_LOCK_FREE]);
	printf("\tlong long is lock-free: %s\n", lock_ans[ATOMIC_LLONG_LOCK_FREE]);
	printf("\tpointer is lock-free: %s\n", lock_ans[ATOMIC_POINTER_LOCK_FREE]);

	printf("\n");
}
#else
void atomics() {
	printf("C11 atomics are not supported\n\n");
}
#endif

