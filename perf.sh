#!/usr/bin/env sh

SVG_VIEWER=brave

if ! command -v perf &> /dev/null
then
	echo "cannot find perf executable!"
	exit 1
fi

if test $# -lt 3;
then
	echo "usage: ./perf.sh <profile type> <count?> <program to profile> <program arguments>
    available profiling types:
        hardware: reports CPU hardware counters for the entire program
        hardware_rep <n>: repeat n times
        execute: shows a breakdown of execution time for the entire program
        flamegraph: generates a flamegraph of the execution time and opens the result in $SVG_VIEWER
	"
	exit
fi

case $1 in
	hardware)
		shift
		echo "NOTE: The final column indicates how much time a counter was active for (due to # events > # counters)."
		perf stat -d -d -d "$@"
		;;
	hardware_rep)
		rept=$1
		shift
		perf stat -d -d -d -r "$@"
		;;
	execute)
		shift
		perf record "$@" && perf report --hierarchy && rm perf.data*
		;;
	flame)
		# install the "cargo-flamegraph" package on Linux
		if ! command -v flamegraph &> /dev/null
		then
			echo "cannot find flamegraph executable!"
			exit 1
		fi
		shift
		flamegraph "$@" && $SVG_VIEWER flamegraph.svg && rm flamegraph.svg && rm perf.data*
		;;
	*)
		echo "unknown option!"
esac

