# Installing notes for OpenCode

## Prerequisites

- [OpenCode.ai](https://opencode.ai) installed

## Installation

Add the plugin to the `plugin` array in your `opencode.json` (global or
project-level):

```json
{
  "plugin": ["notes-skills@git+https://github.com/dEitY719/notes-skills.git"]
}
```

Restart OpenCode. The plugin installs through OpenCode's plugin manager and
registers all five skills.

OpenCode uses its own plugin install. If you also use Claude Code, Codex, or
another harness, install this plugin separately for each one.

## Usage

Use OpenCode's native `skill` tool:

```
use skill tool to list skills
use skill tool to load rca
```

## Tool mapping

The authoritative OpenCode tool mapping for every `dEitY719/*-skills` repo is
owned by the sibling repo
[`dEitY719/harness-skills`](https://github.com/dEitY719/harness-skills/blob/main/references/opencode-tools.md)
(dotfiles #1410 F-5). Read it there when a skill names a tool you do not
recognise; this repo keeps no copy on purpose. Short version:

- "Read a file" -> `read`
- "Create a file" / "edit a file" -> `apply_patch`
- "Run a shell command" -> `bash`
- "Search file contents" / "find files by name" -> `grep`, `glob`
- "Create a todo" -> `todowrite`
- "Ask the user" -> OpenCode has no dedicated ask tool; stop and ask in your
  reply, then wait. `insight` (candidate pick) and `blog-dev-learnings` (title
  pick) both need a real answer.
- "Invoke a skill" -> OpenCode's native `skill` tool

Every skill here builds its document from the current conversation. OpenCode
cannot read past sessions: use the live context, and when it is empty ask the
user rather than inventing the story.

## Troubleshooting

### Plugin not loading

1. Check logs: `opencode run --print-logs "hello" 2>&1 | grep -i notes`
2. Verify the plugin line in your `opencode.json`
3. Make sure you are running a recent version of OpenCode

### Skills not found

1. Use the `skill` tool to list what was discovered
2. Check that the plugin is loading (see above)

## Getting Help

Report issues: https://github.com/dEitY719/notes-skills/issues
