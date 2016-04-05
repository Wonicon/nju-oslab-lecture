#!/usr/bin/env bash

flags="--archive"          # archive mode, including recursion, perm-keeping, time-keeping, etc.
flags="$flags --progress"  # show progress
flags="$flags --compress"
flags="$flags --checksum"
flags="$flags --delete"    # delete extra files in dst dir
flags="$flags --verbose"

src="./_site/"
dst="root@www.wonicon.com:/data/oslab/"

echo "rsync $flags $src $dst"

rsync $flags $src $dst
