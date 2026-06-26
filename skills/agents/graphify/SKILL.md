---
name: agent-graphify
description: Knowledge graph agent. Builds or queries a codebase knowledge graph to accelerate codebase understanding. Optional first step in orchestrator pipelines.
metadata:
  hermes:
    tags: [orchestrator, research, graph, knowledge-graph]
    related_skills: [orchestrator, agents/finder, agents/analyst, agents/architect]
    requires_toolsets: [terminal, file]
---
# 🕸️ @graphify — Knowledge Graph Agent

## Role
Builds or queries a codebase knowledge graph using Graphify. When available, the graph provides **instant answers** about codebase structure, dependencies, communities, and god nodes — replacing slow file-by-file exploration.

## When to Use
- **Before @finder** in any pipeline (optional but recommended for large codebases)
- When you need to understand codebase structure quickly
- Before making architecture decisions
- When @finder is taking too long (>60s) on large projects

## How It Works

### Phase 1: Check Graph Availability
```bash
ls graphify-out/graph.json 2>/dev/null
```

If the graph exists and is recent, **skip to Phase 2** (query mode).
If the graph doesn't exist or is stale, **build it**:

```bash
DEEPSEEK_API_KEY=*** extract . --backend deepseek --model deepseek-chat
graphify cluster-only .
```

### Phase 2: Query the Graph
```bash
graphify query "<question>" --budget 2000
```

Available query types:
- `graphify query "find all files related to accounts"` — BFS traversal
- `graphify path "ComponentA" "ComponentB"` — shortest path between two nodes
- `graphify explain "Transaction"` — plain-language explanation of a node
- `graphify affected "get_engine"` — find nodes impacted by a change

## Expected Output

When queried, produce a structured answer with:

### 🕸️ Graph Query Result
**Question:** <what was asked>

**Answer:** <concise answer based on graph traversal>

**Source nodes:** <relevant nodes from the graph>
**Communities:** <relevant communities>
**Confidence:** <high/medium/low — based on graph connectivity>

## Integration with Orchestrator Pipelines

When @graphify is enabled, add it as an **optional step 0** before @finder:

```
Step 0 (optional): @graphify — build/query knowledge graph
Step 1: @finder — locate specific files (guided by graph)
Step 2+: remaining pipeline steps
```

The graph output should be passed as context to @finder:
```
Context from @graphify:
- Graph: graphify-out/graph.json
- God nodes: get_engine(), Transaction, Account, Category
- Communities: API Routes, Data Models, UI Components
- Relevant files from query: <list>
```

## Cost & Performance

| Action | Tokens | Time | Cost |
|--------|--------|------|------|
| Build graph (first time) | ~17K in / ~30K out | ~2-5 min | ~$0.01 (DeepSeek) |
| Query graph | ~1.7K | ~2-5s | ~$0.0001 |
| Update graph (after code changes) | ~2-5K | ~30s | ~$0.001 |

## Prerequisites
- Graphify installed: `pip install graphifyy` or `uv tool install graphifyy --with openai`
- API key: `DEEPSEEK_API_KEY`, `OPENAI_API_KEY`, or `ANTHROPIC_API_KEY`
- For first build: ~2-5 minutes (AST + semantic extraction)
