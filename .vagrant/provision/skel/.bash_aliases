# Typos
alias ..='cd ..'
alias cd..='cd ..'

# Self-referencing (sensible default options).
alias ls='ls --color=auto --group-directories-first'
alias mkdir='mkdir -pv'
alias nano="nano -AES --tabsize=4"
alias rm='rm -I --preserve-root'
alias wget='wget -c'

# Shortcuts
alias ll='ls -lAh --color=auto --group-directories-first'
alias c='clear'
alias fuck='sudo "$BASH" -c "$(history -p !!)"'
alias search='grep -Irlc --color=auto'
