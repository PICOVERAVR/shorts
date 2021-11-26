#include <stdio.h>
#include <stdint.h>
#include <setjmp.h>

#include "hw.h"

void hw() {

	printf("hardware tests:\n");

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
	printf("\tendianness: %s\n", end);

	printf("\tjmp_buf size: %ld bytes\n", sizeof(jmp_buf));

	printf("\n");
}

