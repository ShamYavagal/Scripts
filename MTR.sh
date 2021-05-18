#!/bin/bash
#Author: Sham Yavagal

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/home/scripts

TIME1=$(date | awk '{print ($2"-"$3"-"$4)}' | cut -f 1 -d ':')
TIME=$(date | awk '{print ($4)}')

mkdir -p $1/mtr_logs/$TIME1
DIRPATH=$1/mtr_logs/$TIME1

mkdir -p /tmp/mtr-script-files/
TMP_DIRPATH="/tmp/mtr-script-files"

URLs=$2

if [[ $# != 2 ]]; then
    echo $# "Usuage: script Dir_To_Create_For_File url -- Example /home/mtrlogs/ MTR.sh google.com"
    exit 1
fi

for each in $URLs
    do
        echo "........................." >> $DIRPATH/mtr.log.$TIME

        printf "\n" >> $DIRPATH/mtr.log.$TIME

        echo  "MTR report of" $each >> $DIRPATH/mtr.log.$TIME

        printf "\n" >> $DIRPATH/mtr.log.$TIME

        echo "........................." >>  $DIRPATH/mtr.log.$TIME

        mtr -rc 1 --no-dns $each >> $DIRPATH/mtr.log.$TIME

        echo ".........................." >> $DIRPATH/mtr.log.$TIME

        printf "\n" >> $DIRPATH/mtr.log.$TIME

    done

CURRENT_MTR_FILE=$DIRPATH/mtr.log.$TIME

chmod 777 $CURRENT_MTR_FILE

#echo $(basename $CURRENT_MTR_FILE)

PREVIOUS_MTR_FILE=$(ls -t $DIRPATH | head -n2 | sed -ne '2p')

chmod 777 $DIRPATH/$PREVIOUS_MTR_FILE

MTRPATH=$(mtr -rc 1 --no-dns $URLs | sed -ne '3,$p' | sed '$d' | awk '{print $2}')

if [[ -f "$DIRPATH/$PREVIOUS_MTR_FILE" ]]; then
    FILE_MTRPATH=$(sed -ne '8,$p' $DIRPATH/$PREVIOUS_MTR_FILE | sed '$d'| awk '{print $2}')
    for i in $FILE_MTRPATH
        do
	    echo $i >> $TMP_DIRPATH/FILE_MTRPATH.$TIME
        done
    echo "PREVIOUS FILE" $(basename $DIRPATH/$PREVIOUS_MTR_FILE)
else
    FILE_MTRPATH=$(sed -ne '8,$p' $CURRENT_MTR_FILE | sed '$d' | awk '{print $2}')
    for i in $FILE_MTRPATH
        do
	    echo $i >> $TMP_DIRPATH/FILE_MTRPATH.$TIME
        done
    echo "CURRENT FILE" $(basename $CURRENT_MTR_FILE)
fi

if 
    [[ "$FILE_MTRPATH" == "$MTRPATH" ]]; then
    
    MTR_CHECK="PASSED"
    echo "Path is Consistant and MTR Check" $MTR_CHECK
else
    MTR_CHECK="FAILED"
    echo "Path is InConsistant and MTR Check" $MTR_CHECK
fi
 

FILE_MTRPATH_COUNT=$(echo $TMP_DIRPATH/FILE_MTRPATH.$TIME | wc -l)
MTR_COUNT=$(mtr -rc 1 --no-dns $URLs | sed -ne '3,$p' | sed '$d' | awk '{print $2}' | wc -l)
echo "PREVIOUS HOPS TO" $URLs $(cat $TMP_DIRPATH/FILE_MTRPATH.$TIME | wc -l) "CURRENT HOPS TO" $URLs $MTR_COUNT
echo $FILE_MTRPATH
echo $MTRPATH
echo "HOPS FROM PREVIOUS RUN : " $(cat $TMP_DIRPATH/FILE_MTRPATH.$TIME) 

echo "HOPS FROM CURRENT RUN : " $(mtr -rc 1 --no-dns $URLs | sed -ne '3,$p' | sed '$d' | awk '{print $2}')

if [[ "$FILE_MTRPATH_COUNT" != "$MTR_COUNT" ]]; then
    echo "The Number of Network Hops to" $URLs "Changed around" $TIME #| mail -r \       #--> Substitute With Your From And To Email IDs.
    #"<from@yourdomain.com>" -s "MTR Path To" $URLs "Changed" to@yourdomain.com
    echo "$FILE_MTRPATH" \n\n "$MTRPATH" | mail -r "<no-reply@sninoc.com>" -s "MTR Path to" URLs "Changed" shambuveer.yavagal@showtime.net,

elif [[ $MTR_CHECK == "FAILED" ]]; then
    echo "The Network Path to" $URLs "Changed around" $TIME #| mail -r \
    #"<from@yourdomain.com>" -s "MTR Path To" $URLs "Changed" to@yourdomain.com
    echo "$FILE_MTRPATH" \n\n "$MTRPATH" | mail -r "<no-reply@sninoc.com>" -s "MTR Path to" $URLs "Changed" shambuveer.yavagal@showtime.net,
else 
    echo "The Network Path to" $URLs  "and Number of Hops has not changed" > /dev/null
fi


