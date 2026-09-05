# File Entry Structure — Step 6

Check if the target file already exists:

- **File does not exist**: Create it with a level-1 heading, then the entry.
- **File exists**: Append a `---` separator followed by the new entry.

Each entry uses this structure:

```markdown
## HH:MM | project-name | Short task title

### JIRA Ticket

\`\`\`text
(JIRA content here)
\`\`\`

### PR

\`\`\`markdown
(PR content here — or omit this entire section if no commits)
\`\`\`
```

The timestamp is the current time when the skill runs (24-hour format).

## Output conventions

- Never use emoji in any output (repo convention).
- JIRA format uses only `>` and `-` symbols for structure, no markdown.
- Always append, never overwrite existing file content.
- The `text` and `markdown` code blocks are essential for the copy-paste workflow.
- Determine project name from `git remote`, falling back to directory name, then "N/A".
- Write content in the same language the user used during the conversation.
