#!/bin/bash

cd $(dirname $0)
dconf load /com/gexperts/Tilix/ < tilix.dconf
