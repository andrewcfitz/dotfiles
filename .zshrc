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
fi

export PATH=$HOME/workspace/dotfiles/bin:$PATH

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

# Load devbox functions
[[ -f ~/.devbox.zsh ]] && source ~/.devbox.zsh

# 1Password service account token (mounted in development container)
[[ -f /secrets/op/credential ]] && export OP_SERVICE_ACCOUNT_TOKEN=$(cat /secrets/op/credential)

# Source secrets file if it exists (used by Coder workspaces)
[[ -f ~/.secrets ]] && source ~/.secrets

export STARSHIP_CONFIG=~/.starship.toml

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data between sessions

if [[ "$OSTYPE" == "darwin"* ]]; then
  source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
else
  source ~/.antidote/antidote.zsh
fi

antidote load

command -v flux >/dev/null && . <(flux completion zsh)
command -v kubectl >/dev/null && . <(kubectl completion zsh)
command -v docker >/dev/null && . <(docker completion zsh)
command -v gh >/dev/null && . <(gh completion -s zsh)
command -v pulumi >/dev/null && . <(pulumi gen-completion zsh)
command -v op >/dev/null && . <(op completion zsh)

# Up/Down arrow: search history for commands starting with the current input
bindkey '^[[A' history-search-backward   # Up arrow (normal mode, e.g. raw terminal)
bindkey '^[[B' history-search-forward    # Down arrow (normal mode)
bindkey '^[OA' history-search-backward   # Up arrow (application mode, e.g. inside tmux)
bindkey '^[OB' history-search-forward    # Down arrow (application mode)

eval "$(starship init zsh)"
eval "$(direnv hook zsh)"
