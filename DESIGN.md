# Design notes

Rationale and internals behind `train`. User-facing install/usage/config live in
[README.md](README.md); this file is the "why" and the non-obvious edge cases.

## Goal

Nudge daily learning without a separate app or habit tracker. The terminal is
already opened every day — piggyback on that moment, then get out of the way.

## Non-goals

- No daemon, cron, or background process — fires from a shell-startup hook only.
- No TUI library (rich, textual, …) — plain stdin/stdout, single-keypress prompts.
- No accounts, remote config sync, or analytics dashboard — the state file is enough.
- Single-file script, stdlib only (Python 3.11+). Keep it trivially auditable and
  copy-deployable.

## Architecture (single file, top to bottom)

```
CONFIG_PATH / STATE_PATH         # env overrides (TRAIN_CONFIG / TRAIN_STATE) or OS defaults
load_config(path) -> dict
validate_config(cfg) -> None     # fail fast: unique ids, root exists, refs resolve, fields per type
load_state / save_state
should_skip(cfg, state)          # honors skip_if_done_today / timeout_hours

prompt_confirm(text) -> bool     # y / n / Enter, single keypress on a TTY
prompt_select(options) -> int

run_node(...)                    # while-loop over graph: current = graph[next_id]
main()                           # argparse, orchestration
```

Traversal is a `while` loop (`current = graph[root]` → follow `next`), not
recursion — simpler to log under `--dry-run`.

State is written when a terminal action fires (`open`, `cmd`), not on `exit` —
skipping a day doesn't count as training. Nodes flagged `no_state` (warmup nodes)
skip the write.

## Edge cases

| Situation | Behavior |
|---|---|
| Missing config | Print install hint, exit 1 |
| Malformed JSON | Print parse error + path, exit 1 |
| Broken `next`/`yes`/`no` ref | Caught in `validate_config`, clear stderr, exit 1 |
| Invalid select input (letter / out of range) | Re-prompt, no crash |
| Ctrl+C mid-prompt | Exit, don't write state |
| Ctrl+C during `cmd` | Child gets the signal; state already written on `cmd` start — acceptable |
| No browser (`webbrowser` fails) | `webbrowser.open` returns false / raises — print hint, still exit cleanly |
| SSH interactive session | Runs normally (`-t 0` satisfied) |
| SSH one-liner / scp | Skipped (non-interactive: `-t 0` false) |
| tmux/screen new pane | `SHLVL > 1` inside pane — hook won't fire; open an outer terminal instead |
| Nested shell (`zsh` in `zsh`) | `SHLVL > 1` — skipped by the `[[ $SHLVL -eq 1 ]]` guard |
| Manual `train` in a subshell | Runs (user explicitly asked) |

The shell hook guard is `[[ $SHLVL -eq 1 && -t 0 ]] && train --auto` — interactive,
top-level shell only. `--auto` applies the skip-if-done-today logic; plain `train`
always prompts.

## Future ideas

| Idea | Notes |
|---|---|
| `last_used` per node id | Weight `select` toward underused options |
| `random` node type | Pick a child uniformly or weighted |
| `sequence` node type | Run multiple `open`/`cmd` in order |
| `weight` on select options | `{label, next, weight: 3}` |
| Weekday filter | `"days": [1,2,3,4,5]` on a node or in settings |
| Streak counter | Track `streak` alongside `last_run` in state |
| `train --validate` | Standalone config check for CI / dotfiles |

## History

Started as a spec note in a personal vault; moved here once the project went
real and entered daily dogfooding (≈ v1.0.x).
