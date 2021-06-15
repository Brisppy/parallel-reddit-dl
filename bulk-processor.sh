#!/bin/bash
DIRECTORY=$1
DOWNLOADEDPOSTS=$2
USERLIST=$3
LOGPATH=$4

sleep $5

while read USER; do
    cd "$DIRECTORY"
    echo Processing "$USER"
    python3.9 -m bdfr download "$DIRECTORY" --submitted --user "$USER" --log "$LOGPATH" --file-scheme "{DATE}_{TITLE}_{SUBREDDIT}_{POSTID}" --folder-scheme "{REDDITOR}" --time-format "%Y-%m-%d_%H-%M" --exclude-id-file "$DOWNLOADEDPOSTS"
    # We need to extract the IDs of downloaded files in order to skip posts we've successfully downloaded.
    "$DIRECTORY/extract_successful_ids.sh" "$LOGPATH" "$LOGPATH.success"
    # Remove the log file to keep it from making new ones with varying names.
    rm "$LOGPATH"
    sleep 5

done <$USERLIST
