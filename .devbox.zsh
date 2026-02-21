__devbox_list_worktrees() {
  local repo_name="$1"
  ssh dev-vm "git -C ~/workspace/${repo_name}/.bare worktree list" 2>/dev/null \
    | awk '{print $1}' \
    | while read -r wt_path; do
        local name="${wt_path:t}"
        [[ "$name" != ".bare" ]] && echo "$name"
      done
}

__devbox_cleanup_worktrees() {
  local repo_name="$1"
  local force="$2"
  local bare="~/workspace/${repo_name}/.bare"

  # Verify bare repo exists
  if ! ssh dev-vm "test -d ${bare}" 2>/dev/null; then
    echo "Error: bare repo not found for '${repo_name}'." >&2
    return 1
  fi

  # Detect default branch
  local default_branch
  default_branch=$(ssh dev-vm "git -C ${bare} symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'")
  [[ -z "$default_branch" ]] && default_branch="main"

  # Fetch latest with prune
  echo "Fetching latest from origin..."
  ssh dev-vm "git -C ${bare} fetch origin --prune" 2>/dev/null

  echo "Cleaning up worktrees for ${repo_name} (default branch: ${default_branch})"
  echo ""

  local worktrees
  worktrees=$(__devbox_list_worktrees "$repo_name")

  if [[ -z "$worktrees" ]]; then
    echo "No worktrees found."
    return 0
  fi

  local removed=0
  local skipped=0

  while read -r wt; do
    [[ -z "$wt" ]] && continue
    [[ "$wt" == "$default_branch" ]] && continue

    local wt_path="~/workspace/${repo_name}/${wt}"
    local skip_reasons=()

    if [[ "$force" != "true" ]]; then
      # Check dirty working tree
      local status_output
      status_output=$(ssh dev-vm "git -C ${wt_path} status --porcelain" 2>/dev/null)
      if [[ -n "$status_output" ]]; then
        skip_reasons+=("uncommitted changes")
      fi

      # Check for unpushed commits
      local unpushed
      unpushed=$(ssh dev-vm "git -C ${bare} log ${wt} --not --remotes=origin --oneline" 2>/dev/null)
      if [[ -n "$unpushed" ]]; then
        skip_reasons+=("unpushed commits")
      fi
    fi

    if [[ ${#skip_reasons[@]} -gt 0 ]]; then
      local reason="${(j:, :)skip_reasons}"
      printf "  %-8s %s (%s)\n" "SKIP" "$wt" "$reason"
      ((skipped++))
    else
      ssh dev-vm "tmux kill-session -t '${repo_name}-${wt}'" 2>/dev/null
      local force_flag=""
      [[ "$force" == "true" ]] && force_flag="--force"
      ssh dev-vm "cd ${bare} && git worktree remove ${force_flag} ../${wt}" 2>/dev/null
      ssh dev-vm "git -C ${bare} branch -D ${wt}" 2>/dev/null
      printf "  %-8s %s\n" "REMOVED" "$wt"
      ((removed++))
    fi
  done <<< "$worktrees"

  echo ""
  echo "Done: ${removed} removed, ${skipped} skipped."
}

__devbox_init_bare_repo() {
  local repo_name="$1"

  echo -n "Git remote URL for ${repo_name}: " >&2
  local git_url
  read -r git_url
  if [[ -z "$git_url" ]]; then
    echo "Aborted: no URL provided." >&2
    return 1
  fi

  echo "Cloning bare repo..." >&2
  ssh dev-vm "git clone --bare '${git_url}' ~/workspace/${repo_name}/.bare" || return 1

  echo "Configuring fetch refspec..." >&2
  ssh dev-vm "git -C ~/workspace/${repo_name}/.bare config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'"
  ssh dev-vm "git -C ~/workspace/${repo_name}/.bare fetch origin" >&2

  local default_branch
  default_branch=$(ssh dev-vm "git -C ~/workspace/${repo_name}/.bare symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'")
  [[ -z "$default_branch" ]] && default_branch="main"

  echo "Creating initial worktree: ${default_branch}" >&2
  ssh dev-vm "cd ~/workspace/${repo_name}/.bare && git worktree add ../${default_branch} ${default_branch}" >&2

  echo "$default_branch"
}

__devbox_create_worktree() {
  local repo_name="$1"
  local worktree_name="$2"
  local bare="~/workspace/${repo_name}/.bare"

  local wt_dir="~/workspace/${repo_name}/${worktree_name}"

  if ssh dev-vm "git -C ${bare} show-ref --verify --quiet refs/remotes/origin/${worktree_name}" 2>/dev/null; then
    echo "Creating worktree from remote branch: ${worktree_name}" >&2
    ssh dev-vm "cd ${bare} && git worktree add ../${worktree_name} ${worktree_name}" >&2
    ssh dev-vm "git -C ${wt_dir} branch --set-upstream-to=origin/${worktree_name} ${worktree_name}" >&2
    echo "Pulling latest changes..." >&2
    ssh dev-vm "git -C ${wt_dir} pull" >&2
  elif ssh dev-vm "git -C ${bare} show-ref --verify --quiet refs/heads/${worktree_name}" 2>/dev/null; then
    echo "Creating worktree from local branch: ${worktree_name}" >&2
    ssh dev-vm "cd ${bare} && git worktree add ../${worktree_name} ${worktree_name}" >&2
    if ssh dev-vm "git -C ${bare} show-ref --verify --quiet refs/remotes/origin/${worktree_name}" 2>/dev/null; then
      ssh dev-vm "git -C ${wt_dir} branch --set-upstream-to=origin/${worktree_name} ${worktree_name}" >&2
      echo "Pulling latest changes..." >&2
      ssh dev-vm "git -C ${wt_dir} pull" >&2
    fi
  else
    local default_branch
    default_branch=$(ssh dev-vm "git -C ${bare} symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'")
    [[ -z "$default_branch" ]] && default_branch="main"
    echo "Creating new branch '${worktree_name}' from '${default_branch}'" >&2
    ssh dev-vm "cd ${bare} && git worktree add -b ${worktree_name} ../${worktree_name} ${default_branch}" >&2
    ssh dev-vm "git -C ${wt_dir} branch --set-upstream-to=origin/${default_branch} ${worktree_name}" >&2
    echo "Pulling latest changes..." >&2
    ssh dev-vm "git -C ${wt_dir} pull" >&2
  fi
}

__devbox_pick_worktree() {
  local repo_name="$1"

  if ! command -v fzf >/dev/null; then
    echo "Error: fzf is required for interactive worktree selection." >&2
    return 1
  fi

  local worktrees
  worktrees=$(__devbox_list_worktrees "$repo_name")

  local selection
  selection=$(printf '%s\n%s' "$worktrees" "+ Create new worktree" \
    | fzf --prompt="Select worktree: " --height=~50% --reverse)

  if [[ -z "$selection" ]]; then
    echo "Aborted." >&2
    return 1
  fi

  if [[ "$selection" == "+ Create new worktree" ]]; then
    echo -n "New worktree name: " >&2
    local new_name
    read -r new_name
    if [[ -z "$new_name" ]]; then
      echo "Aborted: no name provided." >&2
      return 1
    fi
    __devbox_create_worktree "$repo_name" "$new_name" || return 1
    echo "$new_name"
  else
    echo "$selection"
  fi
}

__devbox_connect() {
  local session_name="$1"
  local workspace_dir="$2"

  printf '\033]1;%s\007' "$session_name"

  if ssh dev-vm "tmux has-session -t '$session_name'" 2>/dev/null; then
    et dev-vm:2022 -c "tmux attach -t '$session_name'"
  else
    et dev-vm:2022 -c "cd $workspace_dir && tmux new -s '$session_name' \; split-window -v"
  fi
}

devbox() {
  local repo_name=""
  local worktree_name=""
  local cleanup=false
  local force=false

  for arg in "$@"; do
    case "$arg" in
      --cleanup) cleanup=true ;;
      --force)   force=true ;;
      *)
        if [[ -z "$repo_name" ]]; then
          repo_name="$arg"
        elif [[ -z "$worktree_name" ]]; then
          worktree_name="$arg"
        fi
        ;;
    esac
  done

  if [[ "$force" == "true" && "$cleanup" != "true" ]]; then
    echo "Error: --force can only be used with --cleanup." >&2
    return 1
  fi

  if [[ "$cleanup" == "true" && -z "$repo_name" ]]; then
    echo "Error: --cleanup requires a repo name." >&2
    return 1
  fi

  if [[ "$cleanup" == "true" ]]; then
    __devbox_cleanup_worktrees "$repo_name" "$force"
    return
  fi

  if [[ -z "$repo_name" ]]; then
    printf '\033]1;devbox\007'
    et dev-vm:2022 -c "cd ~/workspace && tmux new \; split-window -v"
    return
  fi

  # Ensure bare repo exists
  if ! ssh dev-vm "test -d ~/workspace/${repo_name}/.bare" 2>/dev/null; then
    worktree_name=$(__devbox_init_bare_repo "$repo_name") || return 1
  fi

  # Select worktree
  if [[ -z "$worktree_name" ]]; then
    worktree_name=$(__devbox_pick_worktree "$repo_name") || return 1
  fi

  # Ensure worktree directory exists
  if ! ssh dev-vm "test -d ~/workspace/${repo_name}/${worktree_name}" 2>/dev/null; then
    __devbox_create_worktree "$repo_name" "$worktree_name" || return 1
  fi

  __devbox_connect "${repo_name}-${worktree_name}" "~/workspace/${repo_name}/${worktree_name}"
}
