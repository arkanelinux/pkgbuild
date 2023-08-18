# ---- Zsh configuration ---- #

autoload -Uz compinit
compinit

# Prompt style, when the hostname is set to toolbox it will load a custom promp style, this is useful for containerized development environments
if [[ ! $HOSTNAME == 'toolbox' ]]; then
	PS1="%n%f@%F{136}%m%f %1~ %#> "
else
	PS1="⬢ %n%f@%F{35}%m%f %1~ %#> "
fi

# Zsh history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# ctrl + left/right word forwards
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# shift + tab for reverse tab-completion
bindkey '^[[Z' reverse-menu-complete

zstyle ':completion:*' menu select

# Custom chars which define beginning or end of words
WORDCHARS=${WORDCHARS/\/}

# Zsh plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Use colors for ls
alias ls="ls --color=auto"

# Print username, host and filepath in title bar
precmd () {
	printf "\033]0;$(printf "$USER@$HOST " && pwd | sed -e "s;^$HOME;~;")\a"
}
