# <Operation name>

## Purpose and scope

<Describe the outcome, intended audience, affected systems, and exclusions.>

## Prerequisites

- Owner: `<team or role>`
- Supported platforms and tool versions: `<requirements>`
- Required permissions: `<permissions; state whether elevation is needed>`
- Required inputs: `<configuration and secure secret source; never paste secrets>`
- Working directory: `<repository or deployment directory>`
- Dependencies and access: `<modules, services, network access>`

## Impact and safety

<Describe changes, downtime, expected duration, and approval requirements.
Identify destructive steps, backups, and stop conditions before execution.>

## Procedure

1. Confirm the target environment and prerequisites.
2. Record current state and take any required backup.
3. Preview the operation if the script supports `ShouldProcess`:

   ```powershell
   # Replace the script path and supply its required parameters.
   ./Invoke-Operation.ps1 -WhatIf
   ```

4. Review the preview and execute the approved operation:

   ```powershell
   ./Invoke-Operation.ps1
   ```

<Replace these example commands with tested commands for the actual operation.
If preview is unsupported, document an alternative safe check instead.
WhatIf previews supported changes; it is not a full simulation or validation.>

## Validation

- Check: `<command or observation>`
- Expected result: `<observable success criteria>`
- Logs: `<location and relevant success/failure messages; redact sensitive data>`

## Rollback

<Provide tested recovery steps, required backups, recovery verification, and
limitations. If rollback is impossible, say so and describe escalation.>

## Troubleshooting and escalation

| Symptom | Likely cause | Action |
| --- | --- | --- |
| `<symptom>` | `<cause>` | `<safe diagnostic or recovery step>` |

Stop and escalate to `<team or role>` when `<condition>` occurs. Include sanitized
diagnostics, the operation version, and the failed step.

## References and maintenance

- Related script: `<relative link>`
- Related documentation: `<link>`
- Last verified: `<YYYY-MM-DD, environment, and version>`
