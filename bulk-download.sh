#!/bin/bash
# Uses:
# https://github.com/aliparlakci/bulk-downloader-for-reddit
# https://gist.github.com/mlgill/ad2693f17aaa720ef777

### MODIFY THESE VALUES
# Directory you wish to download the user files to, do NOT end with a slash (/).
DIRECTORY="/path/to/user/folders"
# Location of the userlist which is sent to BDFR, this should point to the file itself.
USERLIST="/path/to/userlist.txt"
# Number of parallel tmux panes to open.
THREADCOUNT=8

### DO NOT MODIFY THESE
# Current directory
CURDIR=$(pwd)
# Location to store download history
DOWNLOADEDPOSTS="$CURDIR/bdfr-logs/downloaded_posts"
# Temporary userlists
USERLISTTMP="$CURDIR/userlists"
RNDUSERLIST="$USERLISTTMP/rnduserlist"

# Set the session name
sess_name=parallel-reddit-dl
# Test if a previous session exists, if so kill
tmux has-session -t "$sess_name" 2> /dev/null
exit=$?
if [[ $exit -eq 0 ]]; then
    echo "Previous session still exists, killing..."
    tmux kill-session -t "$sess_name"
fi

# Create log directory
mkdir -p "$CURDIR/bdfr-logs"

# Update the downloaded-ids list
for file in "$CURDIR"/bdfr-logs/log*.success; do
    cat "$file" >> "$CURDIR/bdfr-logs/downloaded_posts"
    # Remove the success file so a new one can be created
    rm "$file"
done

# Check if USERLISTTMP exists, if so delete and remake it
[ -d "$USERLISTTMP" ] && rm -drf "$USERLISTTMP" && sleep 5
mkdir "$USERLISTTMP"

# Randomize list order
shuf "$USERLIST" > "$RNDUSERLIST"
# Split the userfile into THREADCOUNT number of chunks
split -a 2 -d -n r/$THREADCOUNT "$RNDUSERLIST" "$USERLISTTMP/userlist."
# Remove the generated random userlist
rm "$RNDUSERLIST"

# Execute the parallel tmux sessions
USERLISTS=$(find $USERLISTTMP -type f -printf "%f\n")

# Set the number of threads, which corresponds to the number of panes
nthread=$THREADCOUNT

# Create the session
tmux new-session -d -s "$sess_name"

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

    tmux select-pane -t "$sess_name.0"
    tmux split-window -v -p $percent
    (( ct-- ))
done

# Create the columns
if [[ $nthread -gt 2 ]]; then
    # Floor function to round down if odd
    ct=`echo "$nthread/2-1" | bc`
    while [[ $ct -ge 0 ]]; do
        tmux select-pane -t "$sess_name.$ct"
        tmux split-window -h -p 50
        (( ct-- ))
    done
fi

ct=0
while [[ $ct -lt $nthread ]]; do
    if [ $ct -lt 10 ]; then
        USERLISTPATH="$USERLISTTMP/userlist.0$ct"
        LOGPATH="$CURDIR/bdfr-logs/log0$ct"
    else
        USERLISTPATH="$USERLISTTMP/userlist.$ct"
        LOGPATH="$CURDIR/bdfr-logs/log$ct"
    fi
    process="$CURDIR/bulk-processor.sh $DIRECTORY $DOWNLOADEDPOSTS $USERLISTPATH $LOGPATH"
    end_cmd="exit"
    exec_cmd="time $process $ct $nthread && $end_cmd"
    tmux send-keys -t "$sess_name.$ct" "$exec_cmd" Enter
    (( ct++ ))
done

tmux select-pane -t "$sess_name.0"

tmux -2 attach-session -t "$sess_name"
