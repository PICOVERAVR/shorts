# shell entirely within AVX registers
#
# rules:
# 1. no heap memory allocation (malloc, brk, mmap, new processes, etc)
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
# $ <path to executable> <args>
# $ <something in /bin or /usr/bin> <args>

# no environment variable support

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
.equ Smd_imm_mask_end, 32 # ignore results past the end of the string
.equ Smd_imm_mask_neg_pol, 48
.equ Smd_imm_least_sig, 0
.equ Smd_imm_most_sig, 64
.equ Smd_imm_bit_mask, 0
.equ Smd_imm_uint_mask, 64

.global _start

.text

# fills xmm with fill (gpr)
.macro Reset_xmm_mask xmm, fill
	mov $0xFF, \fill
	pinsrb $0, \fill, \xmm
	vpbroadcastb \xmm, \xmm
.endm

# read text into str (*mm), putting reverse mask in mask (*mm) and number of chars in count (gpr)
.macro Read str, mask, count, take_single_word
	Reset_xmm_mask \mask, %r10
	mov $0, \count
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

	# increment index
	inc \count

	# test if out of space in str
	cmp $16, \count
	jz L2_\@

	# test for \n, \t, space (done with command)
	cmpb $'\n', (%r9)
	jz L1_\@

.if \take_single_word > 0
	cmpb $'\t', (%r9)
	jz L1_\@

	cmpb $' ', (%r9)
	jz L1_\@
.endif

	jmp L0_\@

L1_\@:
	# un-get break token
	vpsrldq $1, \str, \str
	vpsrldq $1, \mask, \mask # NOTE: introduces garbage in xmm1 because this is logical, not arith

L2_\@:
	vpshufb \mask, \str, \str # reverse str using mask and zero unused chars
.endm

# reads an argument (if all arguments have not been read)
.macro Read_arg str, mask, count
	cmpb $'\n', (%r9)
	jz end\@
	Read \str, \mask, \count, 1
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

# jumps to dst if str != cmp
.macro Jmp_str str, cmp, dst
	pcmpistri $Smd_imm_cmp_eq_each + Smd_imm_neg_pol, \cmp, \str
	jnb \dst # jmp if CF = 0, CF = 0 if bytes in string differ
.endm

# sets ecx to address of first occurrance of sub (xmm) in str (xmm)
# rcx set to -1 if no substring is found
.macro Str_str sub, str
	pcmpistri $Smd_imm_cmp_eq_order + Smd_imm_mask_end, \sub, \str
.endm

# red zone memory map

# space to store command and args
.equ Argv_0, 0
.equ Argv_1, 16
.equ Argv_2, 32
.equ Argv_3, 48

# table of *argv elements
.equ Argv_ptr, 64

_start:
	lea -128(%rsp), %r9 # legal red zone is rsp - 1 to rsp - 128

	# find **env and put in r8
	mov (%rsp), %r8 # get argc
	lea 16(%rsp, %r8, 8), %r8 # put 16 + (rsp + r8 * 8) (**env) in r8
	mov (%r8), %r8 # put *env in r8

reset:
	.irp i, 0, 1, 2, 3
		vpxor %xmm\i, %xmm\i, %xmm\i
	.endr

parse:
	Print prompt, $(prompt_end - prompt)

	# read 16 bytes of cmd
	Read %xmm0, %xmm7, %r10, 1

	# read up to 48 more bytes of arg if required
	Read_arg %xmm1, %xmm7, %r10
	Read_arg %xmm2, %xmm7, %r10
	Read_arg %xmm3, %xmm7, %r10

try_builtin:
	# handle builtins
	Jmp_str %xmm0, cmd_version, version
	Jmp_str %xmm0, cmd_exit, exit
	Jmp_str %xmm0, cmd_cd, cd

write_argv:
	# write out cmd and args
	.irp i, 0, 1, 2, 3
		vmovdqu %xmm\i, Argv_\i(%r9)
	.endr

	mov %r9, Argv_ptr(%r9)
	lea Argv_1(%r9), %r15

	# write xmm address to argv table if xmm reg is non zero
	.irp i, 1, 2, 3
		pextrb $0, %xmm\i, %r14
		cmp $0, %r14
		jz skip_\i
		mov %r15, (Argv_ptr + \i * 8)(%r9) # fill argv address
		jmp end_\i
	skip_\i:
		movq $0, (Argv_ptr + \i * 8)(%r9) # clear argv address (might have a stale address from last cmd)
	end_\i:
		add $16, %r15
	.endr

	movq $0, (Argv_ptr + 32)(%r9)

is_parent:
	# fork()
	mov $57, %rax
	syscall
	#mov $0, %rax

	# if child, call exec()
	cmp $0, %rax
	jz do_exec

wait_exec:
	# int waitid(int which, pid_t upid, <*struct>, int options, <*struct>)
	mov $247, %rax
	mov $0, %rdi # P_ALL (wait for any child to return, ignore upid)
	mov $0, %rsi # ignored because of P_ALL
	mov $0, %rdx # NULL struct ptr
	mov $4, %r10 # WEXITED (check which children exited)
	mov %r8, %r15 # save r8
	mov $0, %r8 # NULL struct ptr
	syscall

	mov %r15, %r8 # restore r8
	jmp reset

do_exec:
	# try cmd itself with execve()
	mov $59, %rax
	lea Argv_0(%r9), %rdi # create *filename
	lea Argv_ptr(%r9), %rsi # create **argv

	# no environment variables because there's no way we would be able to write a table for em all
	mov $0, %rdx
	syscall

	# try /bin/<exec>
	mov $59, %rax
	lea path_bin, %r15
	vpslldq $5, %xmm0, %xmm0
	pinsrd $0, (%r15), %xmm0
	pinsrb $4, 4(%r15), %xmm0
	vmovdqu %xmm0, Argv_0(%r9)
	syscall

	# try /usr/bin/<exec>
	mov $59, %rax
	lea path_usr_bin, %r15
	vpsrldq $5, %xmm0, %xmm0
	vpslldq $8, %xmm0, %xmm0
	pinsrq $0, (%r15), %xmm0
	pinsrb $8, 8(%r15), %xmm0
	vmovdqu %xmm0, Argv_0(%r9)
	syscall

	# error out if all three tries failed
	Print err_msg, $(err_msg_end - err_msg)

	# exit()
	mov $60, %rax
	mov $1, %rdi
	syscall

exit:
	mov $60, %rax
	xor %rdi, %rdi
	syscall

version:
	Print ver_msg, $(ver_msg_end - ver_msg)
	jmp reset

cd:
	# chdir()
	mov $80, %rax
	movdqu %xmm1, Argv_1(%r9)
	lea Argv_1(%r9), %rdi # new directory
	syscall

	jmp reset

cmd_version:
	.asciz "version"

cmd_exit:
	.asciz "exit"

cmd_cd:
	.asciz "cd"

err_msg:
	.asciz "what?\n"
err_msg_end:

prompt:
	.asciz "smdsh $ "
prompt_end:

ver_msg:
	.asciz "smdsh v0.1\n"
ver_msg_end:

space_msg:
	.asciz " "

path_bin:
	.asciz "/bin/"

path_usr_bin:
	.asciz "/usr/bin/"

