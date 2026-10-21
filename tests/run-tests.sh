#!/usr/bin/env bash
# Runs the same test cases against ld.sh and ld.ps1.
# PowerShell cases are skipped when neither pwsh nor powershell is available.

cd "$(dirname "$0")/.." || exit 1

impls=(sh)
if command -v pwsh >/dev/null; then
    ps=pwsh
elif command -v powershell >/dev/null; then
    ps=powershell
fi
if [ -n "$ps" ]; then
    impls+=(ps1)
else
    echo "PowerShell not found - skipping ld.ps1"
fi

passed=0
failed=0

# Runs one implementation; sets $out (without CR characters) and $status.
run() { # IMPL ARGS...
    local impl=$1
    shift
    if [ "$impl" = sh ]; then
        out=$(scripts/ld.sh "$@" 2>/dev/null)
    else
        out=$("$ps" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File scripts/ld.ps1 "$@" 2>/dev/null)
    fi
    status=$?
    out=${out//$'\r'/}
}

pass() {
    passed=$((passed + 1))
    echo "PASS [$1] $2"
}

fail() {
    failed=$((failed + 1))
    echo "FAIL [$1] $2"
}

# Expects a successful run with the given output (lines separated by \n).
check() { # IMPL NAME EXPECTED ARGS...
    local impl=$1 name=$2 expected
    expected=$(printf '%b' "$3")
    shift 3
    run "$impl" "$@"
    if [ "$status" -eq 0 ] && [ "$out" = "$expected" ]; then
        pass "$impl" "$name"
    else
        fail "$impl" "$name"
        echo "  expected (exit 0):"
        printf '%s\n' "$expected" | sed 's/^/    /'
        echo "  actual (exit $status):"
        printf '%s\n' "$out" | sed 's/^/    /'
    fi
}

# Expects a failed run with no output on stdout.
check_error() { # IMPL NAME ARGS...
    local impl=$1 name=$2
    shift 2
    run "$impl" "$@"
    if [ "$status" -ne 0 ] && [ -z "$out" ]; then
        pass "$impl" "$name"
    else
        fail "$impl" "$name"
        echo "  expected a non-zero exit code and no output, got exit $status:"
        printf '%s\n' "$out" | sed 's/^/    /'
    fi
}

for impl in "${impls[@]}"; do
    check "$impl" "duplicates without placeholder" 'Hello!\nHello!\nHello!\nHello!' "Hello!" 1 4
    check "$impl" "replaces placeholder" 'Hello World 1!\nHello World 2!\nHello World 3!\nHello World 4!' "Hello World @i!" 1 4
    check "$impl" "uses step" 'User 1\nUser 3\nUser 5\nUser 7' "User @i" 1 2 7
    check "$impl" "skips values past end" '1\n6' "@i" 1 5 10
    check "$impl" "replaces every occurrence" '1-1\n2-2' "@i-@i" 1 2
    check "$impl" "supports negative numbers" '-2\n-1\n0' "@i" -2 0
    check "$impl" "prints nothing when start is past end" '' "@i" 5 1
    LD_PLACEHOLDER='#it' check "$impl" "custom placeholder from env" 'Password1\nPassword3\nPassword5' "Password#it" 1 2 5
    LD_PLACEHOLDER='$i' check "$impl" "placeholder with special characters" 'A 1 100%!\nA 2 100%!' 'A $i 100%!' 1 2
    LD_PLACEHOLDER='.' check "$impl" "placeholder is not a regex" 'a1b\na2b' "a.b" 1 2

    check_error "$impl" "rejects step 0" "@i" 1 0 5
    check_error "$impl" "rejects negative step" "@i" 1 -2 5
    check_error "$impl" "rejects too few arguments" "@i" 1
    check_error "$impl" "rejects too many arguments" "@i" 1 1 5 6
    check_error "$impl" "rejects non-integer" "@i" a 3
done

if [ -n "$ps" ]; then
    check ps1 "custom placeholder from parameter" 'Password1\nPassword2\nPassword3' "Password#n" 1 3 -Placeholder "#n"
fi

echo
echo "Passed: $passed, failed: $failed"
[ "$failed" -eq 0 ]
