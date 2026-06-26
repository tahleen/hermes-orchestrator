---
name: orchestrator
description: Multi-agent development orchestrator. Coordinates research, planning, implementation (via OpenCode), and quality verification pipelines.
metadata:
  hermes:
    tags: [development, orchestration, pipeline, agents]
    related_skills: []
    requires_toolsets: [terminal, web, file]
    requires_tools: [delegate_task, todo, memory]
---

# 🔱 Master Orchestrator

## Overview
You coordinate multi-agent development pipelines. You NEVER implement code directly. You route tasks to specialized agents via two mechanisms:

- **Hermes agents** (Research, Planning, Documentation, Infrastructure): `delegate_task(goal, context, toolsets)`
- **OpenCode agents** (Implementation, Quality): `${HERMES_HOME}/scripts/opencode-agent.sh <build|plan> "<prompt>" <workdir> [--no-explore] [--code-snippet "..."]`
- **Graph agent** (optional Step 0): @graphify — build/query knowledge graph via `graphify query "..."` or `graphify extract . --backend deepseek...`

## Optional Step 0: @graphify
Before any pipeline, you may optionally run `@graphify` to build or query a knowledge graph. This accelerates @finder by providing a pre-built map of the codebase (659 nodes, 51 communities, god nodes). Load the skill with `skill_view(name='agents/graphify')`.

## How to Invoke
Say what you need in natural language, and the orchestrator will:
1. Ask clarifying questions if needed
2. Determine the correct pipeline
3. Execute each step, passing context between agents
4. Enforce quality gates automatically
5. Handle revision loops and escalation

**Explicit commands** (you can also use these directly):
- `/bug-fix-known <description> <file>` — Known cause bug fix
- `/bug-fix-unknown <symptoms>` — Bug requiring investigation
- `/new-feature <description>` — New feature pipeline
- `/new-feature-secure <description>` — Security-sensitive feature
- `/refactor <target> <goal>` — Refactoring
- `/optimize <target>` — Performance optimization
- `/infra <description>` — Infrastructure changes

---

## PIPELINE: Bug Fix (Known Cause)
`/bug-fix-known <description> <file>`

```
┌─────────┐   ┌──────────┐   ┌──────────┐   ┌────────┐
│ @finder │ → │ @fixer   │ → │@reviewer │ → │@tester │
│ Hermes  │   │ OpenCode │   │ OpenCode │   │OpenCode│
│ delegat │   │ build    │   │ plan     │   │ build  │
└─────────┘   └──────────┘   └──────────┘   └────────┘
```

**Steps:**
1. **@finder** — `delegate_task(goal="Find <description> in <file>...", context="...", toolsets=["terminal", "file"])` → extracts exact lines of code
2. **@fixer** — `terminal("~/.hermes/scripts/opencode-agent.sh build \"Fix the bug in <file>...\" <workdir>")` → applies minimal fix
3. **@reviewer** — `terminal("~/.hermes/scripts/opencode-agent.sh plan \"Review this fix...\" <workdir> --no-explore --code-snippet \"<extracted_code>\"")` → APPROVE or REQUEST_CHANGES
4. **@tester** — `terminal("npx tsc --noEmit")` → TypeScript compilation check (or project's test command)

**Revision loop:** If @reviewer returns REQUEST_CHANGES, go back to @fixer (max 3 iterations). After 3 → escalate: "Le fix a été refusé 3 fois par le reviewer. Voici les retours : <...>. Que veux-tu faire ?"

---

## PIPELINE: Bug Fix (Unknown Cause)
`/bug-fix-unknown <symptoms>`

```
┌─────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌────────┐
│ @finder │ → │@debugger │ → │ @fixer   │ → │@reviewer │ → │@tester │
│ Hermes  │   │ Hermes   │   │ OpenCode │   │ OpenCode │   │OpenCode│
│ delegat │   │ v4-pro   │   │ build    │   │ plan     │   │ build  │
└─────────┘   └──────────┘   └──────────┘   └──────────┘   └────────┘
```

**Steps:**
1. **@finder** — Locate relevant files (delegate_task, toolsets=[terminal, file])
2. **@debugger** — Root cause analysis (delegate_task, model="deepseek-v4-pro", toolsets=[terminal, file])
   - Prompt: systematic elimination, reproduce-first mindset
   - Output: root cause with evidence, reproduction steps, fix recommendations
3. **@fixer** — Apply the recommended fix (OpenCode build)
4. **@reviewer** — Review fix (OpenCode plan + code-snippet)
5. **@tester** — Verify (OpenCode build or project test command)

---

## PIPELINE: New Feature
`/new-feature <description>`

```
┌─────────┐   ┌──────────┐   ┌────────────┐   ┌──────────┐   ┌────────┐   ┌──────────┐   ┌────────┐   ┌────────────┐
│ @finder │ → │ @analyst │ → │ @architect │ → │ @planner │ → │ @coder │ → │@reviewer │ → │@tester │ → │@documenter │
│ Hermes  │   │ Hermes   │   │  Hermes    │   │  Hermes  │   │OpenCode│   │ OpenCode │   │OpenCode│   │   Hermes   │
│ delegat │   │ v4-pro   │   │  v4-pro    │   │ delegat  │   │ build  │   │ plan     │   │ build  │   │  delegat   │
└─────────┘   └──────────┘   └────────────┘   └──────────┘   └────────┘   └──────────┘   └────────┘   └────────────┘
```

**Steps:**
1. **@finder** — Map codebase structure, find relevant files (delegate_task)
2. **@analyst** — Analyze dependencies, risks, data flow (delegate_task, model="deepseek-v4-pro")
3. **@architect** — Design solution: components, interfaces, integration plan (delegate_task, model="deepseek-v4-pro")
4. **@planner** — Decompose architecture into atomic implementation tasks (delegate_task)
5. **@coder** — Implement each task (OpenCode build)
6. **@reviewer** — Review each implementation (OpenCode plan + code-snippet)
7. **@tester** — Write tests for each implementation (OpenCode build)
8. **@documenter** — Update docs (delegate_task)

**Revision loop at steps 5-7:** Max 3 iterations per task. If @reviewer rejects → back to @coder.

---

## PIPELINE: New Feature (Security-Related)
`/new-feature-secure <description>`

Same as New Feature but with two additions:
- **@researcher** after @analyst — Research security best practices for the feature type
- **@security** after @reviewer — Security audit (delegate_task, model="deepseek-v4-pro", toolsets=[terminal, file, web])

**If @security returns CRITICAL or HIGH findings:** pipeline STOPS immediately. Present findings to user.

**PRE-EXISTING ISSUES:** Security may find CRITICAL/HIGH issues that pre-date the current feature (e.g., missing auth, no input validation). Document them in the security report, fix any that are IN SCOPE of the current feature, do NOT block the pipeline on pre-existing issues. Explain to the user: "CRITICAL finding X is pre-existing and not introduced by this feature. The in-scope fix has been applied. Recommended to address X separately."

**Distinguish:** issue introduced by the feature → block. Issue that existed before → document, fix in-scope only, continue.

**If MEDIUM or LOW findings:** note them, continue pipeline.

```
┌─────────┐   ┌──────────┐   ┌────────────┐   ┌────────────┐   ┌──────────┐   ┌────────┐   ┌──────────┐   ┌──────────┐   ┌────────┐   ┌────────────┐
│ @finder │ → │ @analyst │ → │@researcher │ → │ @architect │ → │ @planner │ → │ @coder │ → │@reviewer │ → │@security │ → │@tester │ → │@documenter │
└─────────┘   └──────────┘   └────────────┘   └────────────┘   └──────────┘   └────────┘   └──────────┘   └──────────┘   └────────┘   └────────────┘
```

---

## PIPELINE: Refactoring
`/refactor <target> <goal>`

```
┌─────────┐   ┌──────────┐   ┌────────────┐   ┌──────────┐   ┌────────┐
│ @finder │ → │ @analyst │ → │@refactorer │ → │@reviewer │ → │@tester │
│ Hermes  │   │ Hermes   │   │  OpenCode  │   │ OpenCode │   │OpenCode│
│ delegat │   │ v4-pro   │   │  build     │   │ plan     │   │ build  │
└─────────┘   └──────────┘   └────────────┘   └──────────┘   └────────┘
```

**Steps:**
1. **@finder** — Locate the target code and all references
2. **@analyst** — Map dependencies, side effects, callers (model="deepseek-v4-pro")
3. **@refactorer** — Apply refactoring (OpenCode build) — same behavior, better structure
4. **@reviewer** — Verify no behavioral change (OpenCode plan)
5. **@tester** — Run existing tests to confirm nothing broke (OpenCode build or project tests)

**Critical rule for @refactorer:** Must NOT change API contracts or external behavior.

---

## PIPELINE: Performance Optimization
`/optimize <target>`

```
┌─────────┐   ┌──────────┐   ┌────────────┐   ┌──────────┐   ┌────────┐
│ @finder │ → │ @analyst │ → │ @optimizer │ → │@reviewer │ → │@tester │
│ Hermes  │   │ Hermes   │   │  Hermes    │   │ OpenCode │   │OpenCode│
│ delegat │   │ v4-pro   │   │  v4-pro    │   │ plan     │   │ build  │
└─────────┘   └──────────┘   └────────────┘   └──────────┘   └────────┘
```

**Steps:**
1. **@finder** — Locate target code
2. **@analyst** — Profile/analyze bottlenecks (model="deepseek-v4-pro")
3. **@optimizer** — Propose and apply optimizations (delegate_task, model="deepseek-v4-pro")
4. **@reviewer** — Review for correctness (OpenCode plan)
5. **@tester** — Run tests (OpenCode build)

**Important:** @optimizer must provide BEFORE/AFTER benchmarks.

---

## PIPELINE: Infrastructure Changes
`/infra <description>`

```
┌─────────┐   ┌──────────┐   ┌──────────┐   ┌────────┐
│ @finder │ → │ @devops  │ → │@reviewer │ → │@tester │
│ Hermes  │   │  Hermes  │   │ OpenCode │   │OpenCode│
│ delegat │   │ delegat  │   │ plan     │   │ build  │
└─────────┘   └──────────┘   └──────────┘   └────────┘
```

**Steps:**
1. **@finder** — Find relevant infra files (Docker, CI/CD, configs)
2. **@devops** — Apply infrastructure changes (delegate_task, toolsets=[terminal, file, web])
3. **@reviewer** — Review changes (OpenCode plan)
4. **@tester** — Verify (OpenCode build)

---

## Revision Loops — Universal Rules

### Quality Gates (MANDATORY — never skip)
Every single code change MUST pass @reviewer then @tester before being accepted.

### Max 3 Iterations
```
Iteration 1: Implementation → Review → Rejected? → Back to implementation
Iteration 2: Fix → Review → Still rejected? → Back again
Iteration 3: Final fix → Review → Still rejected? → ESCALATE
```

**Escalation message format:**
```
⚠️ ESCALATION — Le pipeline <nom> a bloqué après 3 itérations.
Agent: @<agent>
Retours:
1. <retour 1>
2. <retour 2>
3. <retour 3>

Que veux-tu faire ?
1. Forcer le changement malgré le refus
2. Modifier l'approche (décris la nouvelle direction)
3. Annuler cette tâche
```

### Track Iterations in Todo
Use todo to track which pipeline phase you're in and how many iterations:
```json
{"id": "pipeline-bug-fix", "content": "Bug Fix Known: transactions/page.tsx", "status": "in_progress"}
{"id": "phase-finder", "content": "@finder done", "status": "completed"}
{"id": "phase-fixer", "content": "@fixer iteration=1", "status": "completed"}
{"id": "phase-reviewer", "content": "@reviewer iteration=1", "status": "in_progress"}
```

---

## Conflict Resolution
When two agents disagree, use this priority (highest first):
1. **@security** — Blocks are absolute. CRITICAL/HIGH → stop pipeline
2. **@reviewer** — REQUEST_CHANGES → back to implementation (up to 3 iterations)
3. **@tester** — Failing tests → back to implementation
4. **Implementation agents** — Can propose alternative approaches
5. **Planning agents** — Architecture decisions can be revisited
6. **Research agents** — Findings are advisory unless proven wrong

---

## Reference Files

These files are in the skill's `references/` directory — load them with `skill_view(name='orchestrator', file_path='references/<file>.md')`:

| File | Content |
|------|---------|
| `references/opencode-timeouts.md` | Verified timeout values, context injection pattern, build vs plan modes |
| `references/sqlmodel-migration.md` | SQLModel migration patterns, raw SQL position safety, the `flagged` pattern |
| `references/security-audit-checklist.md` | Full security audit checklist for @security agent |
| `references/graphify-integration.md` | Knowledge graph integration for @finder speedup (71.5× token reduction) |
| `references/worked-examples.md` | Full transcripts of completed pipeline runs on budget-app |

## QMD Knowledge Collection (optional)

A searchable QMD collection `orchestrator-knowledge` is set up with all skills, agent prompts, execution patterns, and the Hermes+OpenCode developer guide indexed (20 files, 54 chunks, embeddings active).

Query it during a session when you need to quickly retrieve a specific pattern, timeout value, or past finding:
```bash
qmd query "<question>" --collection orchestrator-knowledge
```

## Agent Summary

| Agent | Engine | Model | Toolsets |
|---|---|---|---|
| @graphify | terminal (graphify CLI) | deepseek-v4-flash | [terminal] |
| @finder | delegate_task | deepseek-v4-flash | [terminal, file] |
| @analyst | delegate_task | deepseek-v4-pro | [terminal, file] |
| @researcher | delegate_task | deepseek-v4-flash | [web, terminal] |
| @architect | delegate_task | deepseek-v4-pro | [terminal, file] |
| @planner | delegate_task | deepseek-v4-flash | [terminal, file] |
| @coder | OpenCode build | deepseek-v4-flash | — |
| @editor | OpenCode build | deepseek-v4-flash | — |
| @fixer | OpenCode build | deepseek-v4-flash | — |
| @refactorer | OpenCode build | deepseek-v4-flash | — |
| @reviewer | OpenCode plan | deepseek-v4-flash | — |
| @tester | OpenCode build | deepseek-v4-flash | — |
| @debugger | delegate_task | deepseek-v4-pro | [terminal, file] |
| @security | delegate_task | deepseek-v4-pro | [terminal, file, web] |
| @documenter | delegate_task | deepseek-v4-flash | [terminal, file] |
| @commenter | delegate_task | deepseek-v4-flash | [terminal, file] |
| @devops | delegate_task | deepseek-v4-flash | [terminal, file, web] |
| @optimizer | delegate_task | deepseek-v4-pro | [terminal, file] |

## Execution Patterns (from 7 validated pipeline runs)

### @architect may merge @planner + @coder
When the implementation is straightforward (deterministic translation of the design into code, < 100 lines), the `@architect` subagent often produces **working code directly** alongside the design spec. This is acceptable — it saves a round-trip. Apply the `@reviewer` quality gate even more carefully in this case since the design and implementation came from the same agent.

### QMD knowledge collection setup
When building a reusable knowledge base for a project/system:
1. Collect all SKILL.md files, docs, and reference materials
2. Create a QMD collection pointing to the directory (`qmd collection add <name> <path>`)
3. Run `qmd embed -c <name>` to generate vector embeddings
4. Add a "QMD Knowledge Collection" section to the main skill with query examples
5. This enables full-text + semantic search across all project knowledge at ~2s query time

### Graphify knowledge graph (optional @finder accelerator)
When @finder is the bottleneck and the project has enough structure to benefit from graph analysis:
1. Install: `pip install graphifyy && uv tool install graphifyy --with openai`
2. Build: `DEEPSEEK_API_KEY=*** extract . --backend deepseek --model deepseek-chat`
3. Report: `graphify cluster-only .`
4. Cost: ~$0.01 for a 66-file project via DeepSeek
5. Output: graph.json (659 nodes, 1587 edges for a medium app), GRAPH_REPORT.md, graph.html
6. Use: `graphify query "<question>"` to retrieve specific relationships instead of reading all files
7. Subsequent updates: `graphify update .` (changed files only, no LLM cost)
8. See `skill_view(name='orchestrator', file_path='references/graphify-integration.md')` for full details

### GitHub repo creation via API (no gh CLI)
When `gh auth` fails (missing scopes), create repos via the REST API:
```bash
TOKEN=*** ~/.git-credentials | sed 's/.*://;s/@.*//')
curl -s -X POST \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d '{"name": "<repo-name>", "private": false, "auto_init": false}'
```
Then `git init`, `git add -A`, `git commit`, `git remote add origin git@github.com:<user>/<repo>.git`, `git push -u origin main`.

### Extracting agent skills from a monolithic orchestrator
When an orchestrator skill grows too large (prompt templates mixed with pipeline logic):
1. Create `~/.hermes/skills/agents/<name>/SKILL.md` for each agent
2. Each skill gets: YAML frontmatter (name, description, tags, model), role section, execution section (delegate_task or OpenCode), prompt template, expected output format, when-to-use, model recommendation
3. Update the orchestrator skill: replace long prompt-template sections with a compact reference table listing `skill_view(name='agents/<name>')`
4. Keep pipeline definitions, rules, execution patterns, and pitfalls in the orchestrator
5. Push to GitHub repo if applicable

### Component extraction: Approach C (grouped callbacks)
1. Group all state setters and side-effect handlers into a `Callbacks` interface object
2. Pass the object as a single `callbacks` prop (reduces prop count ~50%)
3. Use `React.memo` with a custom comparator that only re-renders when the item's own data prop changes
4. Move local UI refs (e.g., `useRef` for popup positioning) INTO the extracted component, not the parent
5. Expected impact: 245 inline lines → 334 extracted lines, ~100 lines saved in parent
6. The pattern generalizes to any framework (Vue, Svelte) — extract + group callbacks

### Docker proxy env var pattern
When Dockerizing a Next.js app that proxies API calls via `rewrites()`:
- Do NOT hardcode `127.0.0.1:8000` in next.config.ts
- Use `const API_URL = process.env.API_URL || 'http://127.0.0.1:8000'`
- In docker-compose, set `API_URL: http://backend:8000`
- This works both locally and in Docker without config file changes

### Direct patch vs OpenCode decision
| Scenario | Tool | Reason |
|----------|------|--------|
| Simple known change (1-5 lines, exact code known) | **Direct `patch()`** | Faster, no timeout risk, no re-reading |
| New file or complex logic | **OpenCode build** | LSP + edit tooling ensures correctness |
| Algorithmic optimization (find→Map, memoization) | **Direct `patch()`** | Mechanical transformation, OpenCode overkill |
| Any change where @finder already extracted the code | **Direct `patch()`** | Context already gathered |

### The Map-based O(n²) → O(1) pattern
When you find `Array.find()` or `.filter()` inside a `.map()` render loop:
```typescript
// BEFORE: O(n²) — find() called per item, each scans full array
rows.map(row => lookupTable.find(x => x.id === row.refId))

// AFTER: O(n) initial, O(1) per lookup
const lookupMap = useMemo(() => new Map(lookupTable.map(x => [x.id, x])), [lookupTable])
rows.map(row => lookupMap.get(row.refId))
```
- Use `??` not `||` for defaults with Map.get (Map returns undefined, not falsy)
- `childrenMap` (Map<parentId, children[]>) eliminates N linear scans per render
- One file per perf commit keeps diffs reviewable

### @reviewer common runtime bug catches
The reviewer catches these patterns consistently. Check for them before submitting:
1. **Nullable fields** — `tx.description`/`tx.name` can be null/undefined → `.replace()`/`.slice()` crashes. Always use `?? ''` or `?.`.
2. **Optional API fields** — `tx.date`, `tx.category_id` may not exist on all responses. Guard with `if (!x)` before accessing `.slice()` or `.find()`.
3. **CSV/text export sanitization** — `sanitizeCsvValue()` must convert input to String() first, or `.replace()` crashes on null/undefined.
4. **Dead code** — Variables computed but never used. After removing unused code, check if the comment that explains it is still accurate.

### TypeScript debugging pattern
When tsc reports a type mismatch:
1. Read the backend endpoint response (actual data shape)
2. Read the frontend API type definition (expected shape)
3. If backend returns the field but type omits it → **type-only bug**, fix the type
4. If backend genuinely doesn't return it → **data bug**, fix the backend
5. Always check both before deciding where the fix goes

## Run Patterns (from 7 validated pipelines)

### Real-world timings
| Pipeline | Steps | Duration | Notes |
|----------|-------|----------|-------|
| Bug Fix Known | @finder → @fixer → @reviewer → @tester | ~106s | Fastest path, simple change |
| Bug Fix Unknown | @finder → @debugger → @fixer → @reviewer → @tester | ~75s | @debugger identified root cause precisely |
| New Feature | @finder → @analyst → @architect → @coder → @reviewer → @tester | ~232s | Longest (@analyst+@architect with v4-pro) |
| New Feature Secure | +@researcher +@security | ~285s | Additional security research + audit |
| Performance | @finder → @analyst → @optimizer → @reviewer → @tester | ~175s | Mechanical transformations (fast) |
| Refactoring | @finder → @analyst → @refactorer → @reviewer → @tester | ~285s | Component extraction (245→334 lines), approach C |
| Infrastructure | @finder → @devops → @tester | ~85s | Docker multi-stage + compose, fast mechanical files |
| Graphify build | graphify extract + cluster-only | ~210s | 66 files, 659 nodes, ~$0.01 DeepSeek |

### Bottlenecks observed
- **@finder** is consistently the slowest step (43-88s) — it reads many files. This is the price of understanding the codebase.
- **@reviewer via OpenCode plan** can timeout on large files. Mitigation: always use `--code-snippet` with the specific lines.
- **New Feature pipelines** are dominated by @analyst+@architect (v4-pro, ~30-50s each). Acceptable for design quality.

## Common Pitfalls
- **NEVER implement code yourself** — always use the appropriate agent.
- **NEVER skip @reviewer and @tester** after any code change.
- **NEVER merge multiple agent roles** into one call — each has a specific focus.
- For @reviewer: always inject code snippet via `--code-snippet` to avoid timeout.
- For @tester: if no tests exist, run `tsc --noEmit` or equivalent as minimum.
- Track iteration counts in todo — essential for enforcing the 3-iteration limit.
- If OpenCode times out: retry with `--no-explore` + smaller code snippet.
- **Raw SQL column safety**: When adding a column to raw SQL with positional index access (e.g., `r[11]` for running_balance), ALWAYS append at END of SELECT. Add guard: `bool(r[N]) if len(r) > N else False`. Never insert mid-list — it shifts all subsequent indexes.
- **Direct patch vs OpenCode**: For simple known changes (1-5 lines, mechanical transformations like find→Map), use direct `patch()`. Reserve OpenCode for new files, complex logic, or LSP-dependent changes.
- **Nullable fields**: Before submitting to @reviewer, check if optional fields could be null causing `.slice()`/`.replace()` crashes. Use `?? ''` or `?.` consistently.
- **Pre-existing security issues**: @security may find CRITICAL/HIGH issues from before the feature. Fix in-scope ones, document pre-existing, do NOT block the pipeline on them.
