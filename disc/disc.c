// A program to discover as many things as possible about the host environment
// using nothing more than the C standard library.

#include <stdlib.h>
#include <stdio.h>

#include <signal.h> // for catching runtime errors

#include "atomics.h"
#include "comptime.h"
#include "floats.h"
#include "gcc_compat.h"
#include "host.h"
#include "hw.h"
#include "threads.h"
#include "types.h"

#if __STDC_VERSION__ < 201112L
#error standard revisions before C11 are not supported!
#endif

#if __STDC_HOSTED__ != 1
#warning implementation is not hosted - some standard headers may not be available
#endif

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
	(void)argc;
	(void)argv;

	// register all signals with our handler in case things go wrong
	signal(SIGABRT, signal_handler);
	signal(SIGFPE, signal_handler);
	signal(SIGILL, signal_handler);
	signal(SIGINT, signal_handler);
	signal(SIGSEGV, signal_handler);
	signal(SIGTERM, signal_handler);

	c_rev();
	gcc_compat();

	std_types();

	atomics();
	threads();
	comptime();

	host();

	hw();

	return EXIT_SUCCESS;
}

