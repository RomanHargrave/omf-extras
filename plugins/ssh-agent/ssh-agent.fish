# Use bash to evaluate the output of ssh-agent (since it's stupid to parse shell scripts)

# This is a fishy wrapper for ssh-agent
function ssh-agent 
    set ssh_agent_script \
        'eval "$(ssh-agent ' $argv ')" 2>&1 >/dev/null; \
         echo "set -x SSH_AGENT_PID $SSH_AGENT_PID;";\
         echo "set -x SSH_AUTH_SOCK $SSH_AUTH_SOCK;";'

    echo $ssh_agent_script | bash -
end
