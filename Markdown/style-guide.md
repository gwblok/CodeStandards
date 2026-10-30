# Markdown style guide

The [source README and changelog](../README.md#source-examples) demonstrate
fenced PowerShell examples, reference tables, and categorized release notes.
The guidance below generalizes those patterns for new documentation.

## Structure

- Use one level-one heading that describes the document.
- Use descriptive sentence-case headings and do not skip heading levels.
- Start with purpose and audience, then prerequisites, steps, validation, and
  recovery where applicable.
- Keep paragraphs short. Use numbered lists for ordered procedures and bullets
  for unordered information.
- Use tables for compact reference data, not long procedures.

## Technical content

- Use fenced code blocks with a language identifier, such as `powershell`,
  `console`, or `json`.
- Make commands copyable: omit shell prompts, label placeholders, and explain
  required privileges, working directory, supported platform, and side effects.
- Distinguish example output from commands. Never imply that sample output was
  observed in the reader's environment.
- Use inline code for parameters, commands, file paths, and literal values.
- Link to repository files with relative links; use descriptive text for
  external sources. Check links after moving a document.
- Never include real credentials, tokens, customer data, or sensitive log output.
- Explain destructive actions and recovery before asking the reader to run them.
- Avoid machine-specific paths and screenshots as the sole source of instructions.

## Templates and review

- Use [the runbook template](templates/runbook.md) for operational procedures.
- Use [the changelog template](templates/changelog.md) for user-visible changes.
- Replace every `<placeholder>` and remove inapplicable sections before publishing.
- Review rendered Markdown, code fence pairing, heading order, and links.
- Verify commands in a safe environment and record observable success criteria.
- Keep documentation aligned with the actual script behavior; clearly label
  unverified assumptions and limitations.
