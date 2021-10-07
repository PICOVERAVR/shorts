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

# SSE string compare immediate bits
.equ Smd_imm_ubyte_op, 0
.equ Smd_imm_uword_op, 1
.equ Smd_imm_sbyte_op, 2
.equ Smd_imm_sword_op, 3
.equ Smd_imm_cmp_eq_any, 0 # find any char in set in string
.equ Smd_imm_cmp_range, 4 # comparing "az" means all chars from a to z
.equ Smd_imm_cmp_eq_each, 8 # strcmp
.equ Smd_imm_cmp_eq_order, 12 # substring search
.equ Smd_imm_neg_pol, 16
.equ Smd_imm_mask_neg_pol, 48
.equ Smd_imm_least_sig, 0
.equ Smd_imm_most_sig, 64
.equ Smd_imm_bit_mask, 0
.equ Smd_imm_uint_mask, 64

# ecx: int argc
# rdx: char **argv
# r8: char **env

# lldb:
# find addr: disas -n <label>
# print reg: reg read <reg>

.global _start

.text

# read text into str (*MM), putting reverse mask in mask (*MM) and number of chars in count (GPR)
.macro Read str, mask, count
read\@:
	# read()
	mov $0, %rax
	mov $0, %rdi
	mov %r9, %rsi
	mov $1, %rdx
	syscall

	# insert the current string index in mask
	vpslldq $1, \mask, \mask
	pinsrb $0, \count, \mask

	# insert the character read in str
	vpslldq $1, \str, \str
	pinsrb $0, (%r9), \str

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
	# un-get break token
	vpsrldq $1, \str, \str
	vpsrldq $1, \mask, \mask # TODO: introduces garbage in xmm1 because this is logical, not arith

	vpshufb \mask, \str, \str # reverse *mm0 using ymm1 mask and zero unused chars
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

	# write()
	mov $1, %rax
	lea newline, %r9
	mov $1, %rdx
	syscall
.endm

.macro Jmp_str str, cmp, dst
	pcmpistri $Smd_imm_cmp_eq_each + Smd_imm_neg_pol, \cmp, \str
	jnb \dst # jmp if CF = 0, CF = 0 if bytes in string differ
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
	Print prompt, $3
	Read %xmm0, %xmm1, %r10

check:
	# handle builtins
	Jmp_str %xmm0, cmd_version, version
	Jmp_str %xmm0, cmd_exit, exit

	# 0. check for avx2
	# 1. parse based on PATH
	# 3. use fork
	# 4. compress argv usage
	# 5. expand ~
	# 6. test, debug, and stop (do grad apps)

	vmovdqu %xmm0, (%r9) # write xmm0

	# argv[0] = %r9 (cmd)
	# argv[1] = NULL
	mov %r9, Argv(%r9)
	movq $0, 24(%r9)

	# execve()
	mov $59, %rax
	lea Cmd(%r9), %rdi # name
	lea Argv(%r9), %rsi # argv
	mov %r8, %rdx # copy envp
	syscall

	jmp error

version:
	Print ver_msg, $(ver_msg_end - ver_msg)
	jmp reset

exit:
	mov $60, %rax
	xor %rdi, %rdi
	syscall

error:
	Print err_msg, $6
	jmp reset

cmd_version:
	.asciz "version"
cmd_exit:
	.asciz "exit"

err_msg:
	.asciz "what?\n"
err_msg_end:

prompt:
	.asciz "$ "
prompt_end:

ver_msg:
	.asciz "smdsh v0.1\n"
ver_msg_end:

newline:
	.byte '\n'

