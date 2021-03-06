clear
echo
neofetch

export CLICOLOR=1
export TERM=xterm-256color
export PATH="/usr/local/bin:/usr/local/sbin:$HOME/.anyenv/bin:$PATH"
export PATH_TO_FX=/Library/Java/JavaVirtualMachines/javafx-sdk-11.0.2/lib
export EDITOR=nvim
export XDG_CONFIG_HOME=~/.config

if $(hash anyenv >& /dev/null); then; eval "$(anyenv init -)"; fi
if $(hash yarn >& /dev/null); then; export PATH="$(yarn global bin):$PATH"; fi

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

bindkey -e

########################################

autoload -Uz colors
autoload -Uz select-word-style
autoload -Uz compinit
autoload -Uz add-zsh-hook
autoload -Uz vcs_info

colors
select-word-style default
compinit

########################################

zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

zstyle ':vcs_info:*' formats '[%F{green}%b%f]'
zstyle ':vcs_info:*' actionformats '[%F{green}%b%f(%F{red}%a%f)]'

PROMPT="%{${fg[green]}%}[%n@%m]%{${reset_color}%} %~%(?.%{${fg[blue]}%}.%{${fg[red]}%})\$%{${reset_color}%} "

########################################

function _pre_cmd() {
  LANG=en_US.UTF-8 vcs_info
  RPROMPT="${vcs_info_msg_0_}"
  grep $TTY ~/.zsh_status > /dev/null && grep -v $TTY ~/.zsh_status | sed '/^$/d' > ~/.zsh_status_tmp && mv ~/.zsh_status_tmp ~/.zsh_status
  echo $TTY `pwd` `date +%s` >> ~/.zsh_status
}

function _set_pwd() {
  grep $TTY ~/.zsh_status > /dev/null && grep -v $TTY ~/.zsh_status | sed '/^$/d' > ~/.zsh_status_tmp && mv ~/.zsh_status_tmp ~/.zsh_status
  echo $TTY `pwd` `date +%s` >> ~/.zsh_status
}

function _zsh_exit() {
  grep -v $TTY ~/.zsh_status | sed '/^$/d' > ~/.zsh_status_tmp && mv ~/.zsh_status_tmp ~/.zsh_status
}

function his() {
  if [ $BUFFER ]; then
    CMD=`history -n 1 | awk '!a[$0]++' | fzf --tac -q $BUFFER`
  else
    CMD=`history -n 1 | awk '!a[$0]++' | fzf --tac`
  fi
  if [ $CMD ]; then
    echo $CMD
    eval $CMD
    BUFFER=""
    zle reset-prompt
  fi
}

add-zsh-hook precmd _pre_cmd
add-zsh-hook chpwd _set_pwd
add-zsh-hook zshexit _zsh_exit

zle -N his
bindkey '^H' his

########################################

alias la='ls -al'
alias g="git add -A; git commit; git push origin \`git symbolic-ref --short HEAD\`"
alias gp="gitmoji -c && git push origin \`git symbolic-ref --short HEAD\`"
alias vi='nvim'
alias vim='nvim'
alias rm='trash-put'
alias rls='$TERMINAL -q --profile=ls -- ~/.rls.sh $TTY'

########################################

setopt print_eight_bit
setopt no_flow_control
setopt ignore_eof
setopt interactive_comments
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt extended_glob
setopt correct
setopt prompt_subst
setopt nonomatch
setopt share_history

if type pacman > /dev/null ; then
  alias pbcopy='xsel --clipboard --input'
  if [ -e /opt/coreutils/bin/ls ]; then
    alias ls='/opt/coreutils/bin/ls -GFh --color=auto'
  else
    alias ls='ls -GFh --color=auto'
  fi
  if [ $USER != "root" ]; then
    alias pacman='sudo pacman'
  fi
  export TERMINAL="gnome-terminal"
elif uname -a | grep Darwin > /dev/null ; then
  alias ls="ls -Gh"
  export TERMINAL="osascript - "$@" <<EOF
on run argv
tell application "iTerm"
    activate
    set new_term to (create window with default profile)
    tell new_term
        tell the current session
            repeat with arg in argv
               write text arg
            end repeat
        end tell
    end tell
end tell
end run
EOF"
fi
export PATH="$PATH:/Users/mizucoffee/Library/Android/sdk/platform-tools"
