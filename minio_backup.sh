#!/bin/bash

TODATE=$(TZ=Asia/Kolkata date  "+%Y-%m-%d")
DATE=$(TZ=Asia/Kolkata date  "+%Y-%m-%d-%H-%M-%S")
DATE_CUST=$(TZ=Asia/Kolkata date  "+%Y-%m-%d-%H")
YEAR=$(date +"%Y")

DIRECTORY="/home/revolution/Honak/minio"
LOG="$DIRECTORY/cleaninglog/SADM-$DATE.txt"
CONNECTLY_DAILY_BACKUP_TIME="00"

if [ ! -d "$DIRECTORY/cleaninglog" ]; then
  mkdir $DIRECTORY/cleaninglog
fi
touch $LOG

echo "" >> $LOG
echo "##################################################################" >> $LOG
echo "Server Auto Dump Management Started...!!!" >> $LOG
echo "##################################################################" >> $LOG
echo "" >> $LOG

echo "*************########### Dump Details #############*************" >> $LOG

echo "" >> $LOG
echo "##################################################################" >> $LOG
echo "Date And Time:" >> $LOG
echo "##################################################################" >> $LOG
echo "$DATE" >> $LOG
echo "" >> $LOG
echo "------------------------------------------------------------------" >> $LOG

echo "" >> $LOG
echo "##################################################################" >> $LOG
echo "Current All Dump State:" >> $LOG
echo "##################################################################" >> $LOG
echo "$CURR_STAT" >> $LOG
echo "" >> $LOG
echo "------------------------------------------------------------------" >> $LOG

################################# connectlybackup Backup Process ################################

echo "##################################################################" >> $LOG
echo "Processing connectlybackup...!!!" >> $LOG
echo "##################################################################" >> $LOG
echo "" >> $LOG
########## Daily Backup connectlybackup #############
echo "*** Processing Daily Dumps ***" >> $LOG

cd $DIRECTORY/connectlybackup
echo "" >> $LOG

#echo  "$(ls *$CONNECTLY_DAILY_BACKUP_TIME* | awk '{printf $1 " "}')" >> $LOG
if [ ! -d "$DIRECTORY/connectlybackup/Daily" ]; then
  mkdir $DIRECTORY/connectlybackup/Daily
fi

#mv $(ls *$CONNECTLY_DAILY_BACKUP_TIME* | awk '{printf $1 " "}') $DIRECTORY/connectlybackup/Daily/
echo "" >> $LOG

################################# Removing dump before 7 days ###################################
echo "" >> $LOG
echo "Removing dump older then 7 days" >> $LOG
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
        if [ $(date -d "$line" +"%s") -lt $(date -d "-7 day" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf Connectly-$line*
    fi
done
echo "" >> $LOG

############# Monthly Backup connectlybackup #####################
echo "*** Processing Connectly Monthly Dumps ***" >> $LOG
cd $DIRECTORY/connectlybackup/Daily

echo "" >> $LOG
echo "Moving Monthly Backup to Monthly Directory" >> $LOG
if [ ! -d "$DIRECTORY/connectlybackup/Monthly" ]; then
  mkdir $DIRECTORY/connectlybackup/Monthly
fi
echo "" >> $LOG

ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
        if [ $(date +"%F" -d "$line")==$(date -d "`date +%Y%m01` +1 month -1 day" +%Y-%m-%d) ]; then
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                mv $(ls *$line*)  $DIRECTORY/connectlybackup/Monthly
    fi
done
echo "" >> $LOG

################## weekly backup connectlybackup ###################
echo "*** Processing Connectly Weekly Dumps ***" >> $LOG
cd $DIRECTORY/connectlybackup/Daily

echo "" >> $LOG
echo "Moving Weekly Backup to Weekly Directory" >> $LOG
if [ ! -d "$DIRECTORY/connectlybackup/Weekly" ]; then
  mkdir $DIRECTORY/connectlybackup/Weekly
fi
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
        if [ $(date +"%A" -d "$line") == "Sunday" ]; then
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                mv $(ls *$line*)  $DIRECTORY/connectlybackup/Weekly
    fi
done
echo "" >> $LOG

###### Removing dump older then 3 day ######
cd $DIRECTORY/connectlybackup/
echo "" >> $LOG
echo "Removing dump older then 3 days" >> $LOG
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt

cat date.txt | while read line
do
    if [ $(date -d "$line" +"%s") -lt $(date -d "-1 months" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf $(ls *$line* )
    fi
done    

### remove 1 week older
cd $DIRECTORY/connectlybackup/Weekly/
echo "Removing dump older then 1 Week from weekly" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
echo "" >> $LOG
cat date.txt | while read line
do
        if [ $(date -d "$line" +"%s") -lt $(date -d "-1 weeks" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf $(ls *$line* | awk '{printf $1 " "}')
        fi
done

#### remove 1 month older
cd $DIRECTORY/connectlybackup/Monthly/
echo "Removing dump older then 1 Month from Month" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
echo "" >> $LOG
cat date.txt | while read line
do
        if [ $(date -d "$line" +"%s") -lt $(date -d "-1 months" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf $(ls *$line* | awk '{printf $1 " "}')
        fi
done


#################################### meracrmbackup Backup Process ##########################################

echo "" >> $LOG
echo "------------------------------------------------------------------" >> $LOG
echo "" >> $LOG
echo "##################################################################" >> $LOG
echo "Processing meracrmbackup...!!!" >> $LOG
echo "##################################################################" >> $LOG
echo "" >> $LOG


####### monthly backup meracrmbackup ########
echo "Processing Monthly Dumps...!!" >> $LOG
cd $DIRECTORY/meracrmbackup

echo "" >> $LOG
echo "Moving Monthly Backup to Monthly Directory" >> $LOG
if [ ! -d "$DIRECTORY/meracrmbackup/Monthly" ]; then
  mkdir $DIRECTORY/meracrmbackup/Monthly
fi
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
        if [ $(date +"%F" -d "$line")==$(date -d "`date +%Y%m01` +1 month -1 day" +%Y-%m-%d) ]; then
                echo "$(ls -d *$line* | awk '{printf $1 " "}')" >> $LOG
                mv $(ls -d *$line*)  $DIRECTORY/meracrmbackup/Monthly
    fi
done
echo "" >> $LOG

######### weekly Backup meracrmbackup #########
echo "Processing Weekly Dumps....!!!" >> $LOG
cd $DIRECTORY/meracrmbackup

echo "" >> $LOG
echo "Moving Weekly Backup to Weekly Directory" >> $LOG
if [ ! -d "$DIRECTORY/meracrmbackup/Weekly" ]; then
  mkdir $DIRECTORY/meracrmbackup/Weekly
fi
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
        if [ $(date +"%A" -d "$line")=="Sunday" ]; then
                echo "$(ls -d *$line* | awk '{printf $1 " "}')" >> $LOG
                mv $(ls -d *$line*)  $DIRECTORY/meracrmbackup/Weekly/MeraCRM-$TODATE
    fi
done
echo "" >> $LOG

###### Removing dump older then 3 day ######
cd $DIRECTORY/meracrmbackup/
echo "" >> $LOG
echo "Removing dump older then 3 days" >> $LOG
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt

cat date.txt | while read line
do
    if [ $(date -d "$line" +"%s") -lt $(date -d "-3 days" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf $(ls *$line* )
    fi    
done


################################## **smsbrain Dir** ################################
echo "Processing smsbrain Backup...!!" >> $LOG
LOGDATE=$(TZ=Asia/Kolkata date  "+%d%m%y")
cd $DIRECTORY/smsbrain
echo "" >> $LOG

echo "Moving smsbrain backup in log Directory" >> $LOG
if [ ! -d "$DIRECTORY/smsbrain/log" ]; then
  mkdir $DIRECTORY/smsbrain/log
fi

#mv $DIRECTORY/smsbrain/logs $DIRECTORY/smsbrain/log-trunk-$LOGDATE
echo "" >> $LOG

############################### **Cleaninglog Backup** ##############################
echo "" >> $LOG
echo "##################################################################" >> $LOG
echo "Processing cleaninglog Backup...!!!" >> $LOG
echo "##################################################################" >> $LOG
echo "" >> $LOG

####### Yearly Backup cleaninglog #######
echo "Processing Yearly Dumps....!!" >> $LOG
cd $DIRECTORY/cleaninglog

echo "" >> $LOG
echo "Moving Yearly Backup to Yearly Directory" >> $LOG
if [ ! -d "$DIRECTORY/cleaninglog/Yearly" ]; then
  mkdir $DIRECTORY/cleaninglog/Yearly
fi
echo "" >> $LOG
ls | grep -E '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}' | sort | uniq > date.txt

cat date.txt | while read line
do
    if [ $(date +"%m-%d" -d "$(echo $line | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}')")==12-31 ]; then
                mv $line  $DIRECTORY/cleaninglog/Yearly
    fi
done
echo "" >> $LOG

###### Monthly Backup cleaninglog######
echo "Processing Monthly Dumps...!!" >> $LOG
cd $DIRECTORY/cleaninglog

echo "" >> $LOG
echo "Moving Monthly Backup to Monthly Directory" >> $LOG
if [ ! -d "$DIRECTORY/cleaninglog/Monthly" ]; then
  mkdir $DIRECTORY/cleaninglog/Monthly
fi
echo "" >> $LOG
ls | grep -E '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}' | sort | uniq > date.txt
cat date.txt | while read line
do
    if [ $(date +"%F" -d "$(echo $line | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}')")==$(date -d "`date +%Y%m01` +1 month -1 day" +%Y-%m-%d) ]; then
                mv $(ls *$line* )  $DIRECTORY/cleaninglog/Monthly
    fi
done
echo "" >> $LOG

##### Weekly Backup cleaninglog #####
echo "Processing Weekly Dumps...!!" >> $LOG
cd $DIRECTORY/cleaninglog

echo "" >> $LOG
echo "Moving Weekly Backup to Weekly Directory" >> $LOG
if [ ! -d "$DIRECTORY/cleaninglog/Weekly" ]; then
  mkdir $DIRECTORY/cleaninglog/Weekly
fi

echo "" >> $LOG
ls | grep -E '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}' | sort | uniq > date.txt
cat date.txt | while read line
do
    if [ $(date +"%A" -d "$(echo $line | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}')")=="Sunday" ]; then
                mv $line  $DIRECTORY/cleaninglog/Weekly
    fi
done
echo "" >> $LOG
echo "---------------------------------------------------------------------------" >> $LOG
echo "" >> $LOG


############################## BookMyFarm Backup Process #############################

echo "##################################################################" >> $LOG
echo "Processing BookMyFarm backup...!!!" >> $LOG
echo "##################################################################" >> $LOG
echo "" >> $LOG

####### Daily Backup BookMyFarm ###############
echo "Processing Daily Dumps...!!" >> $LOG
cd $DIRECTORY/bookmyfarm
echo "" >> $LOG

if [ ! -d "$DIRECTORY/bookmyfarm/Daily" ]; then
  mkdir $DIRECTORY/bookmyfarm/Daily
fi
#mv $DIRECTORY/bookmyfarm/Hourly/bookmyfarm-$DATE_CUST-00.tar.gz  $DIRECTORY/bookmyfarm/Daily/
echo "" >> $LOG

####### Yearly Backup BookMyfarm#########
echo "Processing BookMyfarm Yearly Dumps...!!" >> $LOG
cd $DIRECTORY/bookmyfarm/Daily

echo "" >> $LOG
echo "Moving Yearly Backup to Yearly Directory" >> $LOG
if [ ! -d "$DIRECTORY/bookmyfarm/Yearly" ]; then
  mkdir $DIRECTORY/bookmyfarm/Yearly
fi
echo "" >> $LOG

ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
        if [ $(date +"%F" -d "$line")==$YEAR-12-31 ]; then
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                mv $(ls *$line* | awk '{printf $1 " "}')  $DIRECTORY/bookmyfarm/Yearly
    fi
done
echo "" >> $LOG

###### Monthly Backup BookMyfarm ######
echo "Processing BookMyFarm Monthly Dumps....!!" >> $LOG
cd $DIRECTORY/bookmyfarm/Daily

echo "" >> $LOG
echo "Moving Monthly Backup to Monthly Directory" >> $LOG
if [ ! -d "$DIRECTORY/bookmyfarm/Monthly" ]; then
  mkdir $DIRECTORY/bookmyfarm/Monthly
fi
echo "" >> $LOG

ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
        if [ $(date +"%F" -d "$line")==$(date -d "`date +%Y%m01` +1 month -1 day" +%Y-%m-%d) ]; then
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                mv $(ls *$line*)  $DIRECTORY/bookmyfarm/Monthly
    fi
done
echo "" >> $LOG

###### Weekly Backup BookMyfarm ######
echo "Processing Bookmyfarm Weekly Dumps...!!" >> $LOG
cd $DIRECTORY/bookmyfarm/Daily

echo "" >> $LOG
echo "Moving Weekly Backup to Weekly Directory" >> $LOG
if [ ! -d "$DIRECTORY/bookmyfarm/Weekly" ]; then
  mkdir $DIRECTORY/bookmyfarm/Weekly
fi
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
        if [ $(date +"%A" -d "$line")=="Sunday" ]; then
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                mv $(ls *$line*)  $DIRECTORY/bookmyfarm/Weekly
    fi
done
echo "" >> $LOG

echo "----------------------------------------------------------------------------" >> $LOG
echo "" >> $LOG

############## Remove BookMyFarm Directory ############ 
cd $DIRECTORY/bookmyfarm/Hourly
echo "Removing dump older then 3 days" >> $LOG
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
        if [ $(date -d "$line" +"%s") -lt $(date -d "-3 days" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf $(ls *$line* | awk '{printf $1 " "}')
    fi
done

cd $DIRECTORY/bookmyfarm/Daily
echo "Removing dump older then 7 days" >> $LOG
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
        if [ $(date -d "$line" +"%s") -lt $(date -d "-8 days" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf $(ls *$line* | awk '{printf $1 " "}')
    fi
done

cd $DIRECTORY/bookmyfarm/Weekly/
echo "Removing dump older then 1 Week from weekly" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
echo "" >> $LOG
cat date.txt | while read line
do
        if [ $(date -d "$line" +"%s") -lt $(date -d "-1 weeks" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf $(ls *$line* | awk '{printf $1 " "}')
        fi
done

cd $DIRECTORY/bookmyfarm/Monthly/
echo "Removing dump older then 1 Month from Month" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
echo "" >> $LOG
cat date.txt | while read line
do
        if [ $(date -d "$line" +"%s") -lt $(date -d "-1 months" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf $(ls *$line* | awk '{printf $1 " "}')
        fi
done

cd $DIRECTORY/bookmyfarm/Yearly/
echo "Removing dump older then 1 year " >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
echo "" >> $LOG
cat date.txt | while read line
do
        if [ $(date -d "$line" +"%s") -lt $(date -d "-1 years" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf $(ls *$line* | awk '{printf $1 " "}')
        fi
done


echo "" >> $LOG
echo "------------------------------------------------------------------" >> $LOG
echo "" >> $LOG

echo "" >> $LOG
echo "##################################################################" >> $LOG
echo "Processing MeraBox Backup...!!!" >> $LOG
echo "##################################################################" >> $LOG
echo "" >> $LOG

echo "*** Processing Yearly Dumps ***" >> $LOG
cd $DIRECTORY/merabox

echo "" >> $LOG
echo "Moving Yearly Backup to Yearly Directory" >> $LOG
if [ ! -d "$DIRECTORY/merabox/Yearly" ]; then
  mkdir $DIRECTORY/merabox/Yearly
fi
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
    if [ $(date +"%F" -d "$line") == $YEAR-12-31 ]; then
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                mv $(ls *$line* )  $DIRECTORY/merabox/Yearly
    fi
done
echo "" >> $LOG

echo "*** Processing Monthly Dumps ***" >> $LOG
cd $DIRECTORY/merabox

echo "" >> $LOG
echo "Moving Monthly Backup to Monthly Directory" >> $LOG
if [ ! -d "$DIRECTORY/merabox/Monthly" ]; then
  mkdir $DIRECTORY/merabox/Monthly
fi
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
    if [ $(date +"%F" -d "$line") == $(date -d "`date +%Y%m01` +1 month -1 day" +%Y-%m-%d) ]; then
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                mv $(ls *$line* )  $DIRECTORY/merabox/Monthly
    fi
done
echo "" >> $LOG

echo "*** Processing Weekly Dumps ***" >> $LOG
cd $DIRECTORY/merabox

echo "" >> $LOG
echo "Moving Weekly Backup to Weekly Directory" >> $LOG
if [ ! -d "$DIRECTORY/merabox/Weekly" ]; then
  mkdir $DIRECTORY/merabox/Weekly
fi
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
    if [ $(date +"%A" -d "$line") == "Sunday" ]; then
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                mv $(ls *$line* )  $DIRECTORY/merabox/Weekly
    fi
done
echo "" >> $LOG
echo "Removing dump older then 3 days" >> $LOG
echo "" >> $LOG
cat date.txt | while read line
do
    if [ $(date -d "$line" +"%s") -lt $(date -d "-3 days" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf $(ls *$line* )
    fi
done

cd $DIRECTORY/merabox/Weekly
echo "" >> $LOG
echo "Removing dump older then 2 days" >> $LOG
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
    if [ $(date -d "$line" +"%s") -lt $(date -d "-4 Weeks" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf $(ls *$line* )
    fi
done

cd $DIRECTORY/merabox/Monthly
echo "" >> $LOG
echo "Removing dump older then 1 month" >> $LOG
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
    if [ $(date -d "$line" +"%s") -lt $(date -d "-1 months" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf $(ls *$line*)
    fi
done



echo "" >> $LOG
echo "------------------------------------------------------------------" >> $LOG
echo "" >> $LOG


echo "##################################################################" >> $LOG
echo "Server Auto Dump Management Completed...!!!" >> $LOG
echo "##################################################################" >> $LOG
