# Markdown style guide

Write task-oriented Markdown that helps readers understand the purpose, prerequisites, steps, and expected result without needing the original conversation.

## Structure

- Start with one descriptive H1 title and a short purpose statement.
- Use a logical heading hierarchy. Include sections such as prerequisites, setup, usage, validation, troubleshooting, limitations, and references when they help the reader; do not add empty boilerplate.
- Use numbered lists for ordered procedures, bullets for unordered information, and tables when comparing files or options.
- Keep headings and terminology consistent within a document. Use concise, direct language.

## Examples and links

- Use fenced code blocks with a language identifier, such as `powershell`, for commands and examples.
- Explain prerequisites, expected output, and any destructive or environment-specific behavior. Test examples when practical and do not claim they were tested if they were not.
- Use relative links for files in the same repository and descriptive link text for external references. Give images useful alternative text.
- Do not include real credentials, tokens, private URLs, or machine-specific paths unless they are intentionally public and necessary. Use clear placeholders where configuration differs by environment.

## Maintenance

Update the documentation when behavior or setup changes. A separate changelog is useful when a project needs one, but ordinary Markdown files do not need a change-history section by default; Git already records their history.

Use the [README](templates/readme.md), [runbook](templates/runbook.md), or [changelog](templates/changelog.md) template when it fits the task. Remove sections and placeholder text that do not apply.
