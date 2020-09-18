#!/bin/bash
DIRECTORY=$1
DOWNLOADEDPOSTS=$2
BDFRSCRIPT=$3
USERLIST=$4

# Sleep to avoid errors with log files being created simultaneously.
sleep $5

# Iterate through provided userlist.
while read USER; do
    cd $DIRECTORY
    echo Processing $USER
    # Pass the user and other variables to BDFR to download.
    python3 $BDFRSCRIPT --submitted --user $USER --directory $DIRECTORY --no-dupes --quit --skip self --downloaded-posts $DOWNLOADEDPOSTS
done <$USERLIST
