# Restore Sosol data from SQL dump

The Sosol RDS instance uses AWS's point-in-time recovery feature. In the event of a major data loss, the first thing to do is to restore the RDS instance to the appropriate point in time using the AWS console.

However, as a secondary backup measure, the contents of the Sosol database are also dumped hourly on the `sosol` server, in `/mnt/data/sosol_db_backup`. These dumps are copied to Amazon S3 nightly.

## Restore Sosol data from local backup

1. Log in to the `sosol` server.

1. Run the following command:

		$ sudo su - 

1. Check the latest local backup:

        # ls -lt /mnt/data/sosol_db_backup/ |head
        total 206084
        -rw-r--r-- 1 root root 2050823 Aug 23 14:00 sosol.sql.2016-08-23T14:00+0000.gz
        -rw-r--r-- 1 root root 2050636 Aug 23 13:00 sosol.sql.2016-08-23T13:00+0000.gz
        -rw-r--r-- 1 root root 2050638 Aug 23 12:00 sosol.sql.2016-08-23T12:00+0000.gz
        ...        
  
1. Select the backup file you want to restore, and check the contents:

    	# zless /mnt/data/sosol_db_backup/sosol.sql.2016-08-23T14\:00+0000.gz
        -- MySQL dump 10.13  Distrib 5.6.31, for debian-linux-gnu (x86_64)
        --
        -- Host: perseidsmysql.cx2nagbknuom.us-east-1.rds.amazonaws.com    Database: sosol
        -- ------------------------------------------------------
        -- Server version       5.6.19-log
    
        /*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
        /*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
        /*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
        /*!40101 SET NAMES utf8 */;
        ...

1. If you need to edit the data for any reason, you can unzip the file with `gzip -d` and edit it with `vi`.

1. Before restoring the data to the Sosol RDS instance, take an RDS snapshot, so that you can reset the database to its current state in the event of any problems with the restore process.

1. Check that you have access to the RDS instance by running this command:

        # mysql -h perseidsmysql.cx2nagbknuom.us-east-1.rds.amazonaws.com -u sosoladmin -ps0s0ladm1n sosol
        Welcome to the MySQL monitor.  Commands end with ; or \g.
        Your MySQL connection id is 7788
        Server version: 5.6.19-log MySQL Community Server (GPL)
        ...

1. **WARNING**: The next step will erase all data in the production Sosol database, so be very sure that this is what you want to do!

1. To restore the data, run the following command:

        # zcat /mnt/data/sosol_db_backup/sosol.sql.2016-08-23T14:00+0000.gz | mysql -h perseidsmysql.cx2nagbknuom.us-east-1.rds.amazonaws.com -u sosoladmin -ps0s0ladm1n sosol

## Restore Sosol data from S3

If the appropriate backup file is not available on the machine, you can retrieve it from S3:

1. On the `sosol` server, get the list of available files in the S3 backup by running:

        duplicity_list sosol_db
        Local and Remote metadata are synchronized, no sync needed.
        Last full backup date: Sat Aug 27 05:00:01 2016
        Tue Aug 30 05:00:01 2016 .
        Thu Aug 18 17:06:11 2016 sosol.sql.2016-08-18T17:06+0000.gz
        Thu Aug 18 17:08:41 2016 sosol.sql.2016-08-18T17:08+0000.gz
        ...

1. Once you know the file you want to retrieve, restore it with:

        duplicity_restore -f sosol.sql.2016-08-30T02:00+0000.gz sosol_db /tmp/sosol.sql.2016-08-30T02:00+0000.gz

1. You can now examine, edit, or restore the data to the RDS instance using the 'Restore Sosol data from local backup' section of this procedure.
