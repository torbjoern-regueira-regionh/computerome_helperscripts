#!/usr/bin/env bash
module unload tools
module load tools
module load vscode/1.116.0

# Run code tunnel, tee output to a temp file so we can watch it
LOGFILE="$(mktemp)"
code tunnel 2>&1 | tee "$LOGFILE" &
TUNNEL_PID=$!

copy_osc52() {
  local b64
  b64=$(printf '%s' "$1" | base64 | tr -d '\n')
  printf '\033]52;c;%s\a' "$b64"
}

# Watch the log for the device code line
( tail -f "$LOGFILE" & TAIL_PID=$!
  while read -r line; do
    if [[ "$line" =~ code[[:space:]]([A-Z0-9]{4}-[A-Z0-9]{4}) ]]; then
      CODE="${BASH_REMATCH[1]}"
      echo ""
      echo "=========================================="
      echo "  GitHub login code: $CODE"
      echo "  -> copied to clipboard"
      echo "  -> https://github.com/login/device"
      echo "=========================================="

      # Try available clipboard tools
      copy_osc52 "$CODE"
      kill "$TAIL_PID" 2>/dev/null
      break
    fi
  done < <(tail -f "$LOGFILE") ) &

wait "$TUNNEL_PID"
rm -f "$LOGFILE"
