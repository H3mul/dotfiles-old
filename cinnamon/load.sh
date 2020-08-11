#!/bin/bash

cd $(dirname $0)
dconf load /org/cinnamon/ < cinnamon.dconf
dconf load /org/nemo/ < nemo.dconf
dconf load /org/gtk/ < gtk.dconf
dconf load /org/gnome/ < gnome.dconf
