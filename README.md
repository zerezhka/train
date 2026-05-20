# training-app

One-shot terminal prompt on shell startup. Pick what to learn, open the resource, exit.

Works on **Linux**, **macOS**, and **Windows**.

## Install

### Linux / macOS

```bash
git clone <repo-url> ~/Projects/training-app
cd ~/Projects/training-app
./install.sh
```

Add to `~/.zshrc` (bash: `~/.bashrc`):

```zsh
[[ $SHLVL -eq 1 && -t 0 ]] && train --auto
```

Ensure `~/.local/bin` is on your `PATH`.

### Windows (PowerShell)

```powershell
cd ~\Projects\training-app
.\install.ps1
```

Add `%USERPROFILE%\.local\bin` to your PATH, then to your PowerShell profile:

```powershell
if ($Host.Name -eq 'ConsoleHost') { train }
```

Requires `py` launcher (Python 3.11+ from python.org or Microsoft Store).

## Files

| OS | Config | State |
|---|---|---|
| Linux | `~/.config/train/config.json` | `~/.local/share/train/state.json` |
| macOS | `~/Library/Application Support/train/config.json` | same dir / `state.json` |
| Windows | `%APPDATA%\train\config.json` | `%LOCALAPPDATA%\train\state.json` |

Override with `TRAIN_CONFIG` / `TRAIN_STATE` env vars.

## Usage

```bash
train                  # always runs
train --auto           # skip if already done today (use in .zshrc)
train --dry-run        # walk menus only; does NOT open browser or run cmd nodes
train --config ./config.example.json --dry-run
```

## Config

Copy `config.example.json` as a starting point. Each node has `id`, `type`, and type-specific fields.

| Type | Fields |
|---|---|
| `confirm` | `prompt`, `yes`, `no` (node ids) |
| `select` | `prompt`, `options: [{label, next}]` |
| `open` | `url` — opened via system default browser |
| `cmd` | `cmd` (shell string; use OS-appropriate commands) |
| `exit` | — |

`confirm` prompts accept **y** / **n** / **Enter** on a single keypress (no Enter required on an interactive terminal).

Traversal starts at `root`. Settings:

```json
{ "skip_if_done_today": true }
```

`open` nodes use Python [`webbrowser`](https://docs.python.org/3/library/webbrowser.html):

- **Linux** — `xdg-open` / `$BROWSER`
- **macOS** — `open` via default browser
- **Windows** — default browser via `os.startfile` / registered handler

## Manual test checklist

- [ ] Fresh install: no state → full prompt
- [ ] `n` at root → silent exit, no state write
- [ ] `open` node → browser opens, `last_run` = today
- [ ] Second terminal same day → silent skip
- [ ] `train --auto` after done today → silent skip
- [ ] `train` after done today → prompts again
- [ ] `train --dry-run` → no side effects
- [ ] Broken `next` ref → clear stderr error
- [ ] Invalid select input → re-prompt

## Requirements

- Python 3.11+
- A default web browser configured on the system
