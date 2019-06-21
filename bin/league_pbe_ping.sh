#!/bin/bash

webhook_conf="discord_webhook.conf"
my_dir="$(dirname "$0")"
webhook_conf_path=$my_dir/$webhook_conf

if [[ ! -f "$webhook_conf_path" ]]; then
    echo "Missing webhook config, $webhook_conf, exiting."
    exit
fi

. "$webhook_conf_path"

if [[ -z "$webhook" ]]; then
    echo "Missing discord webhook from $webhook_conf, exiting."
    exit
fi

discordMessage () {
    #curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$1\"}" $webhook
    echo "Sending Discord message: $1"
}

cleanup () {
    echo "stopped listening..."
    discordMessage "Stopped monitoring PBE."
    exit
}
trap cleanup INT

echo "listening to status... "
discordMessage "Monitoring PBE..."

last_status=-1;
while true; do
    ping_json_cmd=`curl -s https://status.pbe.leagueoflegends.com/shards/pbe | jq '.services | .[] | select(.name | . and contains("Game")) | .status'`

    echo \[$(date +%H:%M:%S)\] Current Status: $ping_json_cmd

    [[ "$ping_json_cmd" = "\"online\"" ]] && new_status=1 || new_status=0

    if [ $last_status -eq -1 ]; then
        last_status=$new_status
    fi

    if [ $new_status -ne $last_status ]; then
        if [ $new_status = 1 ]; then
            echo \[$(date +%H:%M:%S)\] switched online!
            discordMessage "PBE online gogogogogo!"
            discordMessage "PBE online gogogogogo!"
            discordMessage "PBE online gogogogogo!"
        else
            echo \[$(date +%H:%M:%S)\] switched offline!
            discordMessage "PBE just went offline"
        fi
    fi

    last_status=$new_status
    sleep 1
done
