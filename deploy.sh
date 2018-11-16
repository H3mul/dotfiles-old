#!/bin/bash

#install zsh
sudo apt-get install zsh -y && chsh -s /bin/zsh

#install oh-my-zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
fi

# Create symlinks in home folder for all .sym files
for s in $(find . -type f -name '*.sym'); do 
	s=$(realpath $s)
	f=${s%.sym}
	f=${f##*/}
	f="$HOME/$f"
	ln -sf $s $f;	
done

#install custom oh-my-zsh plugins if not already installed

autosuggestions_home=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 

if [ ! -d  $autosuggestions_home ]; then
	git clone https://github.com/zsh-users/zsh-autosuggestions $autosuggestions_home 
fi


syntax_highlighting_home=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

if [ ! -d $syntax_highlighting_home ]; then
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $syntax_highlighting_home 

	chmod g-w $syntax_highlighting_home -R 
	chmod o-w $syntax_highlighting_home -R 

fi

