#!/usr/bin/env zsh

this_script=${0:a}

main () {
	setopt err_exit pipe_fail
	local -a help keep show_output

	zparseopts -D -K -F -- \
		-show-output=show_output \
		-keep=keep \
		{h,-help}=help

	if [[ $? != 0 ]] ; then
		usage >&2
		exit 1
	elif [[ -n $help ]] ; then
		usage
		exit 0
	fi

	# Optionally accept paths to tests to run. Directories will be recursed into.
	local tests=($@)
	if [[ $#tests == 0 ]] ; then
		tests=(tests)
	fi

	local source_root=$(pwd)
	local working_root=$(mktemp -d)
	integer succeeded=0 failed=0

	if [[ $keep ]] ; then
		echo "Running tests in $working_root"
	fi

	IFS=$'\n'
	for f in $(find $tests -type f) ; do
		if run_test "$show_output" "$source_root" "$working_root" "$f" ; then
			succeeded=$(( succeeded + 1 ))
		else
			failed=$(( failed + 1 ))
		fi
	done

	if [[ ! $keep ]] ; then
		rm -rf $working_root
	fi

	echo "Tests complete: ${succeeded} succeeded, ${failed} failed."
	if [[ $failed > 0 ]] ; then
		exit 1
	fi
}

usage () {
  cat <<END
Usage: run-tests.zsh [--help] [--show-output] [--keep] [test-files]

  --help         Show this message.
  --show-output  Show output from all tests, not just the ones that fail.
  --keep         Keep the test working directory instead of deleting it.

test-files:
  Optional path to tests to run. If a path is a directory, it will run all
  files found within the directory.

  Default: ./tests
END
}

run_test () {
	local show_output=$1
	local source_root=${2:A}
	local working_root=${3:A}
	local test_file=$4

	mkdir -p $working_root/$test_file

	setopt local_options no_err_exit
	SHLVL=0 HOME=$working_root/$test_file SOURCE=$source_root TEST=$test_file \
	zsh -l "$this_script" --subshell &>$working_root/$test_file.out

	local code=$?
	if [[ $code != 0 ]] ; then
		echo Test $test_file failed with code $code:
		cat $working_root/$test_file.out | sed -e 's/^/  /'
		echo
		return 1
	elif [[ $show_output ]] ; then
		echo Test $test_file succeeded:
		cat $working_root/$test_file.out
		echo
	fi
}

# Inside a subshell in run_test
subshell () {
	setopt err_exit

	cd $SOURCE
	local test_abs=${TEST:A}

	setopt null_glob
	local helpers=(test-*.zsh)
	setopt no_null_glob
	for file in $helpers ; do
		source $file
	done

	cd
	try_command before_test
	source "$test_abs"
	try_command after_test
}

try_command () {
	if command -v "$1" &>/dev/null ; then
		"$@"
	fi
}

# Utility functions for tests

# Print a message to stderr and exit
#
# fail "message" [exit_code]
fail () {
	echo "$1" >&2
	exit ${2:-1}
}

# Check that the expected number of arguments were passed
#
# check_arguments "function_name" number "$@"
check_arguments () {
	local func=$1
	local expected=$2
	shift ; shift
	if [[ $# != $expected ]] ; then
		print "$func expected $expected arguments but got $#:" >&2
		printf "  %s\n" ${(q+)@} >&2
		exit 1
	fi
}

# Assert two strings are equal
#
# assert_eq actual expected
assert_eq () {
	check_arguments assert_eq 2 "$@"
	if [[ "$1" != "$2" ]] ; then
		fail "Not equal:\n  actual:   ${(q+)1}\n  expected: ${(q+)2}"
	fi
}

if [[ "$*" == '--subshell' ]] ; then
	subshell
else
	main "$@"
fi
