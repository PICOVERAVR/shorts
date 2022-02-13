#!/usr/bin/env sh

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
	"
	exit
fi

case $1 in
	hardware)
		shift
		perf stat -d -d -d "$@"
		;;
	hardware_rep)
		rept=$1
		shift
		perf stat -d -d -d -r "$@"
		;;
	execute)
		shift
		perf record "$@" && perf report && rm perf.data
		;;
	*)
		echo "unknown option!"
esac

