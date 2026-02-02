typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Force COLORTERM for true color support in tmux
# Necessary because mosh doesn't pass COLORTERM from the client terminal
if [[ -n "$TMUX" ]] || [[ "$TERM" == *"256color"* ]] || [[ "$TERM" == "tmux"* ]]; then
    export COLORTERM=truecolor
fi

export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH=/opt/local/bin:/opt/local/sbin:$PATH
  export PATH=$HOME/Library/Python/3.9/bin:/opt/homebrew/bin:/usr/local/bin:/usr/local/sbin:$HOME/bin:$HOME/go/bin:/opt/homebrew/bin/git:$PATH
  export PATH=$HOME/.bin:/usr/local/bin:$HOME/.dotnet:$HOME/.dotnet/tools:$HOME/workspace/mac-dev-playbook/bin:$PATH
  export PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:/usr/local/opt/libpq/bin:$PATH
  export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
  export PATH="$HOME/Library/Application Support/JetBrains/Toolbox/scripts:$PATH"
  # Added by Windsurf
  export PATH="/Users/andrew/.codeium/windsurf/bin:$PATH"
else
  export PATH="$HOME/.local/bin:$PATH"
  export PATH="$HOME/.dotnet:$PATH"
  export PATH="$HOME/.pulumi/bin:$PATH"
fi

export PATH=$HOME/workspace/dotfiles/bin:$PATH

bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

export ZSH="$HOME/.oh-my-zsh"
export ZSH_COMPDUMP="$HOME/.zcompdump"

export LANG=en_US.UTF-8

POWERLEVEL10K_MODE='nerdfont-complete'

plugins=(
  git
  jsontools
  macos
  pod
  sudo
  textmate
  web-search
  z
  kubectl
)

source $ZSH/oh-my-zsh.sh

# Configure zsh-autocomplete before loading it
zstyle ':autocomplete:*' widget-style menu-select
zstyle ':autocomplete:*' fzf-completion no

if [[ "$OSTYPE" == "darwin"* ]]; then
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source $(brew --prefix)/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
  source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  # source $(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
  
  # Unbind arrow keys from autocomplete menu navigation
  bindkey -M menuselect '^[[D' .backward-char
  bindkey -M menuselect '^[[C' .forward-char
else
  # Linux: Load plugins from oh-my-zsh custom directory
  [[ -f ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  [[ -f ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]] && \
    source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
  [[ -f ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  [[ -f ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]] && \
    source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
else
  source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme
fi

alias reload='source ~/.zshrc'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ "$OSTYPE" == "darwin"* ]]; then
  export LS_CMD="gls --color=auto"
else
  export LS_CMD="ls --color=auto"
fi
alias ls="$LS_CMD"
alias ll="$LS_CMD -alh"
alias la="$LS_CMD -A"
alias l="$LS_CMD -lahrtc"

alias gs="git status"
alias gst="git status"
alias gadd="git add -A && git status -sb"
alias update_submodules="git pull --recurse-submodules && git submodule update"
alias gp="git push origin HEAD -u"
alias gb="git co -b"
alias gd="git diff"
alias gk="gitk 2> /dev/null"
alias gcm="git commit -m"
alias grh_git_reset_hard="git reset --hard"
alias pull="git pull"
alias gpr_git_pull_rebase="git pull --rebase"
alias push="git push"

# Syntax highlighting for less (-R for RAW ^ colors)
alias less='less -R'

alias path='echo $PATH'

# Interactive delete
alias rm='rm -i'

# Verbosely show progress for move and copy
alias cp='cp -v'
alias mv='mv -v'

alias tf="terraform"

cleandd() {
  rm -rf ~/Library/Developer/Xcode/DerivedData
  echo "Removed all derived data."
}

alias cleardd=cleandd

# Generate UUID and copy to clipboard
alias uuid="uuidgen | tr -d '\n' | tr '[:upper:]' '[:lower:]'  | pbcopy && pbpaste && echo"
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

alias stop='./scripts/stop.sh'
alias start='./scripts/start.sh'
alias build='./scripts/build.sh'
alias nuke='./scripts/nuke.sh'
alias preload='./scripts/preload-data.sh'

function ShowTitle() {
  local title=$1
  local folder=$2
  clear 
  figlet -w 1000 -f starwars "$title" | lolcat -S 120 
}

alias rvcl='ShowTitle "RVChecklist" && cd ~/workspace/rvchecklist'
alias louie='ShowTitle "Louie.Camp" && cd ~/workspace/louie-camp'
alias df='ShowTitle "dotfiles" && cd ~/workspace/dotfiles'
alias mdp='ShowTitle "mac-dev-playbook" && cd ~/workspace/mac-dev-playbook'
alias ws='ShowTitle "workspace" && cd ~/workspace'

if [[ "$OSTYPE" == "darwin"* ]]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && . "$(brew --prefix)/opt/nvm/nvm.sh" # This loads nvm
  [ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && . "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion
fi

ZSH_AUTOSUGGEST_HISTORY_IGNORE="(cd *|curl *|wget *)"
ZSH_AUTOSUGGEST_STRATEGY=(completion history)

# bindkey '^I' forward-word

alias copilot="gh copilot"
alias gcs="gh copilot suggest --shell-out=/bin/sh"
alias gce="gh copilot explain"

alias claude="claude --allow-dangerously-skip-permissions"

alias docker-nas="docker -H ssh://andrew@truenas.fitzy.foo"

if [[ "$OSTYPE" == "darwin"* ]]; then
  eval "$(rbenv init - --no-rehash zsh)"
fi

command -v flux >/dev/null && . <(flux completion zsh)

devbox() {
  local session_name="$1"

  if [[ -n "$session_name" ]]; then
    # Set iTerm2 tab title to session name
    printf '\033]1;%s\007' "$session_name"

    if ssh coder-k3s "tmux has-session -t '$session_name'" 2>/dev/null; then
      mosh --ssh="ssh" coder-k3s -- tmux attach -t "$session_name"
    else
      mosh --ssh="ssh" coder-k3s -- sh -c "mkdir -p ~/workspace/$session_name && cd ~/workspace/$session_name && tmux new -s $session_name \; split-window -v"
    fi
  else
    # No session name - just go to ~/workspace
    printf '\033]1;devbox\007'
    mosh --ssh="ssh" coder-k3s -- sh -c "cd ~/workspace && tmux new \; split-window -v"
  fi
}

# 1Password service account token (mounted in development container)
[[ -f /secrets/op/credential ]] && export OP_SERVICE_ACCOUNT_TOKEN=$(cat /secrets/op/credential)

# Source secrets file if it exists (used by Coder workspaces)
[[ -f ~/.secrets ]] && source ~/.secrets

eval "$(direnv hook zsh)"
