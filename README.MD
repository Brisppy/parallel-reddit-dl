# ⏸️ parallel-reddit-dl ⏸️
This script can be used to download a large number of user profiles using parallel tmux panes to speed up the process. The purpose of this script is to keep a running archive of a reddit user's profile through scheduling this script to run frequently, grabbing any new images, videos and text posts.


# How to use
After installing, move (cd) to the parallel-reddit-dl directory and simply run bulk-download.sh.

To add users, simply add their reddit username to a file with each separate user on a new line (as shown below). Pass the file path to parallel-reddit-dl as the **USERLIST** variable in ```bulk-download.sh```.
```
spez
Gallowboob
kn0thing
```


# Requirements
* **Python 3.5 (Or newer)**
* **[ffmpeg](https://ffmpeg.org/)**


# Installation
1. Download parallel-reddit-dl to /opt/.
```
git clone https://github.com/Brisppy/parallel-reddit-dl /opt/
```

2. Install bulk-downloader-for-reddit (BDFR).
```
python3 -m pip install bdfr
```

3. Modify the default BDFR configuration file. Change `backup_log_count = 3` to `backup_log_count = 0`.
```
nano ~/.config/bdfr/default_config.cfg
```


4. Modify the variables in ```bulk-downloader.sh``` to match your environment.
| Variable | Function |
|-------|------|
|```DIRECTORY```|Directory you wish to download the user files to, do NOT end with a slash (/). (e.g /mnt/redditdl)
|```USERLIST```|Location of the userlist which is sent to BDFR, this should point to the file itself. (e.g /mnt/redditdl/users.txt)
|```THREADCOUNT```|Number of parallel tmux panes to open.


# Notes
* Not all content hosts are supported for download, see bdfr's [supported sources](https://github.com/aliparlakci/bulk-downloader-for-reddit#list-of-currently-supported-sources)
* This script uses my own custom directory and time formatting described below. This can be modified in ```bulk-download.sh```, see the [bdfr documentation](https://github.com/aliparlakci/bulk-downloader-for-reddit) for the various options.


# Post Title Format
Posts are titled as follows:

**YYYY-MM-DD_HH-MM_TITLE_SUBREDDIT_POSTID**

# Directory Structure

    DIRECTORY ─┬─ USER1 ─┬─ POST1
               │         │
               │         ├─ POST2
               │         │
               │         └─ ...
               │
               ├─ USER2 ─┬─ POST1
               │         │
               │         ├─ POST2
               │         │
               │         └─ ...
               │
               └─ ...


# Issues
* Occasionally one of the BDFR panes will stop processing, simply move to the pane (CTRL+B, ARROW KEYS) and CTRL+C to move to the next user.


# Credits
Michelle L. Gill for their parallel tmux script.
```
https://gist.github.com/mlgill/ad2693f17aaa720ef777
```

Ali Parlakçı for creating **bulk-downloader-for-reddit** which this script implements.
```
https://github.com/aliparlakci/bulk-downloader-for-reddit
```
