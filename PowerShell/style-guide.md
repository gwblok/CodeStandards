# PowerShell style guide

Use this guide for new PowerShell scripts and modules. For an existing file, preserve its behavior and established conventions; update it deliberately rather than rewriting it just to match this guide.

## Comment-based help

Start each new `.ps1` script and `.psm1` module with a comment-based help block before executable code. A required shebang or `#Requires` directive may come first; separate any preceding line comments from the help block with a blank line so `Get-Help` recognizes it. If a function directly follows the help, leave at least two blank lines before the function so PowerShell associates the help with the script rather than the function. Use the [script template](ScriptTemplate.ps1) as a starting point and replace its template-specific details, including the notes and history.

Include these sections:

1. `.SYNOPSIS`: a short statement of the purpose.
2. `.DESCRIPTION`: what the script does, including important prerequisites, side effects, and limitations.
3. `.PARAMETER`: the purpose of each script-level parameter, when parameters exist.
4. `.EXAMPLE`: at least one realistic invocation and a short explanation of the result.
5. `.NOTES`: `Author:`, `Created:`, and `Change History:` fields. Add a dated initial entry and record the author and a concise description of each meaningful change.

Use `YYYY-MM-DD` for dates and format history entries as `YYYY-MM-DD - Author - Description`. If the author or creation date is unknown, write `Not specified` rather than guessing; use the actual date of each recorded change. Include a version or `.LINK` when useful and known, but do not invent one. Document public module functions with their own comment-based help.

For an existing script, update an existing change history when making a meaningful behavior or configuration change. Add a missing header when creating a file or substantially revising it, not as an unrelated mass cleanup. Preserve a script's shebang, required directives, encoding, and signature requirements; modifying a signed script invalidates its signature.

## Comments throughout the script

- Add a short comment before each meaningful phase, such as checking prerequisites, loading configuration, connecting to a service, carrying out the main operation, or reporting results.
- Add comments before significant non-obvious operations to explain what is about to happen and any important reason, risk, or assumption.
- Keep comments accurate as the code changes. Avoid repeating every obvious command or describing behavior that the code does not perform.

## Structure and behavior

- Put parameters and configuration near the beginning, followed by reusable functions and a clearly organized execution flow when those parts are needed.
- Use four spaces for indentation in new files. In an existing file, follow the surrounding style unless a formatting change is requested.
- Use descriptive parameter and function names; use approved `Verb-Noun` names for functions. Follow existing project naming conventions for local variables.
- State the supported PowerShell version and operating system when known. Do not assume PowerShell 7 features work in Windows PowerShell 5.1.
- Validate inputs and prerequisites before making changes. Surface errors clearly instead of hiding failures.
- For operations that change state, consider `SupportsShouldProcess` and `-WhatIf` when practical. Describe potentially destructive actions and avoid embedding credentials or environment-specific secrets.
- Use the appropriate output streams: return useful objects or results, use verbose output for optional progress, and preserve the host behavior the script requires.

## Validation

Run the [header checker](../Tools/Test-PowerShellHeaders.ps1) on new or substantially revised scripts, and run relevant tests. The checker validates required sections, parameter documentation, creation-date format, and at least one dated history entry without executing the target files; it does not judge the accuracy of their contents or the quality of comments.

Use [PSScriptAnalyzer settings](PSScriptAnalyzerSettings.psd1) where PSScriptAnalyzer is available. The settings retain its default rules and do not replace the header checker or a review of the script's behavior.
