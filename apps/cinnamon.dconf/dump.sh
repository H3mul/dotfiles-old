#!/bin/bash

cd $(dirname $0)
dconf dump /org/cinnamon/ > cinnamon.dconf
dconf dump /org/nemo/     > nemo.dconf
dconf dump /org/gtk/      > gtk.dconf
dconf dump /org/gnome/    > gnome.dconf
