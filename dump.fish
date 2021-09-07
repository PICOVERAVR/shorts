#!/usr/bin/env fish

# A really simple shell script version of Godbolt's Compiler Explorer.
# Pretty-prints disassembly for a given function symbol in a binary.

# Not a lot of error checking here, use with care!

set -l nargs (count $argv)

if test $nargs -lt 2
	echo "Usage: ./dump.fish <executable> \"<fn>([args])\""
	exit 1
end

set -l bin $argv[1]

for fn in (seq 2 $nargs)
	set -l sym $argv[$fn]
	
	# the symbol table lists the main function as "main", not "main()"
	if test $sym = main\(\)
		set sym main
	end

	# check the symbol table, count matching functions
	set -l nmatches (objdump --demangle --section=.text --disassemble=$sym $bin | head -n 7 | grep -c $sym)
	
	# main is special and doesn't have parenthesis in the symbol table
	if test $nmatches -eq 1
		or test $sym = main
		# run full disassembly
		objdump --demangle --visualize-jumps=extended-color --section=.text --no-show-raw-insn --dwarf=follow-links --disassembler-options=intel --disassemble=$sym $bin | tail -n +7
	else
		# either no or multiple matches, print em
		echo "symbol $sym not found, listing possible matches."
		objdump --section=.text --demangle --syms $bin | grep $sym | cut --fields=2
		exit 1
	end
end

