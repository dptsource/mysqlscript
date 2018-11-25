#!/bin/ksh

######MySQL Dump Backup Script##############
####Created by : Dheeraj Porayil Thekkinakathu#################
####Version : 1.0 ##################
#####################
##########################

dstr=`date +'%d.%m.%y.%H:%M'`
dstr1=`date +'%d.%m.%y'`
BACKUP_DIR=/backup
BACKUP_LOG=/backup
hostname=localhost
username=root
pwd=XXXXXXX
database_name='database1'

find $BACKUP_DIR/*.gz -mtime +3 -exec rm {} \;

mysqldump -h$hostname -u$username -p$pwd --single-transaction --flush-logs --master-data=2 -q -R $database_name  2> Error_${database_name}_DB_Backup${dstr}.log | gzip >> $BACKUP_DIR/${database_name}_Backup_${dstr}.sql.gz
if [ `grep -c "error" Error_${database_name}_DB_Backup${dstr}.log` -ne 0 ] ;then
echo -e "\n**************** ${database_name}  DataBase Backup Faild ************************************* \n" >>$BACKUP_LOG/${database_name}_DB_Backup_Error_${dstr}.log
      echo -e "\t\t\tHost Name: $hostname\n\nDate&Time:$dstr\t\tDatabase Name: ${database_name} \n" >> $BACKUP_LOG/
${database_name}_DB_Backup_Error_${dstr}.log
      cat Error_${database_name}_DB_Backup${dstr}.log >> $BACKUP_LOG/${database_name}_DB_Backup_Error_${dstr}.log
echo -e "\n********************************************************************************************************** \n" >> $BACKUP_LOG/${database_name}_DB_Backup_Error_${dstr}.log
 ( cat $BACKUP_LOG/${database_name}_DB_Backup_Error_${dstr}.log

  ) | mailx -s "ERROR While taking the backup on ${database_name} MYSQL DB Server" dptsource@gmail.com

      rm Error_${database_name}_DB_Backup${dstr}.log

else

Backup_file_name=$BACKUP_DIR/${database_name}_Backup_${dstr}.sql.gz
echo -e "\n**************** ${database_name}  DataBase Backup Completed Sucessfully ***************************** \n" >> $BACKUP_LOG/${database_name}_DB_Backup_success
full_${dstr}.log
 echo -e "\t\t\tHost Name: $hostname\n\nDate&Time:$dstr\t\tDatabase Name: ${database_name} \n" >> $BACKUP_LOG/

${database_name}_DB_Backup_successfull_${dstr}.log
      cat Error_${database_name}_DB_Backup${dstr}.log >> $BACKUP_LOG/${database_name}_DB_Backup_successfull_${dstr}.log
      echo -e "\nStatus:${database_name}   Server Backup has been Completed Sucessfully \n"   >> $BACKUP_LOG/

${database_name}_DB_Backup_successfull_${dstr}.log
      echo -e " ${database_name} DataBase Backup File:" >> $BACKUP_LOG/${database_name}_DB_Backup_successfull_${dstr}.log
du -sh ${Backup_file_name} >>$BACKUP_LOG/${database_name}_DB_Backup_successfull_${dstr}.log

echo -e "\n********************************************************************************************************** \n" >> $BACKUP_LOG/${database_name}_DB_Backup_successfull_${dstr}.log

( cat $BACKUP_LOG/${database_name}_DB_Backup_successfull_${dstr}.log

  ) | mailx -s " ${database_name} MYSQL DB Server Backup is Completed Sucessfully " dptsource@gmail.com
      rm Error_${database_name}_DB_Backup${dstr}.log


find $BACKUP_DIR/*.gz -mtime +3 -exec rm {} \;

fi
