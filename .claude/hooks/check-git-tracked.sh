#!/bin/bash
# PreToolUse hook — blocks bare mv/rm on git-tracked files
#
# Runs before every Bash tool call. If the command contains a bare `mv` or
# `rm` (i.e. not already `git mv` / `git rm`) and any of the affected paths
# are tracked by git, the operation is blocked (exit 2) and the appropriate
# git equivalent is suggested instead.
#
# Skips silently when:
#   - the command already starts with `git`
#   - the working directory is not inside a git repository
#   - python3 is unavailable (argument parsing falls back gracefully)
set -euo pipefail

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('command', ''))
" 2>/dev/null || echo "")

[[ -z "$COMMAND" ]] && exit 0

# Skip commands that already use git
echo "$COMMAND" | grep -qE '^\s*git\s' && exit 0

# Skip if not inside a git repo
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

check_git_tracked() {
    local path="$1"
    [[ -z "$path" ]] && return 1
    if [[ -d "$path" ]]; then
        [[ -n "$(git ls-files -- "$path" 2>/dev/null)" ]]
    else
        git ls-files --error-unmatch -- "$path" >/dev/null 2>&1
    fi
}

get_args_after() {
    local target="$1"
    local mode="$2"
    python3 -c "
import sys, shlex
cmd, target, mode = sys.argv[1], sys.argv[2], sys.argv[3]
SHELL_OPS = {'&&', '||', ';', '|', '(', ')'}
try:
    parts = shlex.split(cmd)
except Exception:
    parts = cmd.split()
found, files = False, []
for p in parts:
    if not found and p == target:
        found = True
        continue
    if found:
        if p in SHELL_OPS:
            break
        if p.startswith('-'):
            continue
        files.append(p)
if mode == 'mv_src' and len(files) >= 2:
    print('\n'.join(files[:-1]))
else:
    print('\n'.join(files))
" "$COMMAND" "$target" "$mode"
}

# Check bare mv
if echo "$COMMAND" | grep -qE '(^|[[:space:];&|])mv[[:space:]]'; then
    SOURCES=$(get_args_after mv mv_src 2>/dev/null || echo "")
    while IFS= read -r FILE; do
        [[ -z "$FILE" ]] && continue
        if check_git_tracked "$FILE"; then
            echo "BLOCKED: '$FILE' is tracked by git. Use 'git mv $FILE <destination>' instead of 'mv' to preserve history." >&2
            exit 2
        fi
    done <<< "$SOURCES"
fi

# Check bare rm
if echo "$COMMAND" | grep -qE '(^|[[:space:];&|])rm[[:space:]]'; then
    FILES=$(get_args_after rm all 2>/dev/null || echo "")
    while IFS= read -r FILE; do
        [[ -z "$FILE" ]] && continue
        if check_git_tracked "$FILE"; then
            echo "BLOCKED: '$FILE' is tracked by git. Use 'git rm $FILE' instead of 'rm'. Add --cached to keep the local file." >&2
            exit 2
        fi
    done <<< "$FILES"
fi

exit 0
