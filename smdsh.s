# shell entirely within AVX registers
#
# rules:
# 1. no heap memory allocation (malloc, brk, mmap, etc)
# 2. no stack allocation (meaning the adjustment of rbp or rsp)
#      a. red zones are fair game but vary by OS and architecture
# 3. no calling libraries that violate rules 1 or 2 (including libc)
# 4. using memory that is already allocated at the start of the program is ok, but don't abuse it
# 5. storing read only data in .text is ok
#
# to run:
# $ clang -nostdlib smdsh.s -o smdsh && ./smdsh

# memory I can use:
# x86 registers, r8 - r15
# SSE/AVX/AVX2 registers (don't have AVX512)
# x87 float registers (8, can use FILD/FIST to load/store integers)
# 128-byte red zone after rsp

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

# ecx: int argc
# rdx: char **argv
# r8: char **env

# lldb:
# find addr: disas -n <label>
# print reg: reg read <reg>

.global _start

.text

# read text into str (XMM), putting reverse mask in mask (XMM) and number of chars in count (GPR)
.macro Read str, mask, count
read\@:
	# read()
	mov $0, %rax
	mov $0, %rdi
	mov %r9, %rsi
	mov $1, %rdx
	syscall

	# insert the current string index in ymm1
	vpslldq $1, \mask, \mask
	pinsrb $0, \count, %xmm1

	# insert the character read in ymm0
	vpslldq $1, \str, \str
	pinsrb $0, (%r9), %xmm0

	# increment and wrap index
	inc \count
	and $0x1F, \count

	# test for \n, \t, space (done with command)
	cmpb $'\n', (%r9)
	jz strip\@

	cmpb $'\t', (%r9)
	jz strip\@

	cmpb $' ', (%r9)
	jz strip\@

	jmp read\@

strip\@:
	# un-get break token and corresponding mask index
	vpsrldq $1, \str, \str
	vpsrldq $1, \mask, \mask

	vpshufb \mask, \str, \str # reverse ymm0 using ymm1 mask and zero unused chars
.endm

.macro Print label, len
	# write()
	mov $1, %rax
	mov $1, %rdi
	lea \label, %rsi
	mov \len, %rdx
	syscall
.endm

.macro Println label, len
	Print \label, \len

	# add newline
	mov $1, %rax
	lea newline, %r9
	mov $1, %rdx
	syscall
.endm

.equ Cmd, 0
.equ Argv, 16

_start:
	lea -128(%rsp), %r9 # legal red zone is rsp - 1 to rsp - 128

reset:
	# set ymm0 = 0
	vpxor %ymm0, %ymm0, %ymm0

	# set ymm1 = 0xFF...FF
	mov $0xFF, %r10
	pinsrb $0, %r10, %xmm1
	vpbroadcastb %xmm1, %ymm1

	mov $0, %r10

parse:
	Print prompt, $4
	Read %xmm0, %xmm1, %r10
	vmovdqu %xmm0, (%r9) # write ymm0

	# argv[0] = %r9 (cmd)
	# argv[1] = NULL
	mov %r9, 16(%r9)
	movq $0, 24(%r9)

	# execve()
	mov $59, %rax
	lea Cmd(%r9), %rdi # name
	lea Argv(%r9), %rsi # argv
	mov %r8, %rdx # copy envp
	syscall

	cmpq $0, %rax
	jge reset

error:
	Print errmsg, $6
	jmp reset

end:
	mov $60, %rax
	xor %rdi, %rdi
	syscall

errmsg:
	.asciz "what?\n"

prompt:
	.asciz "-> "

newline:
	.byte '\n'

