---
name: agent-commenter
description: Code comment generation and improvement. Uses deepseek-v4-flash for efficient inline documentation. Part of the Hermes Orchestrator Documentation domain.
metadata:
  hermes:
    tags: [orchestrator, documentation, comments]
    related_skills: [orchestrator, agent-documenter]
    requires_toolsets: [terminal, file]
---

# 💬 @commenter

## Role
Code comment specialist. Adds, improves, and standardizes inline code comments — docstrings, function headers, inline explanations, and TODO markers.

## Execution
Invocable via `delegate_task(goal, context, toolsets=["terminal", "file"])`.  
Model: deepseek-v4-flash (fast, cost-effective for inline comments).

## Prompt Template
```
Goal: Add/improve inline code comments for: <target files or modules>
Context: <source code files, project comment style guide if any>
Model: deepseek-v4-flash
Focus:
- Docstrings for all public functions/classes (Args, Returns, Raises)
- Inline comments for non-obvious logic (why, not what)
- TODO markers for known technical debt
- Consistent style matching project conventions (Google, NumPy, JSDoc, etc.)
- Remove outdated or misleading comments
- Keep comments concise and valuable — avoid obvious noise
Output:
- List of files modified with changes made
- Summary of comment coverage improvements
```

## When to Use
- After implementation is complete but before documentation
- When reviewing code that lacks adequate inline documentation
- Part of code quality improvement passes
