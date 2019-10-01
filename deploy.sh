#!/bin/bash

# Chdir to dotfiles
cd "$(dirname "$0")"

cli=(
    zsh
    vim
    git
)

plasma=(
    konsole
    dolphin
    plasma-colors
    plasma-globals
)

full=("${cli[@]} ${plasma[@]}")

for item in ${full[@]}; do
    stow -R -t "${HOME}" $item 2>/dev/null && echo "[+] deployed: $item" || echo "[-] failed: $item"
done


#######################################
# Oh My ZSH

#install oh-my-zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "[+] installing oh-my-zsh..."
        sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
fi

autosuggestions_home=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 

if [ ! -d  $autosuggestions_home ]; then
        echo "[+] installing autosuggestions for zsh..."
        git clone https://github.com/zsh-users/zsh-autosuggestions $autosuggestions_home 
fi


syntax_highlighting_home=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

if [ ! -d $syntax_highlighting_home ]; then
        echo "[+] installing syntax highlighting for zsh..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $syntax_highlighting_home 

        chmod g-w $syntax_highlighting_home -R 
        chmod o-w $syntax_highlighting_home -R 

fi


#######################################
# Finished

echo "[+] Dotfiles deploy complete!"
