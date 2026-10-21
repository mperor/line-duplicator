#!/usr/bin/env bash
# Prints a line repeatedly, replacing the placeholder with the current counter.
#
# Usage: ld.sh TEXT START END
#        ld.sh TEXT START STEP END
#
# The placeholder defaults to "@i" and can be changed with LD_PLACEHOLDER.
# It is matched literally (not as a regex).

placeholder="${LD_PLACEHOLDER:-@i}"

usage() {
    echo "Usage: ld.sh TEXT START END | ld.sh TEXT START STEP END" >&2
    echo "Example: ld.sh \"Hello World $placeholder!\" 1 2 10" >&2
    exit 1
}

if [ $# -eq 3 ]; then
    text=$1 start=$2 step=1 end=$3
elif [ $# -eq 4 ]; then
    text=$1 start=$2 step=$3 end=$4
else
    usage
fi

for n in "$start" "$step" "$end"; do
    [[ $n =~ ^-?[0-9]+$ ]] || { echo "Not an integer: $n" >&2; exit 1; }
done
(( step >= 1 )) || { echo "STEP must be at least 1" >&2; exit 1; }
[ -n "$placeholder" ] || { echo "Placeholder must not be empty" >&2; exit 1; }

for (( i = start; i <= end; i += step )); do
    printf '%s\n' "${text//"$placeholder"/$i}"
done
