# line-duplicator
Simple line duplicator with iteration.

Prints a line repeatedly, replacing every occurrence of a placeholder (`@i` by default)
with the current counter value.

Two equivalent scripts are available in the `scripts` directory:
- `ld.sh` - Bash (Linux, macOS, Git Bash on Windows)
- `ld.ps1` - PowerShell (Windows)

## Usage
```
ld.sh  TEXT START END
ld.sh  TEXT START STEP END

ld.ps1 TEXT START END [-Placeholder PLACEHOLDER]
ld.ps1 TEXT START STEP END [-Placeholder PLACEHOLDER]
```
`STEP` defaults to 1 and must be at least 1.

## Example of use
1. Duplicate n times.
```
./ld.sh "Hello!" 1 4
```
Above command produce:
```
Hello!
Hello!
Hello!
Hello!
```
2. Duplicate n times with iteration.
```
./ld.sh "Hello World @i!" 1 4
```
Above command produce:
```
Hello World 1!
Hello World 2!
Hello World 3!
Hello World 4!
```
3. Duplicate with iteration step.
```
.\ld.ps1 "User @i" 1 2 7
```
Above command produce:
```
User 1
User 3
User 5
User 7
```

## Custom placeholder
The placeholder is matched literally (not as a regular expression), so any text can be used.

Bash - set the `LD_PLACEHOLDER` environment variable:
```
LD_PLACEHOLDER='#n' ./ld.sh "Password#n" 1 3
```
PowerShell - use the `-Placeholder` parameter (or `$env:LD_PLACEHOLDER`):
```
.\ld.ps1 "Password#n" 1 3 -Placeholder "#n"
```
Both produce:
```
Password1
Password2
Password3
```

## Running as `ld`
Bash - add an alias to `~/.bashrc`:
```
alias ld='/path/to/line-duplicator/scripts/ld.sh'
```
Note: on Linux `ld` is also the GNU linker - the alias only shadows it in interactive shells,
but you may prefer a different name, e.g. `ldup`.

PowerShell - add an alias to your profile (`notepad $PROFILE`):
```
Set-Alias ld 'C:\path\to\line-duplicator\scripts\ld.ps1'
```
If PowerShell refuses to run the script, allow local scripts once:
```
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

## Tests
Run the same test cases against both scripts (PowerShell cases are skipped when PowerShell is not installed):
```
tests/run-tests.sh
```
The tests also run on GitHub Actions on Ubuntu and Windows for every push and pull request.
