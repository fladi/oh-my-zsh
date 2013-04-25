# run command line as user root via sudo:
sudo-command-line() {
    [[ -z $LBUFFER ]] && zle up-history
    [[ $LBUFFER != sudo\ * ]] && LBUFFER="sudo $LBUFFER"
}
zle -N sudo-command-line

# Put the current command line into a \kbd{sudo} call
bindkey "^Os" sudo-command-line
