export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
if [[ ! $(ps aux | grep ssh-agent | grep -v grep) ]]; then
        eval $(ssh-agent)
fi
