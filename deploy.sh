#!/bin/bash

for s in $(find . -type f -name '*.sym'); do 
	s=$(realpath $s)
	f=${s%.sym}
	f=${f##*/}
	f="$HOME/$f"
	ln -sf $s $f;	
done
