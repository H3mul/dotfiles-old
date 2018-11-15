#!/bin/bash

# Create symlinks in home folder for all .sym files
for s in $(find . -type f -name '*.sym'); do 
	s=$(realpath $s)
	f=${s%.sym}
	f=${f##*/}
	f="$HOME/$f"
	ln -sf $s $f;	
done


#install oh-my-zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
fi

#install custom oh-my-zsh plugins if not already installed
if [ ! -d  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]; then
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

