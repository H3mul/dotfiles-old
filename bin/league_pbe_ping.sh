#!/bin/bash

webhook=""

echo "listening to status... "
while true; do
    ping_json_cmd=`curl -s https://status.pbe.leagueoflegends.com/shards/pbe | jq ".services| .[0] | .status == \"online\""`
    if $ping_json_cmd eq "true"; then
        echo "online!"
        msg="\"PBE online gogogogogo!\""
        curl -H "Content-Type: application/json" -X POST -d "{\"content\": $msg}" $webhook
        exit
    fi
    sleep 1
done
