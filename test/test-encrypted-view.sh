#!/usr/bin/env sh

# Test setting up an encrypted view of a directory, backing it up,
# and restoring from the backup

_cleanup() {
    rm -rf "$PLAIN_DIR"
    rm -rf "$BACKUP_DIR"
    rm -rf "$RESTORED_DIR"
    rm -rf "$ENCRYPTED_DIR"
    rm "$KEY_FILE"
}

_fail() {
    echo "Fail: $1"
    echo "PLAIN_DIR: $PLAIN_DIR"
    echo "BACKUP_DIR: $BACKUP_DIR"
    echo "RESTORED_DIR: $RESTORED_DIR"
    echo "ENCRYPTED_DIR: $ENCRYPTED_DIR"
    echo "KEY_FILE: $KEY_FILE"
    _cleanup
    exit 1
}

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
BASE_ENCRYPTED_DIR="$HOME/encrypted-cloud-sync"

PLAIN_DIR="$(mktemp -d)"
BACKUP_DIR="$(mktemp -d)"
RESTORED_DIR="$(mktemp -d)"
ENCRYPTED_DIR="$BASE_ENCRYPTED_DIR/sync/test"
KEY_FILE="$BASE_ENCRYPTED_DIR/test-key.txt"

echo "Testing setup"
mkdir "$PLAIN_DIR/test"
"$SCRIPT_DIR/../setup-encrypted-dir.sh" "$PLAIN_DIR/test" || _fail 'Error setting up configuration'
echo "sus" > "$PLAIN_DIR"/test/secret.txt
echo ""

echo "Testing encrypted view"
"$SCRIPT_DIR/../mount-encrypted-dir.sh" "$PLAIN_DIR/test" "exit 0" || _fail 'Error mounting encrypted view'
echo ""

echo "Testing encryption"
"$SCRIPT_DIR/../mount-encrypted-dir.sh" "$PLAIN_DIR/test" "! grep -r 'sus' \"$ENCRYPTED_DIR\"" || _fail 'Secret was not encrypted'
echo ""

echo "Testing backup"
"$SCRIPT_DIR/../mount-encrypted-dir.sh" "$PLAIN_DIR/test" "cp -r \"$ENCRYPTED_DIR\" \"$BACKUP_DIR\"" || _fail 'Failed to copy encrypted view to backup location'
find "$BACKUP_DIR/test" -name "gocryptfs.conf" || _fail "Encrypted dir has no configuration file"
echo ""

echo "Testing restoration from backup"
gocryptfs -passfile "$KEY_FILE" "$BACKUP_DIR/test" "$RESTORED_DIR" || _fail "Failed to restore from encrypted backup"
diff -rq -x ".gocryptfs.reverse.conf" "$PLAIN_DIR/test" "$RESTORED_DIR" || _fail "Restored directory does not match plain dir"
fusermount -u "$RESTORED_DIR" || _fail 'Failed to unmount restored directory'
echo ""

_cleanup
