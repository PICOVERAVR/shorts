# doing interesting things without user-level memory allocation
#
# rules:
# 1. no heap memory allocation (malloc, sbrk, mmap?, etc), with limited exceptions
# 2. no stack allocation (meaning the adjustment of rbp or rsp)
#      a. red zones are fair game but vary by OS and architecture
# 3. no calling libraries that violate rules 1 or 2
# 4. using memory that is already allocated at the start of the program is ok, but don't abuse it
#
# to run:
# $ clang -nostdlib old_mem.s -o old_mem && ./old_mem

# ideas:
# wozmon thing (maybe even a functional shell?)
# 80's shell programs
# BASIC
# calculator

.global _start

.text

_start:
	# legal red zone is rsp - 1 to rsp - 128 (4 AVX2 registers)

	mov $60, %rax
	xor %rdi, %rdi
	syscall

