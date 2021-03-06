#!/bin/bash
set -x
exec &>/dev/stdout

test -z $1 && echo "need video link! $0 <video link>" && exit 1
test -z $2 && echo "need directory destination! $0 <video link> <destination>" && exit 1

BEET=/usr/local/bin/beet
FB_CMD="filebot -rename -non-strict --format \"{plex}\" --log all --output /video"

KIND=$(echo $2 | tr '[:upper:]' '[:lower:]')

if [[ $KIND = *"audio"* ]]; then
    TITLE=$(youtube-dl --add-metadata -x --extract-audio --audio-format mp3 -o '/downloads/music/%(title)s-%(id)s.%(ext)s' --print-json --no-warnings "$1" | jq -r .title) && \
        $BEET import -q /downloads/music && \
        plex-refresh $PLEX_MUSIC_LIB_ID
elif [[ $KIND = *"movie"* ]]; then
    TITLE=$(youtube-dl --format "bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best" --merge-output-format mp4 -o '/downloads/video/%(title)s-%(id)s.%(ext)s' --print-json --no-warnings "$1" | jq -r .title) && \
        $FB_CMD --db TheMovieDB -r /downloads/video/"${TITLE}" && plex-refresh $PLEX_MOVIES_LIB_ID
elif [[ $KIND = *"tv"* ]]; then
    TITLE=$(youtube-dl --format "bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best" --merge-output-format mp4 -o '/downloads/video/%(title)s-%(id)s.%(ext)s' --print-json --no-warnings "$1" | jq -r .title) && \
        $FB_CMD --db TheTVDB -r /downloads/video/"${TITLE}" && plex-refresh $PLEX_TV_LIB_ID
elif [[ $KIND = *"music"* ]]; then
    TITLE=$(youtube-dl --format "bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best" --merge-output-format mp4 -o '/video/music/%(title)s-%(id)s.%(ext)s' --print-json --no-warnings "$1" | jq -r .title) && \
        plex-refresh $PLEX_MUSIC_VIDEO_LIB_ID
elif [[ $KIND = *"talks"* ]]; then
    TITLE=$(youtube-dl --format "bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best" --merge-output-format mp4 -o '/video/talks/%(title)s-%(id)s.%(ext)s' --print-json --no-warnings "$1" | jq -r .title) && \
        plex-refresh $PLEX_TALKS_LIB_ID
fi

/usr/bin/pushover "$TITLE is complete"
