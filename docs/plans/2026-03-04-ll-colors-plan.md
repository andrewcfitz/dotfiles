# eza ls Aliases Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Switch ls aliases to eza with fallback to GNU ls when eza is unavailable.

**Architecture:** Replace the ls alias block in `.aliases` with a conditional that checks for eza, using eza-based aliases when available and falling back to current behavior otherwise.

**Tech Stack:** zsh, eza

---

### Task 1: Update ls alias block in .aliases

**Files:**
- Modify: `.aliases:3-11`

**Step 1: Replace the ls alias block**

Replace lines 3-11 of `.aliases` with:

```zsh
if command -v eza &>/dev/null; then
  alias ls="eza --color=auto"
  alias ll="eza -alh --git --color=auto"
  alias la="eza -A --color=auto"
  alias l="eza -alh --sort=changed --reverse --color=auto"
else
  if [[ "$OSTYPE" == "darwin"* ]]; then
    export LS_CMD="gls --color=auto"
  else
    export LS_CMD="ls --color=auto"
  fi
  alias ls="$LS_CMD"
  alias ll="$LS_CMD -alh"
  alias la="$LS_CMD -A"
  alias l="$LS_CMD -lahrtc"
fi
```

**Step 2: Verify aliases load without errors**

Run: `zsh -c 'source ~/.aliases 2>&1 && echo OK'`
Expected: `OK` (no errors)

**Step 3: Verify eza path works (if eza installed)**

Run: `zsh -c 'source ~/.aliases && type ll'`
Expected: Contains `eza` if eza is installed, `ls` otherwise.

**Step 4: Commit**

```bash
git add .aliases
git commit -m "feat: switch ls aliases to eza with GNU ls fallback"
```
