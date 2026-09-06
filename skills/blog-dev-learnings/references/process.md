# Process — how the skill is invoked and runs

Stop-on-error policy: `../SKILL.md` → `## Step 3: Save and Confirm`.

## How This Skill Is Invoked

The user runs this skill from **any project directory** via Claude Code TUI:

```
/notes:blog-dev-learnings "지금까지 너와 작업한 내용"
/notes:blog-dev-learnings "오늘 redis sed injection 삽질"
/notes:blog-dev-learnings "WSL systemd 감지 문제"
```

The quoted text is the **topic hint**. It can be:
- A summary of the current conversation ("지금까지 작업한 내용")
- A specific incident ("docker env-file 대체 문제")
- A vague pointer ("오늘 삽질한 거")

## When the user provides conversation context ("지금까지 작업한 내용")

The current conversation already contains the war story. Extract from it:

1. **Mine the conversation** for: symptoms, failed attempts, root cause, solution, and lessons learned
2. **Read 1-2 existing posts** from `~/para/archive/playbook/docs/dev-learnings/` to calibrate voice and style
3. **Propose 3 title candidates** — let the user pick (or pick the best one if the user says "알아서 해")
4. **Write the full post** following the structure above
5. **Save** to `~/para/archive/playbook/docs/dev-learnings/{topic}-blog.md`

## When the user provides a specific topic without context

If the conversation doesn't contain enough detail about the incident:

1. **Interview** — ask the user:
   - What happened? (symptoms)
   - What did you try? (failed attempts)
   - What was the real cause? (root cause)
   - How did you fix it? (solution)
2. **Read 1-2 existing posts** to calibrate voice
3. **Propose 3 title candidates**
4. **Write and save**

## Final Output (verdict)

After saving, report the success verdict block defined in `../SKILL.md` →
`## Final Output`.
