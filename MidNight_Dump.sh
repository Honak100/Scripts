#!/bin/base

HOST="localhost"
USERNAME="TestUser"
PASSWORD="TestPass"

DATE=$(TZ=Asia/Kolkata date  "+%Y-%m-%d-%H-%M");
NOW=$(TZ=Asia/Kolkata date  "+%Y-%m-%d-%H-%M-%S");

DIRECTORY="/home/revolution/Honak/script/Dump"
PROJECT="$DIRECTORY/admin-$DATE"
LOG="$PROJECT/BookMyFarm_Dump_$NOW.log"
MIDNIGHTDUMP="$PROJECT/ZeroDump"

echo "create data directory"
if [ ! -d "$DIRECTORY" ]; then
  mkdir -p $DIRECTORY
fi

echo "create project directory"
if [ ! -d "$PROJECT" ]; then
  mkdir -p $PROJECT
fi

echo "" >> $LOG
echo "##################################################################" >> $LOG
echo "Process Start:" >> $LOG
echo "##################################################################" >> $LOG
echo "" >> $LOG

echo "##################################################################" >> $LOG
echo "Date And Time:" >> $LOG
echo "##################################################################" >> $LOG
echo "$(date)" >> $LOG
echo "" >> $LOG
echo "------------------------------------------------------------------" >> $LOG
echo "" >> $LOG


echo "##################################################################" >> $LOG
echo "Processing MidNight ZeroDumps:" >> $LOG
echo "##################################################################" >> $LOG
echo "" >> $LOG

cd $DIRECTORY

echo "-------------MongoDB Database_Backup------------------------------" >> $LOG
echo "" >> $LOG

echo "------------Create Dump Database----------------------------------" >> $LOG

/usr/bin/mongodump --host $HOST --db BookMyFarm --port=27037 --username $USERNAME --password $PASSWORD --out $PROJECT --authenticationDatabase admin

echo "-----------MongoDB Database_Backup completed----------------------" >> $LOG

echo "MidNight data dump:" >> $LOG
ls | grep BookMyFarm | grep -E '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}-00-00' >> $MIDNIGHTDUMP

echo "" >> $LOG
echo "--------------------MidNight dump data Successfully---------------------" >> $LOG

echo "" >> $LOG
echo "##################################################################" >> $LOG
echo "Processing Removing dump older then 5 Days:" >> $LOG
echo "##################################################################" >> $LOG
echo "" >> $LOG

echo "Removing dump older then 5 Days" >> $LOG
echo "" >> $LOG
ls | grep BookMyFarm | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}' >> date.txt

cat date.txt | while read line
do
    if [ $(date -d "$(echo $line | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}')" +"%s") -lt $(date -d "-5 days" +"%s") ]; then
 
    	echo "$(ls *$line* | awk '{printf $1 " "}') removed." >> $LOG
        rm -rf $DIRECTORY/BookMyFarm-$line.tar.gz
    fi
done

echo "" >> $LOG
echo "-----------------------Process completed--------------------------" >> $LOG
echo "" >> $LOG
echo "exit"

