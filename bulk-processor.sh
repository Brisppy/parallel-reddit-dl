#!/bin/bash
DIRECTORY=$1
DOWNLOADEDPOSTS=$2
USERLIST=$3
LOGPATH=$4
BDFRDIR=$5

sleep $6

while read USER; do
    cp "$BDFRDIR/bdfr-config.conf" "$BDFRDIR/bdfr-config/config$6.conf"
    cd "$DIRECTORY"
    echo Processing "$USER"
    python3.9 -m bdfr download "$DIRECTORY" --submitted --user "$USER" --log "$LOGPATH" --file-scheme "{DATE}_{TITLE}_{SUBREDDIT}_{POSTID}" --folder-scheme "{REDDITOR}" --time-format "%Y-%m-%d_%H-%M" --exclude-id-file "$DOWNLOADEDPOSTS" --config "$BDFRDIR/bdfr-config/config$6.conf"
    # We need to extract the IDs of downloaded files in order to skip posts we've successfully downloaded.
    "$DIRECTORY/extract_successful_ids.sh" "$LOGPATH" "$LOGPATH.success"
    # Remove the log file to keep it from making new ones with varying names.
    rm "$LOGPATH"
    # Remove the config file
    rm "$BDFRDIR/bdfr-config/config$6.conf"
    sleep 5
    # Now update the non-duplicate archive
    /scripts/individual-bulk-linker.sh "$DIRECTORY/$USER" "/mnt/archive/reddit-archive/"

done <$USERLIST
