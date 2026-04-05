#!/bin/bash
# Life Hack System — Session Context Loader
# Fires on UserPromptSubmit. Outputs text reminder on first prompt only.

CACHE_DIR="${HOME}/.claude/life-hack-session-cache"
mkdir -p "$CACHE_DIR"

# Extract session_id from stdin JSON without python dependency
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | grep -o '"session_id":"[^"]*"' | head -1 | cut -d'"' -f4)
SESSION_ID="${SESSION_ID:-unknown}"

CACHE_FILE="${CACHE_DIR}/${SESSION_ID}"

# First prompt only — output context reminder
if [ ! -f "$CACHE_FILE" ]; then
    touch "$CACHE_FILE"
    cat <<'EOF'
[LIFE HACK SYSTEM ACTIVE]
Mode: Determine from user message. If slash command → follow command. If free text → DIALOGUE mode.
Commands: /setup /daily /pulse /review /goals /abyss
DIALOGUE mode first action: Read Notion context (최근 3일 Daily Log + 활성 인사이트) before responding.
Refer to CLAUDE.md for full routing rules.
EOF
fi

exit 0
