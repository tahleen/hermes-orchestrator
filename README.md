# 🔱 Hermes Orchestrator

Multi-agent development orchestration system for [Hermes Agent](https://hermes-agent.nousresearch.com).

**7 pipelines · 16 agents · Hermes + OpenCode integration**

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/tahleen/hermes-orchestrator/main/install.sh | bash
```

Or manually:

```bash
git clone https://github.com/tahleen/hermes-orchestrator.git
cd hermes-orchestrator
bash install.sh
```

## Prerequisites

- [Hermes Agent](https://hermes-agent.nousresearch.com) installed
- [OpenCode](https://opencode.ai) installed (for implementation & quality agents)

## Usage

1. Copy `.hermes/AGENTS.md` to your project root
2. Start Hermes in that project
3. Say: *"I need to fix a bug"* or use explicit commands:

| Command | Pipeline |
|---------|----------|
| `/bug-fix-known <desc> <file>` | Bug fix with known cause |
| `/bug-fix-unknown <symptoms>` | Bug requiring investigation |
| `/new-feature <description>` | Full new feature pipeline |
| `/new-feature-secure <description>` | Security-sensitive feature |
| `/refactor <target> <goal>` | Refactoring (same behavior, better code) |
| `/optimize <target>` | Performance optimization |
| `/infra <description>` | Infrastructure changes |

## Architecture

```
┌──────────────────────────────────────────────────┐
│ 🔱  HERMES MASTER ORCHESTRATOR                   │
│  Model: openai/gpt-5.2-high                      │
├──────────────────────────────────────────────────┤
│                                                   │
│  ┌──────────┐ ┌──────────┐ ┌───────────────────┐ │
│  │ RESEARCH │ │ PLANNING │ │ IMPLEMENTATION*    │ │
│  │ @finder  │ │@architect│ │ @coder @editor     │ │
│  │ @analyst │ │ @planner │ │ @fixer @refactorer │ │
│  │@researcher│ │          │ │ (*via OpenCode)   │ │
│  └──────────┘ └──────────┘ └───────────────────┘ │
│                                                   │
│  ┌──────────┐ ┌──────────┐ ┌───────────────────┐ │
│  │ QUALITY* │ │    DOC   │ │ INFRASTRUCTURE    │ │
│  │@reviewer │ │@documenter│ │ @devops           │ │
│  │ @tester  │ │@commenter │ │ @optimizer        │ │
│  │@debugger │ │           │ │                    │ │
│  │@security │ │           │ │                    │ │
│  └──────────┘ └──────────┘ └───────────────────┘ │
│              (*via OpenCode)                      │
└──────────────────────────────────────────────────┘
```

## Agents

| Agent | Engine | Model | Role |
|-------|--------|-------|------|
| @finder | Hermes delegate_task | v4-flash | Fast codebase scout |
| @analyst | Hermes delegate_task | v4-pro | Deep code analysis |
| @researcher | Hermes delegate_task | v4-flash | External knowledge |
| @architect | Hermes delegate_task | v4-pro | Solution design |
| @planner | Hermes delegate_task | v4-flash | Task decomposition |
| @coder | **OpenCode** build | v4-flash | Creates new code |
| @editor | **OpenCode** build | v4-flash | Modifies existing code |
| @fixer | **OpenCode** build | v4-flash | Fixes bugs |
| @refactorer | **OpenCode** build | v4-flash | Improves structure |
| @reviewer | **OpenCode** plan | v4-flash | Code review |
| @tester | **OpenCode** build | v4-flash | Testing |
| @debugger | Hermes delegate_task | v4-pro | Bug investigation |
| @security | Hermes delegate_task | v4-pro | Security audit |
| @documenter | Hermes delegate_task | v4-flash | Technical docs |
| @commenter | Hermes delegate_task | v4-flash | Code comments |
| @devops | Hermes delegate_task | v4-flash | CI/CD, Docker |
| @optimizer | Hermes delegate_task | v4-pro | Performance |

## Rules

- **Quality gates**: Every code change MUST pass @reviewer + @tester
- **Max 3 iterations**: After 3 review rejections → escalate to user
- **Conflict order**: Security > Quality > Implementation > Planning > Research
- **OpenCode timeouts**: build=180s, plan=120s, no-explore=60s

## File Structure

```
~/.hermes/
├── AGENTS.md                     → Pipeline commands & orchestrator role
├── skills/orchestrator/SKILL.md  → 7 pipelines, 16 agents, rules
└── scripts/opencode-agent.sh     → OpenCode wrapper (--no-explore, --code-snippet)
```

## License

MIT
