<#
.SYNOPSIS
    Demonstrates a documented PowerShell script skeleton.
.DESCRIPTION
    Provides a safe starting point for a new script. Replace this help, the
    template notes, and the example workflow with details for the new task.
.PARAMETER Name
    A sample value used to demonstrate a documented parameter.
.EXAMPLE
    .\ScriptTemplate.ps1 -Name 'Example'
    Writes a sample result for the supplied name.
.NOTES
    Author: CodeStandards contributors
    Created: 2026-10-30
    Change History:
        2026-10-30 - CodeStandards contributors - Initial template.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Name
)

# Replace this phase with the prerequisite checks and setup for the new script.
Write-Verbose "Starting the template example for '$Name'."

# Replace this phase with the script's main operation and result.
Write-Output "Template example: $Name"
