#!/bin/bash
# Uses:
# https://github.com/aliparlakci/bulk-downloader-for-reddit
# https://gist.github.com/mlgill/ad2693f17aaa720ef777

### MODIFY THESE VALUES
DIRECTORY=/mnt/redditdl
# Either edit this, or move bulk-downloader-for-reddit to /opt/
BDFRSCRIPT=/opt/bulk-downloader-for-reddit/script.py
USERLIST=/mnt/redditdl/users.txt
THREADCOUNT=8

### DO NOT MODIFY
# File which keeps track of what has been downloaded
DOWNLOADEDPOSTS=$DIRECTORY/downloaded_posts
# Temporary userlists
USERLISTTMP=$DIRECTORY/userlists

# Check if USERLISTTMP exists
[ -d "$USERLISTTMP" ] && rm -drf $USERLISTTMP && sleep 5
mkdir "$USERLISTTMP"

# Split the userfile into THREADCOUNT number of chunks
split -a 2 -d -n r/$THREADCOUNT $USERLIST $USERLISTTMP/userlist.

# Execute the parallel tmux sessions
USERLISTS=$(find $USERLISTTMP -type f -printf "%f\n")

### This script was created by Michelle L. Gill, and modified to work with parallel-reddit-dl.
# Set the number of threads, which corresponds to the number of panes
nthread=$THREADCOUNT
# Set the session name 
sess_name=parallel-reddit-dl

# Test if the session exists
tmux has-session -t $sess_name 2> /dev/null
exit=$?
if [[ $exit -eq 0 ]]; then
    echo "Session not created because it already exists. Exiting."
    exit 0
fi

# Create the session
tmux new-session -d -s $sess_name

# Set the number of rows 
nrow=0
if [[ $nthread -eq 2 ]]; then
    nrow=2
elif [[ $nthread -gt 2 ]]; then
    # Ceiling function to round up if odd
    nrow=`echo "($nthread+1)/2" | bc`
fi

# Create the rows
ct=$nrow
while [[ $ct -gt 1 ]]; do
    frac=`echo "scale=2;1/$ct" | bc`
    percent=`echo "($frac * 100)/1" | bc`

    tmux select-pane -t $sess_name.0
    tmux split-window -v -p $percent
    (( ct-- ))
done

# Create the columns
if [[ $nthread -gt 2 ]]; then
    # Floor function to round down if odd
    ct=`echo "$nthread/2-1" | bc`
    while [[ $ct -ge 0 ]]; do
        tmux select-pane -t $sess_name.$ct
        tmux split-window -h -p 50
        (( ct-- ))
    done
fi

ct=0
while [[ $ct -lt $nthread ]]; do
    process="$DIRECTORY/bulk-processor.sh $DIRECTORY $DOWNLOADEDPOSTS $BDFRSCRIPT $USERLISTTMP/userlist.0$ct"
    exec_cmd="time $process $ct $nthread"
    tmux send-keys -t $sess_name.$ct "$exec_cmd" Enter
    (( ct++ ))
done

tmux select-pane -t $sess_name.0

tmux -2 attach-session -t $sess_name
