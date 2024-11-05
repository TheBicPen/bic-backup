# Bic Backup

A simple set of scripts for backing up your files to untrusted (i.e. cloud)
storage. Provides a low-storage-overhead encrypted view of your private
directories, that you can safely back up to an untrusted location.

## Usage
Set up a directory for encrypted backup: `setup_encrypted_dir.sh /path/to-dir`

Create an encrypted view of an initialized directory for manual backup:
```sh
mount-encrypted-dir.sh /path/to/dir
# This will block to wait for you to manually back up the files
```

Create an encrypted view of an initialized directory with a backup script:
```sh
mount-encrypted-dir.sh /path/to/dir my_backup_script.sh
```

## Testing
To test these scripts, run `test/test-encrypted-view.sh`. The tests verify that
the encrypted view really is encrypted.