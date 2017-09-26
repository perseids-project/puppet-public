# Restore data from backup

1. Log in to the server onto which you want to restore the data.

1. Run the following commands (for example):

		$ sudo su - 
		# duplicity_restore git /tmp/restore
		
	The data from the specified backup will be restored into `/tmp/restore`.
	
1. If you want to restore only a specific file or directory tree, specify the `-f` option, like this:

		# duplicity_restore -f canonical.git git /tmp/restore
		
	The argument to `-f` is a relative path from the root of the backup. For example, in this case, we want to restore `/mnt/data/gitrepo/data/canonical.git`, and the backup root is `/mnt/data/gitrepo/data`, so the relative path is just `canonical.git`.
	
1. If you want to restore data from a specific time or date, rather than the latest backup, use the `-t` switch:

		# duplicity_restore -t 1W git /tmp/restore
		
	The time specifier (`1W` in the example, meaning one week ago) can be a date, a date and time, or an interval (for example `10d` for ten days). For full details see `man duplicity`.

1. If the required data was deleted at some point in the past, and is not present in the latest backup, see the 'Find a deleted file in backups' procedure.
