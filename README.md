# CodeStandards

Reusable standards and starting points for PowerShell automation and Markdown
documentation. Reference these files when asking GitHub Copilot to create or
review code; adapt the examples to the target repository rather than copying
project-specific infrastructure.

## Contents

| Area | Standard | Starting points |
| --- | --- | --- |
| PowerShell | [Style guide](PowerShell/style-guide.md) | [Script template](PowerShell/ScriptTemplate.ps1), [PSScriptAnalyzer settings](PowerShell/PSScriptAnalyzerSettings.psd1) |
| Markdown | [Style guide](Markdown/style-guide.md) | [Runbook](Markdown/templates/runbook.md), [Changelog](Markdown/templates/changelog.md) |

## Using these standards with Copilot

Provide the relevant files as context or link them in your prompt. A link to this
repository alone does not automatically configure Copilot in another repository.
For recurring use, add references or a concise summary to that repository's
Copilot instructions.

Example prompt:

> Follow PowerShell/style-guide.md and use PowerShell/ScriptTemplate.ps1 from
> gwblok/CodeStandards as the starting point. Preserve the target repository's
> supported PowerShell versions and existing interfaces. Use the analyzer
> settings, keep secrets out of code and logs, and document operational steps
> using Markdown/templates/runbook.md. Explain any necessary deviations.

Copy templates into the target repository, rename them for their purpose, and
replace all placeholder text. Existing repository requirements take precedence;
these files are a baseline, not a reason to rewrite working code.

## Validate PowerShell

Run from the root of your checkout with PSScriptAnalyzer available:

```powershell
Invoke-ScriptAnalyzer -Path ./PowerShell/ScriptTemplate.ps1 -Settings ./PowerShell/PSScriptAnalyzerSettings.psd1
```

No output means no analyzer findings. If the module is missing, install it
according to your organization's package policy before running the command.
Analyze copied scripts with the same settings, test their behavior separately,
and validate on every PowerShell version and operating system they claim to
support. Static analysis alone does not prove compatibility or correctness.

## Evolving the standards

Prefer conventions demonstrated by maintained scripts over speculative rules.
When adding a standard, include its rationale and a source example where
possible. Keep project-specific URLs, deployment paths, credentials, and
environment assumptions out of the reusable templates.

## Source examples

This initial baseline draws on recent work in `gwblok/2PintLabs` and
`gwblok/OEMWrapPS`. These pinned references explain the inspiration; the guides
also include recommended defaults, not claims that every source follows every rule.

- [2PintLabs client-content publishing script, October 16, 2026](https://github.com/gwblok/2PintLabs/blob/8111281191c374d263ca14ab3ec6b4d998e35f28/StifleR/AutoUpdates/Update-2PintStifleRClientContentItem.ps1):
  detailed help, typed inputs, explicit requirements, and contextual errors.
- [OEMWrapPS Dell installer, October 20, 2026](https://github.com/gwblok/OEMWrapPS/blob/86cc0756fc39accbd9c865dda9adeee3c7e8e63c/Public/Dell.Client.Update/Public/Install-DellUpdate.ps1):
  validated parameters, `ShouldProcess`, logging, and structured results.
- [OEMWrapPS module entry point](https://github.com/gwblok/OEMWrapPS/blob/86cc0756fc39accbd9c865dda9adeee3c7e8e63c/OEMWrapPS.psm1):
  explicit PowerShell 5.1 support and module-relative paths.
- [OEMWrapPS README](https://github.com/gwblok/OEMWrapPS/blob/86cc0756fc39accbd9c865dda9adeee3c7e8e63c/README.md)
  and [changelog](https://github.com/gwblok/OEMWrapPS/blob/86cc0756fc39accbd9c865dda9adeee3c7e8e63c/CHANGELOG.md):
  executable examples, reference tables, and versioned change descriptions.
