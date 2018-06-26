#!/bin/sh
test -z $1 && echo "need magnet link! $0 <magnet link>" && exit 1
test -z $2 && echo "need directory destination! $0 <magnet link> <destination>" && exit 1

$DOWNLOAD_DIR=/download/complete

# HOST=trans
# PORT=9091
TRANSMISSION=/usr/bin/transmission-cli
 
# SESSID=$(curl --silent --anyauth  "http://$HOST:$PORT/transmission/rpc" | sed 's/.*<code>//g;s/<\/code>.*//g')
# curl --silent --anyauth --header "$SESSID" "http://$HOST:$PORT/transmission/rpc" -d "{\"method\":\"torrent-add\",\"arguments\":{\"paused\":\"false\",\"filename\":\"$1\"}}"

"$TRANSMISSION" -w "$DOWNLOAD_DIR"/"$2" "$1"