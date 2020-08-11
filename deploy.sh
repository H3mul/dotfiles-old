#!/bin/bash

# Chdir to dotfiles
dotfiles="$(dirname "$0")"
cd $dotfiles

export NVIM_HOME="$HOME/.config/nvim"

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

# Set up nvim home dir if we are installing it,
# otherwise stow will symlink the whole dir
if [[ " ${deploylist[@]} " =~ " nvim " ]] && [ ! -d "$NVIM_HOME" ]; then
    mkdir "$NVIM_HOME"
fi

for item in ${deploylist[@]}; do
    # Skip dconf packages as literals
    if [[ $item =~ .dconf$ ]] && [ -d "$dotfiles/$item" ]; then
        echo "[-] $item: Error - load dconf packages without the .dconf suffix. Skipping...";
        continue 
    fi

    # Stow stowable packages
    if [ -d "$dotfiles/$item" ]; then
        stow -R -t "${HOME}" $item 2>/dev/null && echo "[+] $item: stow deployed" || echo "[-] $item: stow failed"
    fi

    # Load configs for dconf packages
    if [ -d "$dotfiles/$item.dconf" ]; then
        ./${item}.dconf/load.sh && echo "[+] $item: dconf loaded from dump" || echo "[-] $item: dconf load failed"
    fi

    if [ ! -d "$dotfiles/$item.dconf" ] && [ ! -d "$dotfiles/$item" ]; then
        echo "[-] $item: Package not found."
    fi
done

# install yay
if ! command -v yay &> /dev/null; then
    echo "[+] installing yay..."
    git clone https://aur.archlinux.org/yay.git && \
    cd yay && makepkg -si && cd .. && rm -rf yay
fi

# install oh-my-zsh if not already installed
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

# install vim plug manager and plugins
if [[ " ${deploylist[@]} " =~ " nvim " ]] && [ ! -d "$NVIM_HOME/autoload/plug.vim" ]; then
    echo "[+] installing vim plug..."
    curl -fLo $NVIM_HOME/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    echo "[+] installing vim plugins..."
    nvim +PlugInstall +qall
fi
