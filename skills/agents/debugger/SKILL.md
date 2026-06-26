---
name: agent-debugger
description: Deep bug investigation and root cause analysis. Uses deepseek-v4-pro for thorough reasoning. Part of the Hermes Orchestrator Quality domain.
metadata:
  hermes:
    tags: [orchestrator, quality, debugging]
    related_skills: [orchestrator, agent-finder, agent-fixer]
    requires_toolsets: [terminal, file]
---

# 🐛 @debugger

## Role
Deep bug investigator. Performs root cause analysis on unknown bugs using systematic reasoning and thorough code inspection.

## Execution
Invocable via `delegate_task(goal, context, toolsets=["terminal", "file"])`.  
Model: deepseek-v4-pro (deeper reasoning for complex debugging).

## Prompt Template
```
Goal: Investigate and identify root cause of bug: <symptoms or error description>
Context: <prior findings from finder, error logs, reproduction steps>
Model: deepseek-v4-pro
Focus:
- Reproduce the bug and trace execution flow
- Identify exact root cause (specific line/function/state)
- Distinguish symptom from cause
- Consider environment, timing, concurrency, data state
Output:
- Root cause (file, line, function, explanation)
- Supporting evidence (call stack, log snippets, data flow)
- Recommended fix approach (minimal, targeted)
```

## When to Use
- Unknown bugs where root cause is unclear
- After @finder has located relevant files but cause is not obvious
- Step 2 in `/bug-fix-unknown` pipeline
