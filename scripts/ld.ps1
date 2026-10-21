<#
.SYNOPSIS
    Prints a line repeatedly, replacing the placeholder with the current counter.

.EXAMPLE
    .\ld.ps1 "Hello World @i!" 1 4
.EXAMPLE
    .\ld.ps1 "Password#n" 1 2 5 -Placeholder "#n"

.NOTES
    The placeholder defaults to "@i" (or $env:LD_PLACEHOLDER) and is matched literally.
#>
param(
    [Parameter(Mandatory, Position = 0)] [string] $Text,
    [Parameter(Mandatory, Position = 1)] [int] $Start,
    [Parameter(Mandatory, Position = 2)] [int] $StepOrEnd,
    [Parameter(Position = 3)] [Nullable[int]] $End,
    [string] $Placeholder
)

if (-not $Placeholder) {
    if ($env:LD_PLACEHOLDER) { $Placeholder = $env:LD_PLACEHOLDER } else { $Placeholder = '@i' }
}

if ($null -eq $End) {
    $Step = 1
    $End = $StepOrEnd
} else {
    $Step = $StepOrEnd
}

if ($Step -lt 1) { throw 'STEP must be at least 1' }

for ($i = $Start; $i -le $End; $i += $Step) {
    $Text.Replace($Placeholder, [string]$i)
}
