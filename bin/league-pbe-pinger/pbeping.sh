#!/bin/bash

# SETTINGS
webhook_conf="../discord_webhook.conf"
league_status_url="https://status.pbe.leagueoflegends.com/shards/pbe"

# ===========================
# GET ARGUMENTS

silent=0
if [ $# -gt 0 ];then
    if [ "$1" = "-q" ];then
        silent=1
    fi

    if [ "$1" = "-h" ];then
        echo "Usage: -q to suppress discord messages"
        exit
    fi
fi

# ===========================
# GET WEBHOOK URL

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


# ===========================
# HELPER FUNCS

discordMessage () {
    if [ $silent -eq 0 ]; then
        curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$1\"}" $webhook
        echo "Sending Discord message: $1"
    fi
}

cleanup () {
    echo "stopped listening..."
    #discordMessage "Stopped monitoring PBE."
    exit
}

# ===========================
# MAIN

trap cleanup INT

echo "listening to status... "
#discordMessage "Monitoring PBE..."

last_status=-1
inet=1
old_data=""
while true; do

    # Check internet connectivity
    if ! ping -c 1 google.com > /dev/null 2>/dev/null; then
        if [ $inet -gt 0 ]; then
            echo Disconnected from internet
            inet=0
        fi
        continue
    else
        if [ $inet -eq 0 ]; then
            echo Reconnected to internet
            inet=1
        fi
    fi

    ping_json=`curl -s $league_status_url 2>/dev/null`
    game_data=`echo "$ping_json" | jq '.services | .[] | select(.slug | . and contains("game"))'`
    game_status=`echo "$game_data" | jq '.status'`

    [[ "$game_status" = "\"online\"" ]] && new_status=1 || new_status=0

    # First loop run
    if [ $last_status -eq -1 ]; then
        last_status=$new_status
        old_data=$game_data
        echo Current game status: "$game_status"
        echo Current game data:
        echo $game_data | jq
        continue
    fi

    # Data changed from last loop
    if [ "$game_data" != "$old_data" ]; then
        echo Game data update:
        diff <(echo $old_data | jq -S .) <(echo $game_data | jq -S .)
    fi

    # State changed from last loop
    if [ $new_status -ne $last_status ]; then

        # State changed to online
        if [ $new_status = 1 ]; then
            echo PBE switched online!
            discordMessage "PBE online gogogogogo!"

        # State changed to offline
        else
            echo switched offline!
            discordMessage "PBE just went offline"
        fi
    fi

    last_status=$new_status
    old_data=$game_data
    sleep 1
done
