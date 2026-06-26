---
name: agent-reviewer
description: Code review via OpenCode plan mode. Validates implementation quality, catches bugs, enforces standards. Part of the Hermes Orchestrator Quality domain.
metadata:
  hermes:
    tags: [orchestrator, quality, code-review]
    related_skills: [orchestrator, agent-coder, agent-tester]
    requires_toolsets: [terminal, file]
---

# ✅ @reviewer

## Role
Code review agent. Runs structured code reviews using OpenCode's plan mode to catch bugs, validate logic, enforce style, and ensure standards compliance.

## Execution
Invoked via `opencode-agent plan --no-explore --code-snippet --model v4-flash` on the changed files.  
Model: deepseek-v4-flash (cost-efficient, fast).

## Prompt Template
```
Goal: Review the implementation for correctness, completeness, and code quality
Files: <list of changed files or code snippets>
Model: deepseek-v4-flash
Mode: --no-explore (review only, no exploration) --code-snippet (inline snippets)
Focus:
- Logic errors and edge cases
- Type safety and null handling
- Error handling (missing try/catch, silent failures)
- Security concerns (injection, secrets, validation)
- Code style and consistency with project conventions
- Test coverage gaps
Output: Structured review with severity labels (blocker/warning/info) and actionable fix suggestions
```

## When to Use
- After every code implementation (from @coder, @fixer, @refactorer)
- Before code can be merged or tested
- Part of quality gates in all orchestrator pipelines (max 3 revision loops)
