__devbox_list_worktrees() {
  local repo_name="$1"
  ssh dev-vm "git -C ~/workspace/${repo_name}/.bare worktree list" 2>/dev/null \
    | awk '{print $1}' \
    | while read -r wt_path; do
        local name="${wt_path:t}"
        [[ "$name" != ".bare" ]] && echo "$name"
      done
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

  if ssh dev-vm "git -C ${bare} show-ref --verify --quiet refs/remotes/origin/${worktree_name}" 2>/dev/null; then
    echo "Creating worktree from remote branch: ${worktree_name}" >&2
    ssh dev-vm "cd ${bare} && git worktree add ../${worktree_name} ${worktree_name}" >&2
  elif ssh dev-vm "git -C ${bare} show-ref --verify --quiet refs/heads/${worktree_name}" 2>/dev/null; then
    echo "Creating worktree from local branch: ${worktree_name}" >&2
    ssh dev-vm "cd ${bare} && git worktree add ../${worktree_name} ${worktree_name}" >&2
  else
    local default_branch
    default_branch=$(ssh dev-vm "git -C ${bare} symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'")
    [[ -z "$default_branch" ]] && default_branch="main"
    echo "Creating new branch '${worktree_name}' from '${default_branch}'" >&2
    ssh dev-vm "cd ${bare} && git worktree add -b ${worktree_name} ../${worktree_name} ${default_branch}" >&2
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
  local repo_name="$1"
  local worktree_name="$2"

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
