# Code standards

This repository is the shared reference for creating consistent PowerShell scripts and Markdown documentation, including work produced with AI coding agents.

## Standards and templates

| Area | Guidance | Starting points |
| --- | --- | --- |
| PowerShell | [Style guide](PowerShell/style-guide.md) | [Script template](PowerShell/ScriptTemplate.ps1), [PSScriptAnalyzer settings](PowerShell/PSScriptAnalyzerSettings.psd1) |
| Markdown | [Style guide](Markdown/style-guide.md) | [README](Markdown/templates/readme.md), [runbook](Markdown/templates/runbook.md), [changelog](Markdown/templates/changelog.md) |
| Agent instructions | [Shared project instructions](AGENTS.md) | [PowerShell instructions](.github/instructions/powershell.instructions.md), [Markdown instructions](.github/instructions/markdown.instructions.md), [Claude import](CLAUDE.md) |

The standards focus on new files and meaningful changes. They are not a request to rewrite every existing script or document.

## Use the standards in another repository

1. Copy [AGENTS.md](AGENTS.md), [CLAUDE.md](CLAUDE.md), and the two files in [`.github/instructions`](.github/instructions) into the corresponding locations in the target repository.
2. If a target file already exists, merge the relevant instructions instead of replacing its project-specific guidance.
3. Keep the copied instructions in sync when the standards change. They are self-contained copies, not automatically updated links.
4. Commit and share the standards and project-repository changes so they are available on other machines.

`AGENTS.md` provides common rules for agents that support it. The `.instructions.md` files provide file-specific guidance for GitHub Copilot in VS Code. `CLAUDE.md` imports the same `AGENTS.md` for Claude Code. Other tools may need their own configuration or a manual reference to the shared instructions. Verify that instruction discovery is enabled in the tool you use.

No instruction file can guarantee that every agent follows every rule. The checks below can enforce part of the PowerShell header convention when run locally or in CI; comments and documentation still need human review.

## Check PowerShell files

From the root of this repository, run the header checker against one or more literal paths:

```powershell
.\Tools\Test-PowerShellHeaders.ps1 -Path .\PowerShell\ScriptTemplate.ps1
```

The checker does not execute the files it inspects. It checks the help block's placement, required sections, documented script parameters, notes fields, a valid creation date or `Not specified`, at least one dated change-history entry, and PowerShell parse errors. It cannot verify that placeholder text was replaced, that authors or dates are factually correct, or that comments explain the right things. It is not automatically run in other repositories or in CI.

To run the checker tests, use an installed version of Pester:

```powershell
Invoke-Pester .\Tests\Test-PowerShellHeaders.Tests.ps1
```

PSScriptAnalyzer is a separate, optional tool. Once it is installed, the included settings run its default rules without excluding any rules:

```powershell
Invoke-ScriptAnalyzer -Path .\PowerShell\ScriptTemplate.ps1 -Settings .\PowerShell\PSScriptAnalyzerSettings.psd1
```

PSScriptAnalyzer and the header checker cover different things. If adding either to CI, explicitly fail the job for findings and select the files that should be checked; legacy scripts may not yet follow these conventions.

## Background

These initial conventions draw on existing comment-based help and change history in [2Pint-DeployR scripts](https://github.com/2pintsoftware/2Pint-DeployR/blob/f2f582a17afca4404b0b8c8ee28f1cd669f111d2/Automation/Add-TagsToContentItems.ps1) and [2PintLabs scripts](https://github.com/gwblok/2PintLabs/blob/18d7f12f23fd654ebf5bea382b57bdd31e330e92/WinPEBuilderV2.ps1), as well as their task-oriented documentation. Existing files are examples of the background, not a requirement to duplicate every legacy formatting choice.
