#!/bin/bash
#########################################################
#                                                       #
# See the readme file and the config file for usage     #
#                                                       #
# Database back ups has 3 steps                         #
#  STEP 1 create initial uncompressed file              #
#  STEP 2 compress the file                             #
#  STEP 3 remove the back up file, leave the zipped copy#
#                                                       #
#########################################################
 
cd "$(dirname "$0")";

while read shellUser port dbUser dbPass
do
  #check to make sure we have all data to make connections
  if [ -n "$shellUser" ] && [ "$shellUser" != "#" ] 
  then
    backUpDir=$shellUser"_"`date +%A`;
    #use --exclude='dirORfile' --exclude='anotherDirOrFile'
    #this grabs the current web Dir 
    rsync -e "ssh -p $port" -abq --delete --backup-dir=../$backUpDir  $shellUser:~/public_html/ $shellUser/ ;
    #if we have the database info then do a back up, otherwise we just skip this step
    if [ -n "$dbUser" ] && [ -n "$dbPass" ]
    then
      # do all 3 actions in one connection
      ssh -n -p $port $shellUser "mysqldump -u '$dbUser' -p'$dbPass' -A --opt > b.sqlBK; tar czf bksql.tar.gz b.sqlBK; rm b.sqlBK;";
      #this grabs the db back up
      rsync -e "ssh -p $port" -bq --backup-dir=../$backUpDir  $shellUser:~/bksql.tar.gz $shellUser/ ;
    fi    
  fi
done < config.cfg

exit 0;
