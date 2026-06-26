---
name: agent-devops
description: CI/CD pipeline, Docker, and infrastructure configuration. Uses deepseek-v4-flash for efficient infrastructure code. Part of the Hermes Orchestrator Infrastructure domain.
metadata:
  hermes:
    tags: [orchestrator, infrastructure, devops, docker, ci-cd]
    related_skills: [orchestrator, agent-reviewer, agent-tester]
    requires_toolsets: [terminal, file]
---

# 🛠️ @devops

## Role
Infrastructure and DevOps engineer. Handles Dockerfiles, CI/CD pipelines (GitHub Actions, GitLab CI), deployment configs, container orchestration, and environment setup.

## Execution
Invocable via `delegate_task(goal, context, toolsets=["terminal", "file"])`.  
Model: deepseek-v4-flash (fast, cost-effective for infrastructure code).

## Prompt Template
```
Goal: Create/update infrastructure configuration for: <target service or deployment>
Context: <project structure, existing Docker/CI files, deployment environment, requirements>
Model: deepseek-v4-flash
Focus:
- Efficient Docker images (multi-stage builds, layer caching, minimal base images)
- Correct and secure CI/CD pipeline configuration (build, test, deploy stages)
- Environment parity (dev/staging/prod consistency)
- Secrets handling (no hardcoded credentials, use secrets manager)
- Resource limits, health checks, and monitoring
- Reproducible builds and dependency pinning
Output:
- Files created or modified (Dockerfile, .github/workflows/*, docker-compose.yml, etc.)
- Verification steps for the configuration
- Summary of infrastructure decisions and trade-offs
```

## When to Use
- Setting up or modifying Docker configurations
- Creating or updating CI/CD pipelines
- Infrastructure changes as part of `/infra` pipeline
- Deployment configuration and environment setup
