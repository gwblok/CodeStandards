# PowerShell style guide

## Scope and compatibility

Use this guide for new scripts and functions; preserve established interfaces in
existing projects. The [source examples](../README.md#source-examples) inform this
baseline, but product-specific defaults are deliberately excluded.

- Declare the minimum supported version with `#Requires -Version`. OEMWrapPS
  supports Windows PowerShell 5.1 while the referenced DeployR script requires
  PowerShell 7; choose based on actual dependencies.
- The [script template](ScriptTemplate.ps1) uses 5.1-compatible syntax. Verify it
  on the actual target runtime; running it on PowerShell 7 is not a 5.1 test.
- Require elevation only when the operation needs it. Use
  `#Requires -RunAsAdministrator` only for Windows scripts that always need
  elevation; otherwise check privileges at the relevant operation.
- Document operating system, module, executable, network, and permission
  requirements. Do not silently install dependencies or change execution policy.

## Script layout and naming

1. Runtime requirements and comment-based help.
2. `[CmdletBinding()]` and `param(...)`.
3. Preferences and configuration.
4. Helper functions, when needed.
5. Main operation and error handling.

- Include `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`, and `.NOTES`.
  Keep examples runnable and document outputs and side effects.
- Use approved `Verb-Noun` names for functions and descriptive script names.
- Use descriptive PascalCase parameter and variable names, except PowerShell
  automatic variables. Prefer full cmdlet and parameter names over aliases.
- Indent with four spaces, use same-line opening braces, and write `} else {`
  and `} catch {`. Use spaces around operators and after commas.
- Use single-quoted strings for literals and double quotes for interpolation.
  Use splatting when it makes long invocations easier to read.
- Comments should explain intent or non-obvious constraints, not restate code.
  Regions can organize longer scripts; do not add them to every small function.

## Inputs, paths, and configuration

- Use typed parameters and appropriate validation such as `ValidateSet`,
  `ValidateRange`, or `ValidateNotNullOrEmpty`. Make required inputs mandatory.
- Do not hard-code lab endpoints, drive letters, tenant identifiers, or
  deployment paths into reusable scripts.
- Use `Join-Path` and `$PSScriptRoot` for script-relative resources; do not assume
  the caller's working directory. Use `-LiteralPath` for user-supplied paths
  where supported so brackets and wildcard characters are not interpreted.
- Keep secrets outside source control. Use an approved secret store or
  credential interface; never log passwords, tokens, or authorization headers.

## Output, logging, and errors

- Return objects on the success stream. Use `[pscustomobject]` for deliberate
  result contracts; keep field names and types stable.
- Use `Write-Verbose` for diagnostic progress, `Write-Warning` for recoverable
  conditions, and terminating errors for failures that prevent completion.
  Avoid `Write-Host` in reusable functions; reserve it for intentional console UI.
- When persistent logs are needed, use the target project's logging mechanism,
  timestamp entries, choose an explicit encoding, and redact sensitive data.
  There is no universal log directory or mandatory logging helper.
- Use `-ErrorAction Stop` or a script-local `$ErrorActionPreference = 'Stop'`
  when an operation must enter `catch` on failure. Include actionable context
  and do not silently swallow exceptions.
- Decide batch failure policy explicitly: a failed item may produce a structured
  failure result while processing continues, but preflight failure should stop
  the operation. Document partial-success behavior.
- Document exit codes for executable entry-point scripts. Functions should
  return results or throw rather than terminate the caller with `exit`.
- Check external process exit codes explicitly; `try`/`catch` alone does not
  reliably detect native command failures across supported PowerShell versions.

## Changes and safety

- For state-changing scripts and functions, declare
  `[CmdletBinding(SupportsShouldProcess)]` and guard mutations with
  `$PSCmdlet.ShouldProcess(...)`. Forward confirmation behavior to nested
  operations deliberately; merely declaring the attribute is not sufficient.
- Keep all mutations, including setup or log writes, out of a `-WhatIf` path
  unless explicitly documented. Preview support is not a full simulation.
- Validate inputs, dependencies, and permissions before changing state.
  Document destructive effects and recovery; clean up owned resources in
  `finally` where necessary.
- For downloaded executables, use trusted sources and validate signatures or
  hashes against trusted metadata before execution. Never disable TLS or
  certificate verification to make a download work.

## Validation

Run the analyzer using the [shared settings](PSScriptAnalyzerSettings.psd1);
the command is in the [README](../README.md#validate-powershell). Default analyzer
rules remain enabled alongside the formatting rules.

Test successful execution, invalid and missing inputs, dependency failures, and
permission failures as applicable. Test `-WhatIf` and `-Confirm` for mutations,
including that preview leaves state unchanged. Use the target repository's
existing tests (for example Pester); avoid introducing a new harness just to
copy this template. Explain any narrowly scoped analyzer suppression.
