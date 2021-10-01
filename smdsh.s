# shell? entirely within AVX registers
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

# SSE immediate encodings:
# _SIDD_UBYTE_OPS = 0
# _SIDD_UWORD_OPS = 1
# _SIDD_SBYTE_OPS = 2
# _SIDD_SWORD_OPS = 3
# _SIDD_CMP_EQUAL_ANY = 0
# _SIDD_CMP_RANGES = 4
# _SIDD_CMP_EQUAL_EACH = 8
# _SIDD_CMP_EQUAL_ORDERED = 12
# _SIDD_NEGATIVE_POLARITY = 16
# _SIDD_MASKED_NEGATIVE_POLARITY = 48
# _SIDD_LEAST_SIGNIFICANT = 0
# _SIDD_MOST_SIGNIFICANT = 64
# _SIDD_BIT_MASK = 0
# _SIDD_UINT_MASK = 64

# xmm0: input
# xmm1: input mask

# lldb:
# find addr: disas -n <label>
# print reg: reg read <reg>

.global _start

.text

_start:
	lea -128(%rsp), %r8 # legal red zone is rsp - 1 to rsp - 128

reset:
	# set xmm0 = 0
	vpxor %xmm0, %xmm0, %xmm0

	# set xmm1 = 0xFF...
	mov $0xFF, %r10
	pinsrb $0, %r10, %xmm1
	vpbroadcastb %xmm1, %xmm1

	mov $0, %r10

read:
	# read()
	mov $0, %rax
	mov $0, %rdi
	mov %r8, %rsi
	mov $1, %rdx
	syscall

	pslldq $1, %xmm1
	pinsrb $0, %r10, %xmm1

	pslldq $1, %xmm0
	pinsrb $0, (%r8), %xmm0

	inc %r10

	cmpb $'\n', (%r8)
	jnz read

	# un-get newline and mask
	psrldq $1, %xmm0
	psrldq $1, %xmm1

parse:
	pshufb %xmm1, %xmm0 # reverse xmm0 using xmm1 mask

	# perform parsing here

	movdqu %xmm0, (%r8) # write xmm0

print:
	mov $1, %rax
	mov $1, %rdi
	mov %r10, %rdx
	syscall

	# add newline
	mov $1, %rax
	movb $'\n', (%r8)
	mov $1, %rdx
	syscall

	jmp reset

end:
	mov $60, %rax
	xor %rdi, %rdi
	syscall

