#!/bin/bash

cd $(dirname $0)
dconf dump /com/gexperts/Tilix/ > tilix.dconf
