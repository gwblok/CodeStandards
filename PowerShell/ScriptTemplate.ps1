#Requires -Version 5.1

<#
.SYNOPSIS
    Reports basic information about a file or directory.
.DESCRIPTION
    A read-only starting point for a standalone script. Replace this operation,
    help, and parameters with the intended task. Returns an object rather than
    formatted console text. No elevation or external modules are required.
.PARAMETER Path
    Literal file-system path to inspect. Defaults to this script's directory.
.EXAMPLE
    ./ScriptTemplate.ps1 -Path . -Verbose
.EXAMPLE
    ./ScriptTemplate.ps1 -Path (Join-Path $PSScriptRoot 'ScriptTemplate.ps1')
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Uses PowerShell 5.1-compatible syntax. Validate on each supported platform.
    Run as a script rather than dot-sourcing it into a caller's scope.
    Add SupportsShouldProcess and guard mutations if adapting it to change state.
#>
[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Path = $PSScriptRoot
)

$ErrorActionPreference = 'Stop'

try {
    Write-Verbose "Inspecting '$Path'."
    $Item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop

    if ($Item -isnot [System.IO.FileSystemInfo]) {
        throw 'Path must identify a file-system file or directory.'
    }

    [pscustomobject]@{
        Name = $Item.Name
        Path = $Item.FullName
        IsDirectory = $Item.PSIsContainer
        LastWriteTimeUtc = $Item.LastWriteTimeUtc
    }
} catch {
    throw "Unable to inspect '$Path': $($_.Exception.Message)"
}
