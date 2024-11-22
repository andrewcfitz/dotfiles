export PATH=$HOME/Library/Python/3.9/bin:/opt/homebrew/bin:/usr/local/bin:/usr/local/sbin:$HOME/bin:$HOME/go/bin:/opt/homebrew/bin/git:$PATH
export PATH=$HOME/.bin:/usr/local/bin:$HOME/.dotnet:$HOME/.dotnet/tools:$HOME/workspace/mac-dev-playbook/bin:$PATH
export PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:/usr/local/opt/libpq/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

export LANG=en_US.UTF-8

POWERLEVEL9K_MODE='nerdfont-complete'
ZSH_THEME="powerlevel10k/powerlevel10k"

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

alias reload='source ~/.zshrc'

export LS_CMD="gls --color=auto"
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

alias rider="$HOME/workspace/mac-dev-playbook/bin/rider"

#customize powerlevel
POWERLEVEL9K_DISABLE_RPROMPT=true
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_git_pair custom_card_number context dir vcs)
POWERLEVEL9K_CUSTOM_GIT_PAIR="git config --get user.initials"
#POWERLEVEL9K_CUSTOM_GIT_PAIR_BACKGROUND="blue"
#POWERLEVEL9K_CUSTOM_GIT_PAIR_FOREGROUND="yellow"
POWERLEVEL9K_CUSTOM_CARD_NUMBER="card_number"
POWERLEVEL9K_CUSTOM_CARD_NUMBER_BACKGROUND="grey"
POWERLEVEL9K_CUSTOM_CARD_NUMBER_FOREGROUND="040"

export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && . "$(brew --prefix)/opt/nvm/nvm.sh" # This loads nvm
[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && . "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
