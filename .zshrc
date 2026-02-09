# typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# # Initialization code that may require console input (password prompts, [y/n]
# # confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# Force COLORTERM for true color support in tmux
# Necessary because mosh doesn't pass COLORTERM from the client terminal
if [[ -n "$TMUX" ]] || [[ "$TERM" == *"256color"* ]] || [[ "$TERM" == "tmux"* ]]; then
    export COLORTERM=truecolor
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH=/opt/local/bin:/opt/local/sbin:$PATH
  export PATH=$HOME/Library/Python/3.9/bin:/opt/homebrew/bin:/usr/local/bin:/usr/local/sbin:$HOME/bin:$HOME/go/bin:/opt/homebrew/bin/git:$PATH
  export PATH=$HOME/.bin:/usr/local/bin:$HOME/.dotnet:$HOME/.dotnet/tools:$HOME/workspace/mac-dev-playbook/bin:$PATH
  export PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:/usr/local/opt/libpq/bin:$PATH
  export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
  export PATH="$HOME/Library/Application Support/JetBrains/Toolbox/scripts:$PATH"
  # Added by Windsurf
  export PATH="/Users/andrew/.codeium/windsurf/bin:$PATH"

  export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
else
  export PATH="$HOME/.local/bin:$PATH"
  export PATH="$HOME/.dotnet:$PATH"
  export PATH="$HOME/.pulumi/bin:$PATH"

  export DOCKER_HOST=tcp://localhost:2375
fi

export PATH=$HOME/workspace/dotfiles/bin:$PATH

# bindkey "^[[1;3C" forward-word
# bindkey "^[[1;3D" backward-word

export ZSH="$HOME/.oh-my-zsh"
export ZSH_COMPDUMP="$HOME/.zcompdump"

# export LANG=en_US.UTF-8

# POWERLEVEL10K_MODE='nerdfont-complete'

# plugins=(
#   git
#   jsontools
#   macos
#   pod
#   sudo
#   textmate
#   web-search
#   z
#   kubectl
# )

# source $ZSH/oh-my-zsh.sh

# # Configure zsh-autocomplete before loading it
# zstyle ':autocomplete:*' widget-style menu-select
# zstyle ':autocomplete:*' fzf-completion no

# if [[ "$OSTYPE" == "darwin"* ]]; then
#   source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
#   source $(brew --prefix)/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
#   source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#   # source $(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
  
#   # Unbind arrow keys from autocomplete menu navigation
#   bindkey -M menuselect '^[[D' .backward-char
#   bindkey -M menuselect '^[[C' .forward-char
# else
#   # Linux: Load plugins from oh-my-zsh custom directory
#   [[ -f ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
#     source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
#   [[ -f ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]] && \
#     source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
#   [[ -f ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
#     source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#   [[ -f ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]] && \
#     source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
# fi

# if [[ "$OSTYPE" == "darwin"* ]]; then
#   source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
# else
#   source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme
# fi

# # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load aliases
[[ -f ~/.aliases ]] && source ~/.aliases

if [[ "$OSTYPE" == "darwin"* ]]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && . "$(brew --prefix)/opt/nvm/nvm.sh" # This loads nvm
  [ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && . "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  eval "$(rbenv init - --no-rehash zsh)"
fi

command -v flux >/dev/null && . <(flux completion zsh)

devbox() {
  local repo_name="$1"

  if [[ -n "$repo_name" ]]; then
    local session_name="${repo_name}"
    local workspace_dir="~/workspace/${repo_name}"

    printf '\033]1;%s\007' "$session_name"

    if ssh coder "tmux has-session -t '$session_name'" 2>/dev/null; then
      et coder:2022 -c "tmux attach -t '$session_name'"
    else
      et coder:2022 -c "mkdir -p $workspace_dir && cd $workspace_dir && tmux new -s '$session_name' \; split-window -v"
    fi
  else
    printf '\033]1;devbox\007'
    et coder:2022 -c "cd ~/workspace && tmux new \; split-window -v"
  fi
}

# 1Password service account token (mounted in development container)
[[ -f /secrets/op/credential ]] && export OP_SERVICE_ACCOUNT_TOKEN=$(cat /secrets/op/credential)

# Source secrets file if it exists (used by Coder workspaces)
[[ -f ~/.secrets ]] && source ~/.secrets

export STARSHIP_CONFIG=~/.starship.toml

if [[ "$OSTYPE" == "darwin"* ]]; then
  source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
else
  source ~/.antidote/antidote.zsh
fi

antidote load

autoload -Uz compinit && compinit

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

eval "$(starship init zsh)"

eval "$(direnv hook zsh)"
