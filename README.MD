# parallel-reddit-dl
This script can be used to download a large number of user profiles using parallel tmux panes to speed up the process.
To add users, simply add their reddit username to a file with each separate user on a new line. Pass this file to parallel-reddit-dl as the USERLIST variable.

# Requirements
Python 3
ffmpeg

# Installation
Download parallel-reddit-dl.
```
git clone https://github.com/Brisppy/parallel-reddit-dl
```

Download bulk-downloader-for-reddit (BDFR).
```
git clone https://github.com/aliparlakci/bulk-downloader-for-reddit
mv ./bulk-downloader-for-reddit /opt/
```

Run BDFR once to authenticate for Reddit.
```
python3 /opt/bulk-downloader-for-reddit/script.py
```

Copy the credentials from config.json in your HOME directory, and insert them into the provided config.json, which should now look like this:
```
{
    "credentials": {
        "reddit_username": "YOUR_USERNAME_HERE",
        "reddit": "YOUR_TOKEN_HERE"
    },
    "filename": "{DATE}_{TITLE}_{SUBREDDIT}_{POSTID}",
    "folderpath": "{REDDITOR}",
    "options": ""
}
```

Modify the variables in bulk-downloader.sh to match your environment.
| Variable | Function |
|-------|------|
|```DIRECTORY```|Directory you wish to download the user files to, do not end with a slash (/). (e.g /mnt/redditdl)
|```BDFRSCRIPT```|Location of the script.py file within bulk-downloader-for-reddit, make sure this is the script.py file itself. You only need to edit this if you did not move bulk-downloader-for-reddit to /opt/. (e.g /opt/bulk-downloader-for-reddit/script.py)
|```USERLIST```|Location of the userlist which is sent to BDFR, this should point to the file itself. (e.g /mnt/redditdl/users.txt)
|```THREADCOUNT```|Number of parallel tmux panes to open.

# To-do
Close the tmux session after all panes have completed.

# Issues
Currently, BDFR does not work for Imgur (Hopefully fixed in next BDFR release).
Occasionally one of the BDFR panes will stop processing, simply move to the pane (CTRL+B, ARROW KEYS) and CTRL+C to move to the next user.

# Credits
Michelle L. Gill for their parallel tmux script.
```
https://gist.github.com/mlgill/ad2693f17aaa720ef777
```

Ali Parlakçı for bulk downloader for reddit which this script is built upon.
```
https://github.com/aliparlakci/bulk-downloader-for-reddit
```
