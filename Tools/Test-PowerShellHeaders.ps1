<#
.SYNOPSIS
    Checks PowerShell files for the shared comment-based help requirements.
.DESCRIPTION
    Parses scripts and modules without executing them, then checks the leading
    help block, script parameter documentation, notes fields, creation-date
    format, and a dated change-history entry. Reports missing or invalid sections
    and PowerShell syntax errors.
.PARAMETER Path
    One or more literal paths to PowerShell scripts or modules.
.EXAMPLE
    .\Tools\Test-PowerShellHeaders.ps1 -Path .\PowerShell\ScriptTemplate.ps1
    Checks the template from the root of the standards repository.
.NOTES
    Author: CodeStandards contributors
    Created: 2026-10-30
    Change History:
        2026-10-30 - CodeStandards contributors - Initial version.
#>

#Requires -Version 5.1

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string[]] $Path
)

$requiredSections = @('SYNOPSIS', 'DESCRIPTION', 'EXAMPLE', 'NOTES')
$failures = [System.Collections.Generic.List[string]]::new()
$validatedFiles = [System.Collections.Generic.List[string]]::new()

foreach ($itemPath in $Path) {
    $file = Get-Item -LiteralPath $itemPath -ErrorAction Stop
    if ($file.PSIsContainer -or $file.Extension -notin @('.ps1', '.psm1')) {
        throw "Expected a PowerShell script or module file: $itemPath"
    }

    $content = [string] (Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop)

    # Parse the target without running it so script-level parameters can be checked.
    $tokens = $null
    $parseErrors = $null
    $scriptAst = [System.Management.Automation.Language.Parser]::ParseFile(
        $file.FullName,
        [ref] $tokens,
        [ref] $parseErrors
    )
    foreach ($parseError in $parseErrors) {
        $failures.Add(('{0}:{1}: {2}' -f $file.FullName, $parseError.Extent.StartLineNumber, $parseError.Message))
    }

    # Permit a shebang, directives, or other line comments before the first block.
    $headerPattern = '(?s)\A(?:\uFEFF)?(?<prefix>(?:(?:[ \t]*\#[^\r\n]*(?:\r?\n|\z))|(?:[ \t]*\r?\n))*)[ \t]*<\#(?<help>.*?)\#>'
    $headerMatch = [regex]::Match($content, $headerPattern)
    if (-not $headerMatch.Success) {
        $failures.Add(('{0}: missing leading comment-based help block.' -f $file.FullName))
        continue
    }

    $prefix = $headerMatch.Groups['prefix'].Value
    if ($prefix -match '(?m)^[ \t]*#' -and $prefix -notmatch '\r?\n[ \t]*\r?\n\z') {
        $failures.Add(('{0}: separate preceding line comments and the help block with a blank line.' -f $file.FullName))
    }
    if ($null -eq $scriptAst.GetHelpContent()) {
        $failures.Add(('{0}: PowerShell does not recognize the leading block as script-level help.' -f $file.FullName))
    }

    $helpText = $headerMatch.Groups['help'].Value
    $sectionPattern = '(?im)^[ \t]*\.(?<name>[a-z][a-z0-9]*)[ \t]*(?<argument>[^\r\n]*)(?:\r?\n|\z)'
    $sectionMatches = [regex]::Matches($helpText, $sectionPattern)
    $sections = @(
        for ($index = 0; $index -lt $sectionMatches.Count; $index++) {
            $sectionMatch = $sectionMatches[$index]
            $bodyStart = $sectionMatch.Index + $sectionMatch.Length
            $bodyEnd = if ($index + 1 -lt $sectionMatches.Count) {
                $sectionMatches[$index + 1].Index
            }
            else {
                $helpText.Length
            }

            [pscustomobject]@{
                Name = $sectionMatch.Groups['name'].Value
                Argument = $sectionMatch.Groups['argument'].Value.Trim()
                Body = $helpText.Substring($bodyStart, $bodyEnd - $bodyStart).Trim()
            }
        }
    )

    foreach ($requiredSection in $requiredSections) {
        $documentedSection = @($sections | Where-Object {
            $_.Name -eq $requiredSection -and -not [string]::IsNullOrWhiteSpace($_.Body)
        })
        if ($documentedSection.Count -eq 0) {
            $failures.Add(('{0}: missing or empty .{1} section.' -f $file.FullName, $requiredSection))
        }
    }

    if ($scriptAst.ParamBlock) {
        foreach ($parameter in $scriptAst.ParamBlock.Parameters) {
            $parameterName = $parameter.Name.VariablePath.UserPath
            $parameterHelp = @($sections | Where-Object {
                $_.Name -eq 'PARAMETER' -and $_.Argument -eq $parameterName -and
                    -not [string]::IsNullOrWhiteSpace($_.Body)
            })
            if ($parameterHelp.Count -eq 0) {
                $failures.Add(('{0}: missing or empty .PARAMETER {1} section.' -f $file.FullName, $parameterName))
            }
        }
    }

    $notes = $sections | Where-Object { $_.Name -eq 'NOTES' } | Select-Object -First 1
    if ($notes) {
        if ($notes.Body -notmatch '(?im)^[ \t]*Author[ \t]*:[ \t]*\S') {
            $failures.Add(('{0}: missing or empty Author field in .NOTES.' -f $file.FullName))
        }

        $createdMatch = [regex]::Match($notes.Body, '(?im)^[ \t]*Created[ \t]*:[ \t]*(?<value>[^\r\n]*)')
        $createdValue = $createdMatch.Groups['value'].Value.Trim()
        if (-not $createdMatch.Success -or [string]::IsNullOrWhiteSpace($createdValue)) {
            $failures.Add(('{0}: missing or empty Created field in .NOTES.' -f $file.FullName))
        }
        elseif ($createdValue -ne 'Not specified') {
            $createdDate = [datetime]::MinValue
            $isValidCreatedDate = [datetime]::TryParseExact(
                $createdValue,
                'yyyy-MM-dd',
                [cultureinfo]::InvariantCulture,
                [System.Globalization.DateTimeStyles]::None,
                [ref] $createdDate
            )
            if (-not $isValidCreatedDate) {
                $failures.Add(('{0}: Created must be a valid YYYY-MM-DD date or Not specified.' -f $file.FullName))
            }
        }

        $historyMatch = [regex]::Match($notes.Body, '(?ims)^[ \t]*Change History[ \t]*:[ \t]*(?<entries>.*)\z')
        if (-not $historyMatch.Success -or [string]::IsNullOrWhiteSpace($historyMatch.Groups['entries'].Value)) {
            $failures.Add(('{0}: missing or empty Change History in .NOTES.' -f $file.FullName))
        }
        else {
            $entryPattern = '(?m)^[ \t]*(?<date>\d{4}-\d{2}-\d{2})[ \t]+-[ \t]+\S[^\r\n]*?[ \t]+-[ \t]+\S[^\r\n]*\r?$'
            $historyEntries = [regex]::Matches($historyMatch.Groups['entries'].Value, $entryPattern)
            $hasDatedEntry = $false
            foreach ($historyEntry in $historyEntries) {
                $entryDate = [datetime]::MinValue
                if ([datetime]::TryParseExact(
                    $historyEntry.Groups['date'].Value,
                    'yyyy-MM-dd',
                    [cultureinfo]::InvariantCulture,
                    [System.Globalization.DateTimeStyles]::None,
                    [ref] $entryDate
                )) {
                    $hasDatedEntry = $true
                    break
                }
            }
            if (-not $hasDatedEntry) {
                $failures.Add(('{0}: Change History needs a valid YYYY-MM-DD - Author - Description entry.' -f $file.FullName))
            }
        }
    }

    $validatedFiles.Add($file.FullName)
}

if ($failures.Count -gt 0) {
    throw ("PowerShell header validation failed:`n- {0}" -f ($failures -join "`n- "))
}

foreach ($validatedFile in $validatedFiles) {
    Write-Output "Validated: $validatedFile"
}
