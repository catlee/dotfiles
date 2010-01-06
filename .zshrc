#!/bin/zsh

# Add ~/bin to PATH
export PATH=~/bin:/opt/local/bin:/opt/local/sbin:$PATH
export MANPATH=/opt/local/share/man:$MANPATH

#bindkey -v
export EDITOR=vim
export PAGER=less

# Debian stuff
export DEBEMAIL="chris@atlee.ca"
export DEBFULLNAME="Chris AtLee"

# Python stuff
export PYTHONSTARTUP=$HOME/.pythonrc.py

# Set some sane keybindings for HOME/END
bindkey "^[OH" vi-beginning-of-line
bindkey "^[OF" vi-end-of-line
bindkey "^E" vi-end-of-line
bindkey "^A" vi-beginning-of-line
bindkey "^R" history-incremental-search-backward

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

# History stuff
setopt histfindnodups histignoredups histreduceblanks
setopt incappendhistory histexpiredupsfirst extendedhistory
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

# complete hostnames out of ssh's ~/.ssh/known_hosts
zstyle ':completion:*' use-cache on
zstyle ':completion:*' users resolve
hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*})
zstyle ':completion:*:hosts' hosts $hosts

# Nice prompt
prompt="%n@%m:%5~ [%h%1(j.%%%j.)%0(?..:%?)]%# "
#if [ -n "$DISPLAY" ]; then
    #precmd() { print -Pn "\e]0;%n@%m: %~\a"}
    #preexec() { print -Pn "\e]0;%n@%m: %~: $1\a" }
#fi

if [[ $PS1 != "" ]] then
    export CLICOLOR=1
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi
source ~/.aliases

export WORKON_HOME=$HOME/.virtualenvs
source /home/catlee/bin/virtualenvwrapper_bashrc

eval `dircolors`

export VNC_VIA_CMD='/usr/bin/ssh -f -o "ControlPath=none" -L %L:%H:%R %G -N'

# Dump core files
ulimit -c unlimited

function buildbot_activate() {
    export PYTHONPATH=$HOME/mozilla:$HOME/mozilla/buildbot:$PYTHONPATH
    export PATH=$HOME/mozilla/buildbot/bin:$PATH
}
