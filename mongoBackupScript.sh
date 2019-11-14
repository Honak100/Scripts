#!/bin/bash

NOW=$(TZ=Asia/Kolkata date  "+%Y-%m-%d-%H-%M-%S");
DATE=$(TZ=Asia/Kolkata date  "+%Y-%m-%d-%H-%M");
IP=$(curl http://ipecho.net/plain; echo)


DB_LIST="BookMyFarm"
DIRECTORY="/home/revolution/Honak/script/BookMyFarmData"
PROJECT="$DIRECTORY/$DB_LIST-$DATE"
LOG="$PROJECT/$DB_LIST-Dump_$NOW.log"

CONNECTLY_DAILY_BACKUP_TIME="02"
CONNECTLY_REMOVE_ALL_BACKUP_BEFORE_DAYS="7"
CONNECTLY_REMOVE_ALL_BACKUP_BEFORE_DAILY="7" 
CONNECTLY_REMOVE_ALL_BACKUP_BEFORE_WEEKLY="2"
CONNECTLY_REMOVE_ALL_BACKUP_BEFORE_MONTHLY="1"

echo "create data directory"
if [ ! -d "$DIRECTORY" ]; then
  mkdir -p $DIRECTORY
  mkdir -p $DIRECTORY/logs
fi

echo "create project directory"
if [ ! -d "$PROJECT" ]; then
  mkdir $PROJECT
fi

if [ ! -d "$DIRECTORY/$DB_LIST-Backup" ]; then
        mkdir -p $DIRECTORY/$DB_LIST-Backup
fi


echo "" >> $LOG
echo "##################################################################" >> $LOG
echo "--------------Processing $DB_LIST Database Backup ...........!!!-------------" >> $LOG
echo "##################################################################" >> $LOG
echo "" >> $LOG

cd $PROJECT/

echo "*************########### Dump Details #############*************" >> $LOG
echo "" >> $LOG

echo "##################################################################" >> $LOG
echo "Date And Time:" >> $LOG
echo "##################################################################" >> $LOG
echo "$(date)" >> $LOG
echo "" >> $LOG
echo "------------------------------------------------------------------" >> $LOG
echo "" >> $LOG

echo "##################################################################" >> $LOG
echo "Processing $DB_LIST Daily Dumps:" >> $LOG
echo "##################################################################" >> $LOG
echo "" >> $LOG

############# Daily Backup $DB_LIST-Backup #####################
echo "*** Starting Daily Dump from $DB_LIST ***" >> $LOG
echo "" >> $LOG
    echo "----------Creating Dump for Database:---------" >> $LOG
    echo "" >> $LOG
    echo "=) *Dump Directory: $PROJECT"

    echo "" >> $LOG


echo "{\"IP\":\"$IP\",\"date\":\"$(TZ=Asia/Kolkata date  "+%Y-%m-%d-%H-%M-%S")\",\"db_name\":\"$DB_LIST\",\"status\":\"start\",\"project\":\"$DB_LIST\",\"componant\":\"mongodump\",\"type\":\"data\"}" >> $LOG  
  echo "" >> $LOG

  rm -rf $DB_LIST
  docker cp mongo_dbs:dump/$DB_LIST $PROJECT

  DB_SIZE=$(du -sh $PROJECT/$line | awk '{print $1}')
  echo  "DB SIZE: $DB_SIZE \t $line" >> $LOG
  echo "" >> $LOG    
echo "{\"IP\":\"$IP\",\"date\":\"$(TZ=Asia/Kolkata date  "+%Y-%m-%d-%H-%M-%S")\",\"db_name\":\"$DB_LIST\",\"status\":\"finish\",\"project\":\"$DB_LIST\",\"componant\":\"mongodump\",\"type\":\"data\"}" >> $LOG
echo "" >> $LOG
echo "------------------------------------------------------------------" >> $LOG
echo "" >> $LOG

echo "" >> $LOG
echo "------------------------------------------------------------------" >> $LOG


cd $DIRECTORY/
    
    echo "*** Processing $DB_LIST Daily Dumps ***" >> $LOG
    echo  "$(ls *$CONNECTLY_DAILY_BACKUP_TIME* | awk '{printf $1 " "}')" >> $LOG
    if [ ! -d "$DIRECTORY/$DB_LIST-Backup/Daily" ]; then
        mkdir $DIRECTORY/$DB_LIST-Backup/Daily
    fi

    mv $(ls *$CONNECTLY_DAILY_BACKUP_TIME* | awk '{printf $1 "\n"}') $DIRECTORY/$DB_LIST-Backup/Daily
    echo "" >> $LOG


############# Weekly Backup $DB_LIST-Backup #####################
echo "*** Processing $DB_LIST Weekly Dumps ***" >> $LOG
cd $DIRECTORY/$DB_LIST-Backup/Daily

echo "" >> $LOG
echo "Moving Weekly Backup to Weekly Directory" >> $LOG
if [ ! -d "$DIRECTORY/$DB_LIST-Backup/Weekly" ]; then
  mkdir $DIRECTORY/$DB_LIST-Backup/Weekly
fi
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
        if [ $(date +"%A" -d "$line") = "Sunday" ]; then
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                cp $(ls *$line*) $DIRECTORY/$DB_LIST-Backup/Weekly
        fi
done
echo "" >> $LOG

############# Monthly Backup $DB_LIST-Backup #####################
echo "*** Processing $DB_LIST Monthly Dumps ***" >> $LOG
cd $DIRECTORY/$DB_LIST-Backup/Weekly

echo "" >> $LOG
echo "Moving Monthly Backup to Monthly Directory" >> $LOG
if [ ! -d "$DIRECTORY/$DB_LIST-Backup/Monthly" ]; then
  mkdir $DIRECTORY/$DB_LIST-Backup/Monthly
fi
echo "" >> $LOG

ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
        if [ $(date +"%F" -d "$line") = $(date -d "`date +%Y%m01` +1 month -1 day" +%Y-%m-%d) ]; then
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                cp $(ls *$line*) $DIRECTORY/$DB_LIST-Backup/Monthly
    fi
done

echo "##################################################################" >> $LOG
echo "------------------$DB_LIST Database Backup Completed...!!!------------------" >> $LOG
echo "##################################################################" >> $LOG

tar -I pigz -cvf $PROJECT.tar.gz $PROJECT

echo "##################################################################" >> $LOG
echo "-----------------Processing $DB_LIST Database Dump Remove ...!!!------------------" >> $LOG
echo "##################################################################" >> $LOG

cd $DIRECTORY/

############# Removing Dump Data #####################
echo "Removing dump older then $CONNECTLY_REMOVE_ALL_BACKUP_BEFORE_DAYS Days" >> $LOG
ls | grep $DB_LIST | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}' | sort | uniq > date.txt
#cat date.txt

echo "" >> $LOG
cat date.txt | while read line
do
        if [ $(date -d "$(echo $line | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}')" +"%s") -lt $(date -d "-$CONNECTLY_REMOVE_ALL_BACKUP_BEFORE_DAYS days" +"%s") ]; then
                echo $(ls *$line* | awk '{printf $1 " "}') >> $LOG
                rm -rf $DIRECTORY/$DB_LIST-$line.tar.gz
      fi
done

############# Removing Daily dump data #####################
cd $DIRECTORY/$DB_LIST-Backup/Daily/
echo "" >> $LOG
echo "Removing dump older then $CONNECTLY_REMOVE_ALL_BACKUP_BEFORE_DAILY Daily Data" >> $LOG
ls | grep $DB_LIST | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}' | sort | uniq > date.txt
#cat date.txt

echo "" >> $LOG
cat date.txt | while read line
do
        if [ $(date -d "$(echo $line | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}')" +"%s") -lt $(date -d "-$CONNECTLY_REMOVE_ALL_BACKUP_BEFORE_DAILY days" +"%s") ]; then
                echo $(ls *$line* | awk '{printf $1 " "}') >> $LOG
                rm -rf $DIRECTORY/$DB_LIST-Backup/Daily/$DB_LIST-$line.tar.gz
      fi
done
echo "" >> $LOG

############# Removing Weekly dump data #####################
cd $DIRECTORY/$DB_LIST-Backup/Weekly
echo "Removing dump older then $CONNECTLY_REMOVE_ALL_BACKUP_BEFORE_WEEKLY Week data" >> $LOG
ls | grep $DB_LIST | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}' | sort | uniq > date.txt
#cat date.txt

echo "" >> $LOG
cat date.txt | while read line
do
        if [ $(date -d "$(echo $line | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}')" +"%s") -lt $(date -d "-$CONNECTLY_REMOVE_ALL_BACKUP_BEFORE_WEEKLY weeks" +"%s") ]; then
                echo $(ls *$line* | awk '{printf $1 " "}') >> $LOG
                rm -rf $DIRECTORY/$DB_LIST-Backup/Weekly/$DB_LIST-$line.tar.gz
      fi
done
echo "" >> $LOG

############# Removing Monthly dump data #####################
cd $DIRECTORY/$DB_LIST-Backup/Monthly
echo "Removing dump older then $CONNECTLY_REMOVE_ALL_BACKUP_BEFORE_MONTHLY Month data" >> $LOG
ls | grep $DB_LIST | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}' | sort | uniq > date.txt
#cat date.txt

echo "" >> $LOG
cat date.txt | while read line
do
        if [ $(date -d "$(echo $line | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}')" +"%s") -lt $(date -d "-$CONNECTLY_REMOVE_ALL_BACKUP_BEFORE_MONTHLY months" +"%s") ]; then
                echo $(ls *$line* | awk '{printf $1 " "}') >> $LOG
                rm -rf $DIRECTORY/$DB_LIST-Backup/Monthly/$DB_LIST-$line.tar.gz
      fi
done
echo "" >> $LOG

cp $LOG $DIRECTORY/logs/