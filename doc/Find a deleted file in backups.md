# Find a deleted file in backups

Duplicity has many wonderful features, but easily finding a deleted file in the backups is not one of them. To help with this, the `duplicity_find_file` script tries to efficiently search the backups for the point in time where the requested file was deleted, and restore the latest version of it that existed.

1. To use it, become root on the server where the backup was made, and run:

        duplicity_find_file FILE_TO_RESTORE BACKUP_NAME MAX_RANGE

    The `FILE_TO_RESTORE` argument is the full path, without leading slashes, to the file you're interested in.
    
    The `BACKUP_NAME` argument is the backup directory to search; this is a subdirectory of the `perseids_data_backup` S3 bucket.
    
    The `MAX_RANGE` argument helps shorten the search by specifying the maximum numbers of days back in time you want the script to look. For example, if you know the file existed 10 days ago, you can use a `MAX_RANGE` of 10. If the file was deleted more than `MAX_RANGE` days ago, though, this script will not find it.
    
    For example:

        duplicity_find_file users/jmharrington.git/refs/heads/Latin_Treebank_Collection/2016223 git 365
        
2. The script will start searching the backups, attempting to find the day before the file was deleted:

        Trying 182 days... found
        Trying 91 days... found
        Trying 45 days... found
        Trying 22 days... found
        Trying 11 days... not found
        Trying 17 days... found
        Trying 14 days... found
        Trying 13 days... found
        Trying 12 days... not found
        Restoring latest version found at 13 days old... done. Restored file is at /mnt/restore/users/jmharrington.git/refs/heads/Latin_Treebank_Collection/2016223
        
3. If the search was successful, the requested file will be restored to the path shown.
