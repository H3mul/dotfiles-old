#!/bin/bash

# Chdir to dotfiles
dotfiles="$(dirname "$0")"
cd $dotfiles

cli=(
    zsh
    nvim
    git
    bin
)

plasma=(
    konsole
    dolphin
    keepass
    plasma-theme
    plasma-settings
    plasma-startup
)

full=("${cli[@]} ${plasma[@]}")

deploylist=${cli[@]}

case "$1" in
        full)
            deploylist=${full[@]}
            ;;
        plasma)
            deploylist=${plasma[@]}
            ;;
        *)
            if [ -z "$1" ]; then
                # Default selection
                deploylist=${cli[@]}
            else
                # Manual package selection
                deploylist=( "$*" )
            fi
esac

for item in ${deploylist[@]}; do
    if [ -d "$dotfiles/$item" ]; then
        stow -R -t "${HOME}" $item 2>/dev/null && echo "[+] Deployed: $item" || echo "[-] failed: $item"
    else
        echo "[-] package doesnt exist: $item";
    fi
done

#######################################
# Oh My ZSH

#install oh-my-zsh if not already installed
if [[ " ${deploylist[@]} " =~ " zsh " ]] && [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[+] installing oh-my-zsh..."
    sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
fi

# install tmux plugins if not already installed

if [[ " ${deploylist[@]} " =~ " tmux " ]] && [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "[+] installing TPM (tmux package manager)..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    echo "[+] installing TPM plugins..."
    ~/.tmux/plugins/tpm/scripts/install_plugins.sh
fi

#######################################
# Finished

echo "[+] Dotfiles deploy complete!"
