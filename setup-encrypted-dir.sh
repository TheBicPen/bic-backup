#!/usr/bin/env sh

# Set up an encrypted view of some directory, mainly for making secure backups

# Base directory that contains all the mount points and key files
BASE_ENCRYPTED_DIR="$HOME/encrypted-cloud-sync"

if [ -z "$1" ]; then
    echo 'Select a directory to encrypt'
    exit 1
fi

# Directory that contains your private files that you want an encrypted view of
PRIVATE_DIR="$1"
# Unique name for the directory to encrypt
DIR_NAME="$(basename "$PRIVATE_DIR")"
# Mount point of the encrypted view
SYNC_DIR="$BASE_ENCRYPTED_DIR/sync/$DIR_NAME"
if [ -d "$SYNC_DIR" ]; then
    echo "Encrypted directory $SYNC_DIR already exists. This script will not overwrite it"
    exit 1
fi

KEY_FILE="$BASE_ENCRYPTED_DIR/$DIR_NAME-key.txt"
if [ -f "$KEY_FILE" ]; then
    echo "Key file $KEY_FILE already exists. This script will not overwrite it"
    exit 1
fi

if [ -f "$PRIVATE_DIR/.gocryptfs.reverse.conf" ]; then
    echo "Configuration file for $PRIVATE_DIR already exists. This script will not overwrite it"
    exit 1
fi

# We've passed all the checks. Set up the encrypted view

# Make the target directory to hold the encrypted view of PRIVATE_DIR
mkdir "$SYNC_DIR" || exit 1

# Generate a secure password
# Use 48 bytes since any more will split the output across lines
openssl rand -base64 -out "$KEY_FILE" 48 || exit 1

# Initialize the configuration
gocryptfs -init -passfile "$KEY_FILE" -reverse -deterministic-names "$PRIVATE_DIR" || exit 1

echo "Set up encrypted view of $PRIVATE_DIR. Mount it with:

    $(dirname "$0")/mount-encrypted-dir.sh $PRIVATE_DIR"
