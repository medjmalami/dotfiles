#!/usr/bin/env bash

set -u

CONFIG_PATH="$HOME/.config/waybar/config.jsonc"
RUNTIME_CONFIG="${XDG_RUNTIME_DIR:-/tmp}/waybar-active.jsonc"
POLL_INTERVAL=2

pick_output() {
  local monitors_json
  monitors_json="$(hyprctl monitors -j 2>/dev/null || true)"

  python3 - "$monitors_json" <<'PY'
import json
import re
import sys

try:
    monitors = json.loads(sys.argv[1])
except Exception:
    print("")
    raise SystemExit(0)

active = [m for m in monitors if not m.get("disabled") and m.get("dpmsStatus", True)]
if not active:
    print("")
    raise SystemExit(0)

external = None
internal = None

for monitor in active:
    name = monitor.get("name", "")
    if re.match(r"^(eDP|LVDS)", name):
        if internal is None:
            internal = name
    elif external is None:
        external = name

print(external or internal or active[0].get("name", ""))
PY
}

write_runtime_config() {
  local output_name="$1"

  python3 - "$CONFIG_PATH" "$RUNTIME_CONFIG" "$output_name" <<'PY'
from pathlib import Path
import sys

source = Path(sys.argv[1])
destination = Path(sys.argv[2])
output_name = sys.argv[3]

text = source.read_text(encoding="utf-8")
start = text.find("{")
if start == -1:
    raise SystemExit("Invalid Waybar config: missing top-level object")

injected = f'\n  "output": ["{output_name}"],'
updated = text[: start + 1] + injected + text[start + 1 :]

destination.write_text(updated, encoding="utf-8")
PY
}

restart_waybar() {
  pkill -x waybar >/dev/null 2>&1 || true
  waybar -c "$RUNTIME_CONFIG" >/dev/null 2>&1 &
}

current_output=""

while true; do
  next_output="$(pick_output)"

  if [ -n "$next_output" ] && [ "$next_output" != "$current_output" ]; then
    if write_runtime_config "$next_output"; then
      restart_waybar
      current_output="$next_output"
    fi
  fi

  sleep "$POLL_INTERVAL"
done
