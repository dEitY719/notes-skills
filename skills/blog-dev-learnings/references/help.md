# notes:blog-dev-learnings — Help

## Synopsis

```
/notes:blog-dev-learnings ["<topic-hint>"]
```

## Description

Write entertaining Korean developer blog posts about debugging war stories,
production incidents, and technical gotchas. Saves to
`~/para/archive/playbook/docs/dev-learnings/{topic}-blog.md`. Narrative arc:
고통 → 삽질 → 깨달음 → 해결. Do NOT use for formal RCA documents (use
`notes:rca`), API docs, or README files.

## Arguments

| Option | Description | Default |
|--------|-------------|---------|
| `"<topic-hint>"` | Topic summary, specific incident, or vague pointer ("오늘 삽질한 거"). | none — mine the current conversation |
| `-h` / `--help` / `help` | Print this help and stop. | — |

## Examples

```
/notes:blog-dev-learnings                      # no argument — mine the current conversation
/notes:blog-dev-learnings "지금까지 너와 작업한 내용"
/notes:blog-dev-learnings "오늘 redis sed injection 삽질"
/notes:blog-dev-learnings "WSL systemd 감지 문제"
```

## Stop conditions

- Conversation does not contain enough detail and the user gives no topic — interview the user for symptoms, attempts, root cause, and fix before writing.
- Topic better fits an RCA or non-narrative doc — redirect to `notes:rca` or the appropriate skill.
