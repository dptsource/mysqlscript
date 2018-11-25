#!/bin/bash

####MySQL Incremental Backup Script using PerconaXtrabackup########
####Created by : Dheeraj Porayil Thekkinakathu ####################
#####ver : 1.0 #####################################################
# Get the day of the week.

BACKUP_DIR=/backup                                         # Backup location.
passwd='XXXXXXXXX'                                          # Backup user password
Backup_user='root'                                         # Backup user with All privileges
config_file='/var/lib/mysql/my.cnf'              # MySQL Configuration File.
socket_file='/var/lib/mysql/mysql.sock' # MySQL socket path
Binary_path='/backup/percona-xtrabackup-2.4.8-Linux-x86_64/bin'  #Percona binary Path, If Binary installed using yum or RPM leave this field empty

# Check for an existing full backup
if [ ! -d $BACKUP_DIR/Mon_Fullbackup ]; # Check whether full backup exists
                then
        echo "Latest full backup information not found... taking a first full backup now"

        $Binary_path/innobackupex --user=$Backup_user --password=$passwd  --parallel=12 --socket=$socket_file --no-timestamp  $BACKUP_DIR/Mon_Fullbackup > $BACKUP_DIR/Mon_Fullbackup.log 2>&1
        echo " Full Backup completed at $(date)";

elif [ ! -d $BACKUP_DIR/Tue_increbackup ]
                then
        $Binary_path/innobackupex   --user=$Backup_user --password=$passwd  --parallel=12 --socket=$socket_file --no-timestamp  --incremental $BACKUP_DIR/Tue_increbackup --incremental-basedir=$BACKUP_DIR/Mon_Fullbackup > $BACKUP_DIR/Tue_increbackup.log 2>&1
        echo " Tuesday incremental Backup completed at $(date)";

elif [ ! -d $BACKUP_DIR/Wed_increbackup ]
        then
        $Binary_path/innobackupex   --user=$Backup_user --password=$passwd  --parallel=12 --socket=$socket_file --no-timestamp  --incremental $BACKUP_DIR/Wed_increbackup --incremental-basedir=$BACKUP_DIR/Tue_increbackup > $BACKUP_DIR/Wed_increbackup.log 2>&1
        echo " Wednesday incremental Backup completed at $(date)";

elif [ ! -d $BACKUP_DIR/Thu_increbackup ]
        then
        $Binary_path/innobackupex   --user=$Backup_user --password=$passwd  --parallel=12 --socket=$socket_file --no-timestamp  --incremental $BACKUP_DIR/Thu_increbackup --incremental-basedir=$BACKUP_DIR/Wed_increbackup > $BACKUP_DIR/Thu_increbackup.log 2>&1
        echo " Thursday incremental Backup completed at $(date)";

elif [ ! -d $BACKUP_DIR/Fri_increbackup ]
        then
        $Binary_path/innobackupex   --user=$Backup_user --password=$passwd  --parallel=12 --socket=$socket_file --no-timestamp  --incremental $BACKUP_DIR/Fri_increbackup --incremental-basedir=$BACKUP_DIR/Thu_increbackup > $BACKUP_DIR/Fri_increbackup.log 2>&1
        echo " Friday incremental Backup completed at $(date)";

elif [ ! -d $BACKUP_DIR/Sat_increbackup ]
        then
        $Binary_path/innobackupex   --user=$Backup_user --password=$passwd  --parallel=12 --socket=$socket_file --no-timestamp  --incremental $BACKUP_DIR/Sat_increbackup --incremental-basedir=$BACKUP_DIR/Fri_increbackup > $BACKUP_DIR/Sat_increbackup.log 2>&1
          echo " Saturday incremental Backup completed at $(date)";

 else
      MS="yes";  # Reference variable to identify when we need to Apply log.

       $Binary_path/innobackupex   --user=$Backup_user --password=$passwd  --parallel=12 --socket=$socket_file --no-timestamp  --incremental $BACKUP_DIR/Sun_increbackup --incremental-basedir=$BACKUP_DIR/Sat_increbackup > $BACKUP_DIR/Sun_increbackup.log 2>&1
        echo " Suday incremental Backup completed at $(date)";
 fi

# Apply log for Backups.

if [ "$MS" = "yes" ]  # Apply log will happen only when all 7days incremental backup completes
then

        $Binary_path/innobackupex --defaults-file=$config_file --apply-log --redo-only $BACKUP_DIR/Mon_Fullbackup > $BACKUP_DIR/Mon_Fullbackup_applylog.log 2>&1
        echo " Apply-log completed for MonFullbackup at $(date)";

        $Binary_path/innobackupex --defaults-file=$config_file --apply-log --redo-only $BACKUP_DIR/Mon_Fullbackup --incremental-dir=$BACKUP_DIR/Tue_increbackup > $BACKUP_DIR/Tue_increbackup_applylog.log 2>&1
         echo " Apply-log completed for Tue_increbackup  at $(date)";

        $Binary_path/innobackupex --defaults-file=$config_file --apply-log --redo-only $BACKUP_DIR/Mon_Fullbackup --incremental-dir=$BACKUP_DIR/Wed_increbackup > $BACKUP_DIR/Wed_increbackup_applylog.log 2>&1
         echo " Apply-log completed for Wed_increbackup  at $(date)";

        $Binary_path/innobackupex --defaults-file=$config_file --apply-log --redo-only $BACKUP_DIR/Mon_Fullbackup --incremental-dir=$BACKUP_DIR/Thu_increbackup> $BACKUP_DIR/Thu_increbackup_applylog.log 2>&1
        echo " Apply-log completed for Thu_increbackup  at $(date)";

        $Binary_path/innobackupex --defaults-file=$config_file --apply-log --redo-only $BACKUP_DIR/Mon_Fullbackup --incremental-dir=$BACKUP_DIR/Fri_increbackup> $BACKUP_DIR/Fri_increbackup_applylog.log 2>&1
        echo " Apply-log completed for Fri_increbackup  at $(date)";

        $Binary_path/innobackupex --defaults-file=$config_file --apply-log --redo-only $BACKUP_DIR/Mon_Fullbackup --incremental-dir=$BACKUP_DIR/Sat_increbackup> $BACKUP_DIR/Sat_increbackup_applylog.log 2>&1
        echo " Apply-log completed for Sat_increbackup  at $(date)";

        $Binary_path/innobackupex --defaults-file=$config_file --apply-log  $BACKUP_DIR/Mon_Fullbackup --incremental-dir=$BACKUP_DIR/Sun_increbackup> $BACKUP_DIR/Sun_increbackup_applylog.log 2>&1
        echo " Apply-log completed for Sun_increbackup  at $(date)";

                $Binary_path/innobackupex --defaults-file=$config_file --apply-log  $BACKUP_DIR/Mon_Fullbackup > $BACKUP_DIR/Mon_Fullbackup_applylogfinal.log 2>&1
        echo " Apply-log completed for MonFullbackupfinal at $(date)";


         [ -d $BACKUP_DIR/Fullbackup_Prev_week ]&& rm -rf $BACKUP_DIR/Fullbackup_Prev_week
                 [ -d $BACKUP_DIR/Tue_increbackup ]&& rm -rf $BACKUP_DIR/Tue_increbackup  # Deleting incremental Backup after apply-log completed.
                 [ -d $BACKUP_DIR/Wed_increbackup ]&& rm -rf $BACKUP_DIR/Wed_increbackup
                 [ -d $BACKUP_DIR/Thu_increbackup ]&& rm -rf $BACKUP_DIR/Thu_increbackup
                 [ -d $BACKUP_DIR/Fri_increbackup ]&& rm -rf $BACKUP_DIR/Fri_increbackup
                 [ -d $BACKUP_DIR/Sat_increbackup ]&& rm -rf $BACKUP_DIR/Sat_increbackup
                 [ -d $BACKUP_DIR/Sun_increbackup ]&& rm -rf $BACKUP_DIR/Sun_increbackup

        mv $BACKUP_DIR/Mon_Fullbackup $BACKUP_DIR/Fullbackup_Prev_week  #Move the current week backup to keep for one week.

                MS="no";  # Need to clear the Reference variable to identify when we need to Apply log


else
        echo "Apply-log will happen only on sunday after All 7 days incremental completes"

        fi
