#!/bin/bash

cmd=`curl -s https://status.pbe.leagueoflegends.com/shards/pbe | jq ".services| .[0] | .status == \"online\""`
webhook="https://discordapp.com/api/webhooks/590990281596338181/UXZdLlsSdrctz5Aus5dC2qGDlrw5G9amqlsafSImSi2Mb8jc-0f40e09REoWlsToCbtf"

if $cmd eq "true"; then
    echo "online!"
    msg="\"PBE online gogogogogo!\""
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": $msg}" $webhook
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": $msg}" $webhook
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": $msg}" $webhook
    exit
else
    echo "offline!"
fi
