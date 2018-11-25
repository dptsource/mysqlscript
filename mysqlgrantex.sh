#!/bin/bash

############################################
#####MySQL Grant Extraction Script##########
###Created By : Dheeraj PT ################
######Method to use########################
######## ./grants.ksh <hostname>.txt <port> ###
############################################

if (( $# != 2 )); then
   echo "Usage: $0 INPUTFILENAME  PORT USERNAME" >&2
   exit 1
fi
#assign argument to variable
file_name=$1
hpost=$2
### Check the existence of the log directory, if the log directory does not exist throw a mail
if [ ! -f $file_name ];then
  echo "File does not exist  Aborting..."
  exit 1
fi
##reset the output file
cat /dev/null > grantsdiff.txt
for i in `cat $file_name`
do
echo $i|tee -a grantsdiff.txt
echo "*****************************************************"|tee -a grantsdiff.txt
### Extracting the grants engaged by mysql instances
mysql -uroot  -pXXXXXXX -P$hpost --silent --skip-column-names --execute "select concat('\'',User,'\'@\'',Host,'\'') as User from mysql.user " | sort | \
while read u
do echo " "|tee -a grantsdiff.txt; mysql -uroot -pXXXXXXX -P$hpost --silent --skip-column-names --execute "show grants for $u" | sed 's/$/;/'|tee -a grantsdiff.txt
done
done
