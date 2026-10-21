<#
.SYNOPSIS
    Prints a line repeatedly, replacing the placeholder with the current counter.

.DESCRIPTION
    Usage: ld.ps1 TEXT START END [-Placeholder PLACEHOLDER]
           ld.ps1 TEXT START STEP END [-Placeholder PLACEHOLDER]

.EXAMPLE
    .\ld.ps1 "Hello World @i!" 1 4
.EXAMPLE
    .\ld.ps1 "Password#n" 1 2 5 -Placeholder "#n"

.NOTES
    The placeholder defaults to "@i" (or $env:LD_PLACEHOLDER) and is matched literally.
    Positional arguments are parsed by the script itself, so negative numbers work
    also when it is started with "powershell -File".
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [string] $Placeholder,
    [Parameter(ValueFromRemainingArguments)] [string[]] $Arguments
)

function Stop-WithError([string] $Message) {
    [Console]::Error.WriteLine($Message)
    exit 1
}

if (-not $Placeholder) {
    if ($env:LD_PLACEHOLDER) { $Placeholder = $env:LD_PLACEHOLDER } else { $Placeholder = '@i' }
}

if ($Arguments.Count -eq 3) {
    $Text, $StartArg, $EndArg = $Arguments
    $StepArg = '1'
} elseif ($Arguments.Count -eq 4) {
    $Text, $StartArg, $StepArg, $EndArg = $Arguments
} else {
    Stop-WithError ("Usage: ld.ps1 TEXT START END | ld.ps1 TEXT START STEP END`n" +
        "Example: ld.ps1 `"Hello World $Placeholder!`" 1 2 10")
}

$Start = 0; $Step = 0; $End = 0
foreach ($pair in @(@($StartArg, [ref]$Start), @($StepArg, [ref]$Step), @($EndArg, [ref]$End))) {
    if ($pair[0] -notmatch '^-?[0-9]+$' -or -not [int]::TryParse($pair[0], $pair[1])) {
        Stop-WithError "Not an integer: $($pair[0])"
    }
}

if ($Step -lt 1) { Stop-WithError 'STEP must be at least 1' }

for ($i = $Start; $i -le $End; $i += $Step) {
    $Text.Replace($Placeholder, [string]$i)
}
