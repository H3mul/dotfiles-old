#!/bin/bash

cd "$(dirname "$0")"

while getopts "i" opt; do
        case $opt in
                i)
                        echo "installing prerequisites..."

                        #install zsh
                        if [ ! -f /bin/zsh ]; then 
                                sudo apt-get install zsh -y
                        fi

                        #install ag
                        if [ ! -f /usr/bin/ag ]; then 
                                sudo apt-get install silversearcher-ag -y
                        fi
                        ;;      
        esac
done

#install oh-my-zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "installing oh-my-zsh..."
        sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
fi

echo "creating symlinks to home directory..."
# Create symlinks in home folder for all .sym files
for s in $(find . -type f -name '*.sym'); do 
        s=$(realpath $s)
        f=${s%.sym}
        f=${f##*/}
        f="$HOME/$f"
        ln -sf $s $f;   
done

echo "creating symlinks to custom zsh themes..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    for s in $(find ./zsh -type f -name '*.zsh-theme'); do 
            s=$(realpath $s)
            f=${s##*/}
            f="$HOME/.oh-my-zsh/themes/$f"
            ln -sf $s $f;   
    done
fi

#install custom oh-my-zsh plugins if not already installed

autosuggestions_home=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 

if [ ! -d  $autosuggestions_home ]; then
        echo "installing autosuggestions for zsh..."
        git clone https://github.com/zsh-users/zsh-autosuggestions $autosuggestions_home 
fi


syntax_highlighting_home=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

if [ ! -d $syntax_highlighting_home ]; then
        echo "installing syntax highlighting for zsh..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $syntax_highlighting_home 

        chmod g-w $syntax_highlighting_home -R 
        chmod o-w $syntax_highlighting_home -R 

fi

echo "Dotfiles deploy complete!"
