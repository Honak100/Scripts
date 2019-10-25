############################# postgrysql BizBrain/MeraCRM/Connectly #################################

############################### BizBrain Dir ####################################
PGSDIR="$DIRECTORY/postgrysql"

echo "##################################################################" >> $LOG
echo "Processing BizBrain Backup...!!!" >> $LOG
echo "##################################################################" >> $LOG
echo "" >> $LOG

cd $PGSDIR/BizBrain

####### Yearly Backup bizbrain #########
echo "" >> $LOG
echo "Moving Monthly Backup to Yearly Directory" >> $LOG
if [ ! -d "$PGSDIR/BizBrain/Yearly" ]; then
  mkdir $PGSDIR/BizBrain/Yearly
fi
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
    if [ $(date +"%F" -d "$line")==$YEAR-12-31 ]; then
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                mv $(ls *$line* )  $PGSDIR/BizBrain/Yearly
    fi
done
echo "" >> $LOG

###### Monthly Backup BizBrain ######
echo "" >> $LOG
echo "Moving Monthly Backup to Monthly Directory" >> $LOG
if [ ! -d "$PGSDIR/BizBrain/Monthly" ]; then
  mkdir $PGSDIR/BizBrain/Monthly
fi
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
    if [ $(date +"%F" -d "$line")==$(date -d "`date +%Y%m01` +1 month -1 day" +%Y-%m-%d) ]; then
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                mv $(ls *$line* )  $PGSDIR/BizBrain/Monthly
    fi
done
echo "" >> $LOG


###### Weekly Backup BizBrain ######
echo "*** Processing Weekly Dumps ***" >> $LOG
cd $PGSDIR/BizBrain

echo "" >> $LOG
echo "Moving Weekly Backup to Weekly Directory" >> $LOG
if [ ! -d "$PGSDIR/Weekly" ]; then
  mkdir $PGSDIR/BizBrain/Weekly
fi
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt
cat date.txt | while read line
do
    if [ $(date +"%A" -d "$line")=="Sunday" ]; then
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                mv $(ls *$line* )  $PGSDIR/BizBrain/Weekly
    fi
done
echo "" >> $LOG

###### Removing dump older then 3 day ######
cd $PGSDIR/BizBrain/ 
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

### 1 week remove
cd $PGSDIR/BizBrain/Weekly 
echo "" >> $LOG
echo "Removing dump older then 1 weeks" >> $LOG
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt

cat date.txt | while read line
do
    if [ $(date -d "$line" +"%s") -lt $(date -d "-2 weeks" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf $(ls *$line* )
    fi    
done

### 1 month remove
cd $PGSDIR/BizBrain/ 
echo "" >> $LOG
echo "Removing dump older then 1 months" >> $LOG
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt

cat date.txt | while read line
do
    if [ $(date -d "$line" +"%s") -lt $(date -d "-2 months" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf $(ls *$line* )
    fi    
done


################################## postgresql//Connectly #####################################

echo "Processing yearly dump" >> $LOG
######### yearly backup Connectly ########
cd $PGSDIR/Connectly/
echo "" >> $LOG

echo "Moving Yearly Backup to Yearly Directory" >> $LOG
if [ ! -d "$PGSDIR/Connectly/Yearly" ]; then
  mkdir $PGSDIR/Connectly/Yearly
fi

ls | grep -E '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}' | sort | uniq > date.txt

cat date.txt | while read line
do
    if [ $(date +"%m-%d" -d "$(echo $line | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}')") == 12-31 ]; then
                mv $line  $PGSDIR/Connectly/Yearly
    fi
done
echo "" >> $LOG

####### monthly Backup Connectly ##########
cd $PGSDIR/Connectly/
echo "" >> $LOG

echo "Moving Monthly Backup to Monthly Directory" >> $LOG
if [ ! -d "$PGSDIR/Connectly/Monthly" ]; then
  mkdir $PGSDIR/Connectly/Monthly
fi

ls | grep -E '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}' | sort | uniq > date.txt

cat date.txt | while read line
do
    if [ $(date +"%F" -d "$line") == $(date -d "`date +%Y%m01` +1 month -1 day" +%Y-%m-%d) ]; then
                mv $line  $PGSDIR/Connectly/Monthly
    fi
done
echo "" >> $LOG

###### weekly Backup Connectly ########
cd $PGSDIR/Connectly/
echo "" >> $LOG

echo "Moving Monthly Backup to Monthly Directory" >> $LOG
if [ ! -d "$PGSDIR/Connectly/Weekly" ]; then
  mkdir $PGSDIR/Connectly/Weekly
fi

ls | grep -E '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}' | sort | uniq > date.txt

cat date.txt | while read line
do
    if [ $(date +"%m-%d" -d "$line") == "Sunday" ]; then
                
                mv $line  $PGSDIR/Connectly/weekly
    fi
done
echo "" >> $LOG

###### Removing dump older then 3 day ######
cd $DIRECTORY/postgrysql/Connectly/ 
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

### remove 1 week older
cd $PGSDIR/Connectly/
echo "" >> $LOG
echo "Removing dump older then 1 Week" >> $LOG
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt

cat date.txt | while read line
do
    if [ $(date -d "$line" +"%s") -lt $(date -d "-2 weeks" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf $(ls *$line* )
    fi    
done

#### remove 1 month older
cd $PGSDIR/Connectly/ 
echo "" >> $LOG
echo "Removing dump older then 1 months" >> $LOG
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt

cat date.txt | while read line
do
    if [ $(date -d "$line" +"%s") -lt $(date -d "-2 months" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf $(ls *$line* )
    fi    
done


################################## postgresql/MeraCRM #####################################

echo "Processing yearly dump" >> $LOG
######### yearly backup MeraCRM ########
cd $PGSDIR/MeraCRM/
echo "" >> $LOG

echo "Moving Yearly Backup to Yearly Directory" >> $LOG
if [ ! -d "$PGSDIR/MeraCRM/Yearly" ]; then
  mkdir $PGSDIR/MeraCRM/Yearly
fi

ls | grep -E '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}' | sort | uniq > date.txt

cat date.txt | while read line
do
    if [ $(date +"%m-%d" -d "$(echo $line | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}')")==12-31 ]; then
                mv $line  $PGSDIR/MeraCRM/Yearly
    fi
done
echo "" >> $LOG

####### monthly Backup MeraCRM ##########
cd $PGSDIR/MeraCRM/
echo "" >> $LOG

echo "Moving Monthly Backup to Monthly Directory" >> $LOG
if [ ! -d "$PGSDIR/MeraCRM/Monthly" ]; then
  mkdir $DIRE$PGSDIR/MeraCRM/Monthly
fi

ls | grep -E '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}' | sort | uniq > date.txt

cat date.txt | while read line
do
    if [ $(date +"%F" -d "$line")==$(date -d "`date +%Y%m01` +1 month -1 day" +%Y-%m-%d) ]; then
                mv $line  $PGSDIR/MeraCRM/Monthly
    fi
done
echo "" >> $LOG

###### weekly Backup MeraCRM ########
cd $PGSDIR/MeraCRM/
echo "" >> $LOG

echo "Moving Monthly Backup to Monthly Directory" >> $LOG
if [ ! -d "$PGSDIR/MeraCRM/Weekly" ]; then
  mkdir $PGSDIR/MeraCRM/Weekly
fi

ls | grep -E '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}' | sort | uniq > date.txt

cat date.txt | while read line
do
    if [ $(date +"%m-%d" -d "$line")=="Sunday" ]; then
                
                mv $line  $PGSDIR/MeraCRM/weekly
    fi
done
echo "" >> $LOG

###### Removing dump older then 3 day ######
cd $PGSDIR/MeraCRM/ 
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

### remove 1 week older
cd $PGSDIR/MeraCRM/ 
echo "" >> $LOG
echo "Removing dump older then 1 weeks" >> $LOG
echo "" >> $LOG
ls | grep -E "[[:digit:]]{4}" | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}" | sort | uniq > date.txt

cat date.txt | while read line
do
    if [ $(date -d "$line" +"%s") -lt $(date -d "-2 weeks" +"%s") ]; then
                echo "" >> $LOG
                echo "$(ls *$line* | awk '{printf $1 " "}')" >> $LOG
                rm -rf $(ls *$line* )
    fi    
done

### remove 1 month older
cd $PGSDIR/MeraCRM/ 
echo "" >> $LOG
echo "Removing dump older then 1 months" >> $LOG
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

