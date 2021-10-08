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

# commands:
# $ version
# $ exit
# <absolute path to executable>

# TODO:
# arg support
# wait() on parent
# checking stuff in PATH

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

.global _start

.text

# read text into str (*mm), putting reverse mask in mask (*mm) and number of chars in count (gpr)
.macro Read str, mask, count, is_cmd
L0_\@:
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

	# test if out of space in str
	cmp $16, \count
	jz L2_\@

	# test for \n, \t, space (done with command)
	cmpb $'\n', (%r9)
	jz L1_\@

.if \is_cmd > 0
	cmpb $'\t', (%r9)
	jz L1_\@

	cmpb $' ', (%r9)
	jz L1_\@
.endif

	jmp L0_\@

L1_\@:
	# un-get break token
	vpsrldq $1, \str, \str
	vpsrldq $1, \mask, \mask # TODO: introduces garbage in xmm1 because this is logical, not arith

	vpshufb \mask, \str, \str # reverse *mm0 using ymm1 mask and zero unused chars

L2_\@:
.endm

.macro Read_arg str, mask, count
	cmp $16, \count
	jl end\@
	mov $0, \count
	Read \str, \mask, \count, 0
	end\@:
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

# red zone memory map

# space to store command and args
.equ Argv_0, 0
.equ Argv_1, 16
.equ Argv_2, 32
.equ Argv_3, 48
.equ Argv_4, 64

# table of *argv elements
.equ Argv_ptr, 80

_start:
	lea -128(%rsp), %r9 # legal red zone is rsp - 1 to rsp - 128

	# find **env and put in r8
	mov (%rsp), %r8 # get argc
	lea 16(%rsp, %r8, 8), %r8 # put 16 + (rsp + r8 * 8) (**env) in r8
	mov (%r8), %r8 # put *env in r8

reset:
	.irp i, 0, 1, 2, 3, 4
		vpxor %xmm\i, %xmm\i, %xmm\i
	.endr

	# set xmm1 = 0xFF...FF
	mov $0xFF, %r10
	pinsrb $0, %r10, %xmm7
	vpbroadcastb %xmm7, %xmm7

	# zero out lengths
	mov $0, %r10
	mov $0, %r11

parse:
	Print prompt, $(prompt_end - prompt)
	Read %xmm0, %xmm7, %r10, 1

	# read 64 bytes of args
	.irp i, 1, 2, 3, 4
		Read_arg %xmm\i, %xmm7, %r10
	.endr

try_builtin:
	# handle builtins
	Jmp_str %xmm0, cmd_version, version
	Jmp_str %xmm0, cmd_exit, exit

try_exec:
	.irp i, 0, 1, 2, 3, 4
		vmovdqu %xmm\i, Argv_\i(%r9)
	.endr

	# TODO: assign args to argv array

	mov %r9, Argv_ptr(%r9)
	movq $0, (Argv_ptr + 8)(%r9)

	# fork()
	mov $57, %rax
	syscall

	# if child, call exec()
	cmp $0, %rax
	jz do_exec

wait_exec:
	# TODO: call into linux headers to use wait4
	jmp exit

do_exec:
	# execve()
	mov $59, %rax
	lea Argv_0(%r9), %rdi # create *filename
	lea Argv_ptr(%r9), %rsi # create **argv
	mov $0, %rdx # no environment variables because there's no way we would be able to write them all
	syscall

	Print err_msg, $(err_msg_end - err_msg)
	jmp exit # don't want to depend on exit being first builtin

exit:
	mov $60, %rax
	xor %rdi, %rdi
	syscall

version:
	Print ver_msg, $(ver_msg_end - ver_msg)
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

