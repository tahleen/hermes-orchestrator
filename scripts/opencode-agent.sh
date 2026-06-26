#!/bin/bash
# OpenCode Agent Wrapper v2
# Usage: opencode-agent.sh <build|plan> <prompt> [workdir] [model] [--no-explore] [--code-snippet <code>]
#
# --no-explore: Pass --dangerously-skip-permissions to avoid deep exploration
# --code-snippet: Inline code context to inject (avoids re-reading files)
# Returns: exit code 0 on success, stdout contains result

set -euo pipefail

OPMCODE="${HOME}/.opencode/bin/opencode"
AGENT_TYPE="${1:?Usage: opencode-agent.sh <build|plan> <prompt> [workdir] [model] [--no-explore]}"
PROMPT="${2}"
WORKDIR="${3:-$PWD}"
MODEL=""
NO_EXPLORE="false"
CODE_SNIPPET=""

shift 3 2>/dev/null || true

# Parse remaining args
while [ $# -gt 0 ]; do
  case "$1" in
    --no-explore)
      NO_EXPLORE="true"
      shift
      ;;
    --model)
      MODEL="$2"
      shift 2
      ;;
    --code-snippet)
      CODE_SNIPPET="$2"
      shift 2
      ;;
    *)
      # If not a flag, treat as model (backward compat)
      if [ -z "$MODEL" ]; then
        MODEL="$1"
      fi
      shift
      ;;
  esac
done

# Build the opencode run command
RUN_ARGS=(
  "run"
  "--agent" "${AGENT_TYPE}"
  "--dir" "${WORKDIR}"
)

# Optional model override
if [ -n "$MODEL" ]; then
  RUN_ARGS+=("--model" "$MODEL")
fi

# Skip deep exploration for quick reviews
if [ "$NO_EXPLORE" = "true" ]; then
  RUN_ARGS+=("--dangerously-skip-permissions")
fi

# Build final prompt with optional code snippet injection
FINAL_PROMPT="${PROMPT}"
if [ -n "$CODE_SNIPPET" ]; then
  FINAL_PROMPT="${FINAL_PROMPT}

--- CONTEXT CODE ---
${CODE_SNIPPET}
--- END CONTEXT ---"
fi

RUN_ARGS+=("--" "${FINAL_PROMPT}")

# Execute with timeout
export OPENCODE_DISABLE_AUTOUPDATE=1
export OPENCODE_DISABLE_MOUSE=1
export OPENCODE_DISABLE_PRUNE=1

# Timeout: depends on mode and exploration
if [ "$NO_EXPLORE" = "true" ]; then
  TIMEOUT=60
elif [ "$AGENT_TYPE" = "plan" ]; then
  TIMEOUT=120
else
  TIMEOUT=180
fi

timeout $TIMEOUT "${OPMCODE}" "${RUN_ARGS[@]}" 2>&1 || {
  EXIT_CODE=$?
  if [ $EXIT_CODE -eq 124 ]; then
    echo "[OPMCODE TIMEOUT after ${TIMEOUT}s] Agent '${AGENT_TYPE}' took too long."
    echo "TIP: Add --no-explore or pass code via --code-snippet to speed up."
  fi
  exit $EXIT_CODE
}
