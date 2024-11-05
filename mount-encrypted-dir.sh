#!/usr/bin/env sh

# Mount an encrypted view of some directory, which can then be synced
# to cloud storage. On modern distros (Debian 11 ships a patch that removes mega
# support), sync to mega with rclone.

BASE_ENCRYPTED_DIR="$HOME/encrypted-cloud-sync"

# To restore, you must have the key file saved somewhere.
# To decrypt, run `gocryptfs -passfile "$KEY_FILE" "$SYNC_DIR" tmp`
# Then copy `tmp` to $PRIVATE_DIR.

if [ "$#" -lt 1 ]; then
    echo "Select a directory to encrypt and back up"
fi

# Initialize a PRIVATE_DIR with setup-encrypted-backup.sh
PRIVATE_DIR="$1"
# Unique name for the directory to encrypt
DIR_NAME="$(basename "$PRIVATE_DIR")"
# Mount point of the encrypted view
SYNC_DIR="$BASE_ENCRYPTED_DIR/sync/$DIR_NAME"
# File that contains the key
KEY_FILE="$BASE_ENCRYPTED_DIR/$DIR_NAME-key.txt"


if [ -z "$2" ]; then
    SYNC_COMMAND="echo 'Now sync $SYNC_DIR manually'; sleep infinity"
else
    SYNC_COMMAND="$2"
fi

# Read-only since there is no need to write to the directory being backed up
gocryptfs -passfile "$KEY_FILE" -reverse -ro "$PRIVATE_DIR" "$SYNC_DIR"

_unmount() {
    echo Unmounting "$SYNC_DIR"
    fusermount -u "$SYNC_DIR"
    exit "$1"
}

trap "_unmount 1" TERM INT

# On a modern distro, rclone can directly sync to mega
# For now, take the sync command as a parameter - let the user do it manually :)
if (eval "$SYNC_COMMAND"); then
    echo "Sync command finished";
    _unmount 0
else
    echo "Error running sync command";
    _unmount 1
fi
