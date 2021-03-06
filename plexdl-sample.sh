#!/bin/bash
# plexdl - Uses curl to send a magnet or youtube link to a webhook to end up in plex
# Copyright 2019,  Neil Grogan
PROGNAME=${0##*/}
VERSION="0.1"
HOOK_URL="http://ballyda.com:8080/hooks/"
set -e
# Logging stuff.
function error()    { echo -e " \033[1m\033[31m✖\033[0m  $@"; }

main(){
	check_args
	get_hook_type
	get_media_type
	post_webhook
}

check_clipboard(){
  if [[ -x $(command -v xclip) ]]; then
    uri=$(xclip -selection clipboard -o)
  elif [[ -x $(command -v pbpaste) ]]; then
    uri=$(pbpaste)
  elif [[ -e /dev/clipboard ]]; then
    uri=$(cat /dev/clipboard)
  else
    error "Could net get the URI from the clipboard"
    exit 1
  fi
}

check_args(){
  #debug "Checking Email, URL and Text to Find are not empty"
  if [[ -z $type ]]; then
    error "You are missing the 'type' argument, please see usage:"
    echo "$(usage)"
    exit 1
  fi

  if [[ -z $uri ]]; then
    check_clipboard
    if [[ -z $uri ]] && [[ $uri != "magnet:"* ]] || [[ $uri != "magnet:"* ]]; then
      error "You are missing  or have an invalid 'uri' argument, please see usage:"
      echo "$(usage)"
      exit 1
    fi
    #TODO alternate failure points here
  fi
}

get_hook_type(){
  if [[ $uri == "magnet:"* ]]; then
    hook="add-torrent"
  elif [[ $uri == "http"* ]]; then
    hook="yt-dl"
  else
    error "Webhook to use cannot be determined from URI: $uri"
    exit 1
  fi
}

get_media_type(){
  local t=$(echo "$type" | tr '[:upper:]' '[:lower:]')
  if [[ $t == "t"* ]]; then
    media="TV Shows"
  elif [[ $t == "mu"* ]]; then
    media="Music"
  elif [[ $t == "mo"* ]]; then
    media="Movies"
  elif [[ $t == "v"* ]]; then
    media="Video"
  else
    error "I cannot work out a valid media type for: $t"
    exit 1
  fi
}

post_webhook(){
  local token=$(cat ~/.webhook)
  curl -X POST --data "token=$token" --data "type=$media" --data "uri=$uri" "$HOOK_URL$hook"
}

help_message() {
	cat <<- _EOF_
	$PROGNAME ver. $VERSION
	Uses curl to send a magnet or youtube link to a webhook to end up in plex.
	$(usage)
	Options:
	-t, --type	Set the type of download (Music/TV/Movies etc)
	-u, --uri	The URI/URL to download
	-h, --help	Display this help message and exit.
	_EOF_
	return
}

usage() {
	echo -e "Usage: $PROGNAME [-t|--type] [-u|--url] <uri>"
}

# Parse command-line
while [[ -n $1 ]]; do
	case $1 in
                -t | --type)	type=$2; shift ;;
		-h | --help)	help_message; exit 0 ;;
		-u | --uri)	uri=$2; shift ;;
		-* | --*)	usage; exit -1 "Unknown option $1" ;;
		*)		echo "Argument $1 to process..." ;;
	esac
	shift
done

main
