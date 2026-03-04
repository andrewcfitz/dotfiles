# ll Alias Colorization Design

## Goal

Add richer file type color distinction to the `ll` alias and related ls aliases.

## Decision

Switch from GNU ls to **eza** as the primary listing tool, with a fallback to GNU ls when eza is not installed.

## Design

Replace the ls-related block in `.aliases` (lines 3-11) with a conditional that checks for eza availability:

- **eza available:** Use eza-based aliases with `--git` for git status in long listings
- **eza unavailable:** Fall back to current GNU ls / gls behavior

### Alias mapping (eza path)

| Alias | Command |
|-------|---------|
| `ls`  | `eza --color=auto` |
| `ll`  | `eza -alh --git --color=auto` |
| `la`  | `eza -A --color=auto` |
| `l`   | `eza -alh --sort=changed --reverse --color=auto` |

### Fallback (no eza)

Unchanged from current behavior: `gls --color=auto` on macOS, `ls --color=auto` on Linux.

## Scope

Only the ls alias block in `.aliases` changes. No other aliases or config files are affected.

## Notes

- No icons (no Nerd Font dependency)
- eza is actively maintained (fork of exa)
- eza needs to be installed separately (apt, brew, or cargo)
