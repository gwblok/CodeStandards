<#
.SYNOPSIS
    Tests the PowerShell comment-based help checker.
.DESCRIPTION
    Uses temporary test files to verify valid headers, missing help, parameter
    documentation, notes, syntax errors, and files that must not be executed.
.EXAMPLE
    Invoke-Pester .\Tests\Test-PowerShellHeaders.Tests.ps1
    Runs the tests from the root of the standards repository.
.NOTES
    Author: CodeStandards contributors
    Created: 2026-10-30
    Change History:
        2026-10-30 - CodeStandards contributors - Initial version.
#>

#Requires -Version 5.1

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments',
    '',
    Justification = 'Pester shares BeforeEach variables with the individual tests.'
)]
param ()

Describe 'Test-PowerShellHeaders' {
    BeforeEach {
        $checker = Join-Path (Split-Path -Parent $PSScriptRoot) 'Tools\Test-PowerShellHeaders.ps1'
        $testFile = Join-Path $TestDrive 'example.ps1'
        $validScript = @'
<#
.SYNOPSIS
    Example script.
.DESCRIPTION
    Demonstrates a valid header.
.PARAMETER Name
    A sample input.
.EXAMPLE
    .\example.ps1 -Name Example
    Demonstrates an invocation.
.NOTES
    Author: Example contributor
    Created: 2026-10-30
    Change History:
        2026-10-30 - Example contributor - Initial version.
#>
param([string] $Name)
throw 'The checker must not run this script.'
'@
    }

    It 'accepts a complete header without executing the target' {
        Set-Content -LiteralPath $testFile -Value $validScript -Encoding UTF8
        & $checker -Path $testFile | Out-Null
    }

    It 'allows a shebang and required directive before the header' {
        $content = "#!/usr/bin/env pwsh`n#Requires -Version 5.1`n`n$validScript"
        Set-Content -LiteralPath $testFile -Value $content -Encoding UTF8
        & $checker -Path $testFile | Out-Null
        $help = Get-Help -Name (Get-Item -LiteralPath $testFile).FullName -Full -ErrorAction Stop
        if ($help.Synopsis -ne 'Example script.' -or $help.Parameters.Parameter.Name -notcontains 'Name') {
            throw 'PowerShell did not recognize the help block and its parameter.'
        }
    }

    It 'rejects preceding line comments without a blank line before help' {
        $content = "#Requires -Version 5.1`n$validScript"
        Set-Content -LiteralPath $testFile -Value $content -Encoding UTF8
        $message = try { $null = & $checker -Path $testFile; '' } catch { $_.Exception.Message }
        if ($message -notmatch 'separate preceding line comments and the help block with a blank line') {
            throw "Expected a help placement error. Received: $message"
        }
    }

    It 'rejects help that would be attached to a directly following function' {
        $header = $validScript.Substring(0, $validScript.IndexOf('#>') + 2)
        $content = $header + "`n`nfunction Get-Example { 'example' }`n"
        Set-Content -LiteralPath $testFile -Value $content -Encoding UTF8
        $message = try { $null = & $checker -Path $testFile; '' } catch { $_.Exception.Message }
        if ($message -notmatch 'does not recognize the leading block as script-level help') {
            throw "Expected a script-level help association error. Received: $message"
        }
    }

    It 'recognizes help separated from the first function by two blank lines' {
        $header = $validScript.Substring(0, $validScript.IndexOf('#>') + 2)
        $content = $header + "`n`n`nfunction Get-Example { 'example' }`n"
        Set-Content -LiteralPath $testFile -Value $content -Encoding UTF8
        & $checker -Path $testFile | Out-Null
        $help = Get-Help -Name (Get-Item -LiteralPath $testFile).FullName -Full -ErrorAction Stop
        if ($help.Synopsis -ne 'Example script.') {
            throw 'PowerShell did not recognize the script-level synopsis.'
        }
    }

    It 'accepts a PowerShell module' {
        $moduleFile = Join-Path $TestDrive 'example.psm1'
        Set-Content -LiteralPath $moduleFile -Value $validScript -Encoding UTF8
        & $checker -Path $moduleFile | Out-Null
    }

    It 'rejects a help block after executable code' {
        $content = "Write-Output 'before help'`n$validScript"
        Set-Content -LiteralPath $testFile -Value $content -Encoding UTF8
        $message = try { $null = & $checker -Path $testFile; '' } catch { $_.Exception.Message }
        if ($message -notmatch 'missing leading comment-based help') {
            throw "Expected a missing leading help error. Received: $message"
        }
    }

    It 'reports each missing required help section' {
        foreach ($section in @('SYNOPSIS', 'DESCRIPTION', 'EXAMPLE', 'NOTES')) {
            $content = $validScript.Replace(".$section", '.OTHER')
            Set-Content -LiteralPath $testFile -Value $content -Encoding UTF8
            $message = try { $null = & $checker -Path $testFile; '' } catch { $_.Exception.Message }
            if ($message -notmatch [regex]::Escape("missing or empty .$section")) {
                throw "Expected a missing .$section error. Received: $message"
            }
        }
    }

    It 'reports an empty example' {
        $content = $validScript -replace '(?s)(\.EXAMPLE\r?\n).*?(\.NOTES)', '$1$2'
        Set-Content -LiteralPath $testFile -Value $content -Encoding UTF8
        $message = try { $null = & $checker -Path $testFile; '' } catch { $_.Exception.Message }
        if ($message -notmatch 'missing or empty \.EXAMPLE') {
            throw "Expected an empty example error. Received: $message"
        }
    }

    It 'requires documentation for each script parameter' {
        $content = $validScript -replace '\.PARAMETER Name', '.PARAMETER Other'
        Set-Content -LiteralPath $testFile -Value $content -Encoding UTF8
        $message = try { $null = & $checker -Path $testFile; '' } catch { $_.Exception.Message }
        if ($message -notmatch 'missing or empty \.PARAMETER Name') {
            throw "Expected a missing parameter error. Received: $message"
        }
    }

    It 'rejects an empty parameter description' {
        $content = $validScript -replace '(?s)(\.PARAMETER Name\r?\n).*?(\.EXAMPLE)', '$1$2'
        Set-Content -LiteralPath $testFile -Value $content -Encoding UTF8
        $message = try { $null = & $checker -Path $testFile; '' } catch { $_.Exception.Message }
        if ($message -notmatch 'missing or empty \.PARAMETER Name') {
            throw "Expected an empty parameter description error. Received: $message"
        }
    }

    It 'requires author and created fields in notes' {
        $content = $validScript -replace '(?m)^\s*Author:.*\r?\n', ''
        $content = $content -replace '(?m)^\s*Created:.*\r?\n', ''
        Set-Content -LiteralPath $testFile -Value $content -Encoding UTF8
        $message = try { $null = & $checker -Path $testFile; '' } catch { $_.Exception.Message }
        if ($message -notmatch 'missing or empty Author' -or $message -notmatch 'missing or empty Created') {
            throw "Expected missing author and created errors. Received: $message"
        }
    }

    It 'accepts an explicitly unknown creation date' {
        $content = $validScript.Replace('Created: 2026-10-30', 'Created: Not specified')
        Set-Content -LiteralPath $testFile -Value $content -Encoding UTF8
        & $checker -Path $testFile | Out-Null
    }

    It 'rejects an invalid creation date' {
        $content = $validScript.Replace('Created: 2026-10-30', 'Created: 2026-02-30')
        Set-Content -LiteralPath $testFile -Value $content -Encoding UTF8
        $message = try { $null = & $checker -Path $testFile; '' } catch { $_.Exception.Message }
        if ($message -notmatch 'Created must be a valid YYYY-MM-DD date') {
            throw "Expected an invalid creation date error. Received: $message"
        }
    }

    It 'requires a nonempty change history in notes' {
        $content = $validScript -replace '(?s)(Change History:).*?(#>)', ('$1' + "`n" + '$2')
        Set-Content -LiteralPath $testFile -Value $content -Encoding UTF8
        $message = try { $null = & $checker -Path $testFile; '' } catch { $_.Exception.Message }
        if ($message -notmatch 'missing or empty Change History') {
            throw "Expected an empty change history error. Received: $message"
        }
    }

    It 'does not accept change history outside notes' {
        $content = $validScript.Replace(
            'Demonstrates a valid header.',
            "Demonstrates a valid header.`n    Change History: not a notes entry."
        )
        $content = $content -replace '(?s)(\.NOTES\r?\n.*?)([ \t]*Change History:.*?)(#>)', '$1$3'
        Set-Content -LiteralPath $testFile -Value $content -Encoding UTF8
        $message = try { $null = & $checker -Path $testFile; '' } catch { $_.Exception.Message }
        if ($message -notmatch 'missing or empty Change History') {
            throw "Expected a missing notes history error. Received: $message"
        }
    }

    It 'requires a dated change entry with an author and description' {
        foreach ($entry in @(
            'Initial version.',
            '2026-02-30 - Example contributor - Initial version.',
            '2026-10-30 - Initial version.'
        )) {
            $content = $validScript.Replace('2026-10-30 - Example contributor - Initial version.', $entry)
            Set-Content -LiteralPath $testFile -Value $content -Encoding UTF8
            $message = try { $null = & $checker -Path $testFile; '' } catch { $_.Exception.Message }
            if ($message -notmatch 'Change History needs a valid YYYY-MM-DD') {
                throw "Expected an invalid history entry error for '$entry'. Received: $message"
            }
        }
    }

    It 'reports PowerShell syntax errors' {
        $content = "$validScript`nif (`$true) {"
        Set-Content -LiteralPath $testFile -Value $content -Encoding UTF8
        $message = try { $null = & $checker -Path $testFile; '' } catch { $_.Exception.Message }
        if ($message -notmatch 'Missing closing') {
            throw "Expected a PowerShell syntax error. Received: $message"
        }
    }

    It 'checks all supplied paths and fails if any header is invalid' {
        $badFile = Join-Path $TestDrive 'bad.ps1'
        Set-Content -LiteralPath $testFile -Value $validScript -Encoding UTF8
        Set-Content -LiteralPath $badFile -Value 'Write-Output "No header"' -Encoding UTF8
        $message = try { $null = & $checker -Path @($testFile, $badFile); '' } catch { $_.Exception.Message }
        if ($message -notmatch 'bad\.ps1: missing leading comment-based help') {
            throw "Expected an error for the invalid file. Received: $message"
        }
    }

    It 'returns a result for each valid path, including paths with spaces' {
        $secondFile = Join-Path $TestDrive 'example script.ps1'
        Set-Content -LiteralPath $testFile -Value $validScript -Encoding UTF8
        Set-Content -LiteralPath $secondFile -Value $validScript -Encoding UTF8
        $results = @(& $checker -Path @($testFile, $secondFile))
        if ($results.Count -ne 2) {
            throw "Expected two validation results. Received: $($results.Count)"
        }
    }

    It 'rejects a non-PowerShell file' {
        $textFile = Join-Path $TestDrive 'example.txt'
        Set-Content -LiteralPath $textFile -Value $validScript -Encoding UTF8
        $message = try { $null = & $checker -Path $textFile; '' } catch { $_.Exception.Message }
        if ($message -notmatch 'Expected a PowerShell script or module file') {
            throw "Expected an unsupported file error. Received: $message"
        }
    }

    It 'rejects a missing file' {
        $missingFile = Join-Path $TestDrive 'missing.ps1'
        $message = try { $null = & $checker -Path $missingFile; '' } catch { $_.Exception.Message }
        if ([string]::IsNullOrWhiteSpace($message)) {
            throw 'Expected an error for a missing file.'
        }
    }
}
