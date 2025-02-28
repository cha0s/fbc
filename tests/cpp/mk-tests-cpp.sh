#!/usr/bin/env bash

set -e

# TODO: select gas or gas64 based on host

# determine make or gmake

osname="`uname -s`"
case "$osname" in
FreeBSD*)
	MAKECMD="gmake CC=gcc CXX=g++"
	;;
*)
	MAKECMD="make"
	;;
esac

echo $MAKCMD

function chk() {
	testname="$1"
	if [ -z $2 ]; then
		genopt=
	fi
	genopt="-gen $2"
	rm -f $testname-cpp.o
	$MAKECMD -f $testname.bmk CFLAGS="-O0 -gstabs"
	fbc -g $genopt -exx $testname-fbc.bas $testname-cpp.o -x $testname-fbc.exe
	echo "Testing: $testname $genopt"
	./$testname-fbc.exe
}

function do_clean() {
	rm -f $1-cpp.o
	rm -f $1-fbc.exe
	rm -f $1-fbc.o
}

function do_clean_all() {
	do_clean "mangle"
	do_clean "call"
	do_clean "call2"
	do_clean "this"
	do_clean "class"
	do_clean "bop"
	do_clean "fbcall"
	do_clean "derived"
}

function chk_all() {
	gen="$1"
	chk "mangle" "$gen"
	chk "call" "$gen"
	chk "call2" "$gen"
	chk "this" "$gen"
	chk "class" "$gen"
	chk "bop" "$gen"
	chk "fbcall" "$gen"
	chk "derived" "$gen"
}

case "$1" in
all)
	chk_all "gas"
#	chk_all "gas64"
	chk_all "gcc"
	;;
mangle|call|call2|this|class|bop|fbcall|derived)
	chk "$1" "gas"
#	chk "$1" "gas64"
	chk "$1" "gcc"
	;;
clean)
	do_clean_all
	;;
*)
	echo "expected all|clean"
	echo "         mangle|call|call2|this|class|bop|fbcall|derived"
	;;
esac

