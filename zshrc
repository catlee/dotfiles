export PATH=$HOME/bin:$PATH

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="af-magic"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git git-extras tmux taskwarrior python virtualenv ssh-agent gpg-agent pip)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export EDITOR=vim
export PAGER=less

# Debian stuff
export DEBEMAIL="chris@atlee.ca"
export DEBFULLNAME="Chris AtLee"

# Python stuff
#export PYTHONSTARTUP=$HOME/.pythonrc.py

# Ctrl-H runs man
bindkey "^H" run-help

# Ctrl-J runs the command, and displays it again
bindkey "^J" accept-and-hold
# Don't print an error if no matches for glob
setopt nonomatch

# Directory stacks
setopt autopushd pushdignoredups

setopt extendedglob
setopt shwordsplit
setopt PROMPT_SUBST

# History stuff
setopt histfindnodups histignoredups histreduceblanks
setopt incappendhistory histexpiredupsfirst extendedhistory
unsetopt share_history
HISTFILE=~/.zsh_history
SAVEHIST=10000
HISTSIZE=20000
setopt HIST_EXPIRE_DUPS_FIRST

# TAB-completion
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' orignal only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
#zstyle :compinstall filename '/home/catlee/.zshrc'
autoload -U compinit
compinit

source ~/.aliases
export WORKON_HOME=$HOME/.virtualenvs
export PIP_DOWNLOAD_CACHE=$WORKON_HOME/pip_cache
VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
#source $HOME/venv/bin/virtualenvwrapper.sh
source /etc/bash_completion.d/virtualenvwrapper

export HG_SHARE_BASE_DIR=$(readlink -f $HOME/repos)
export GIT_SHARE_BASE_DIR=$(readlink -f $HOME/repos/git)
export ARDUINO_INSTALL_DIR=$HOME/projects/arduino-1.0
export REPORTTIME=60

function ressh() {
    eval `ressh.sh`
}

function ruston() {
    export PATH=/opt/rust/bin:$PATH
    export LD_LIBRARY_PATH=/opt/rust/lib:$LD_LIBRARY_PATH
}

#export PYENV_ROOT=$HOME/.pyenv
#export PATH=$PYENV_ROOT/bin:$PATH
#eval "$(pyenv init -)"
#eval "$(pyenv virtualenv-init -)"
