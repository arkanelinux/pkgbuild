# ---- Zsh configuration ---- #
# Prompt style
PS1="%n%f@%F{136}%m%f %1~ %#> "

# Zsh history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# ctrl + left/right word forwards
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Custom chars which define beginning or end of words
WORDCHARS=${WORDCHARS/\/}

# Zsh plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
