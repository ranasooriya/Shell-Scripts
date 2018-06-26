#!/bin/bash

if [ "$1" != "" ];then
        REPORTDATE="$1"
else
        REPORTDATE=`date +%Y%m%d`
fi

REPORTNAME="$REPORTDATE.html"

# FTP Environment Variables
FTPSERVER="SERVERNAME"
USER="USERNAME"
PASSWD="PASSWORD"
LOCATION="WEBPATH"
FILE="$REPORTNAME"

ndays=7


# work out our cutoff date
TDATE=`date --date="$ndays days ago" +%Y%m%d`
##############################################################
ssh <username>@<servername> 'cat <logfile>' > mainChecker.${REPORTDATE}.summary.log
UNIXSUMMARYLOG="mainChecker.${REPORTDATE}.summary.log"
echo '<style>
        table.tableizer-table {
                font-size: 12px;
                border: 1px solid #CCC;
                font-family: Arial, Helvetica, sans-serif;
        }
        .tableizer-table td {
                padding: 12px;
                margin: 3px;
        }
        .tableizer-table th {
                background-color: #104E8B;
                color: #FFF;
                font-weight: bold;
        }
        * {
  box-sizing: border-box;
}
</style>' > $REPORTNAME
echo '<table class="tableizer-table" id="tblLogs">' >> $REPORTNAME
while IFS= read line
do
        echo "$line" |awk '{ $3=""; $4=""; $6=""; $7=""; $8=""; $9=""; $10=""; print}' |column -t > temp.txt
        REPDATE=`cat temp.txt |awk '{print $1}'`
        STARTTIME=`cat temp.txt |awk '{print $2}'`
        ENDTIME=`cat temp.txt |awk '{print $3}'`
        PUB=`cat temp.txt |awk '{print $5}'`
        PUBERROR=`cat temp.txt |awk '{print $6}'`
        QUA=`cat temp.txt |awk '{print $8}'`
        QUAERROR=`cat temp.txt |awk '{print $9}'`
        inPr=`cat temp.txt |awk '{print $11}'`
        rem=`cat temp.txt |awk '{print $13}'`
        dw=`cat temp.txt |awk '{print $15}'`
        dwerror=`cat temp.txt |awk '{print $16}'`
        wlF=`cat temp.txt |awk '{print $18}'`
        cnP=`cat temp.txt |awk '{print $20}'`
        cnPERROR=`cat temp.txt |awk '{print $21}'`
        cnF=`cat temp.txt |awk '{print $23}'`
        cnFERROR=`cat temp.txt |awk '{print $24}'`
        cnS=`cat temp.txt |awk '{print $26}'`
        cnSERROR=`cat temp.txt |awk '{print $27}'`
        cnO=`cat temp.txt |awk '{print $29}'`
        cnOERROR=`cat temp.txt |awk '{print $30}'`
        cnV=`cat temp.txt |awk '{print $32}'`
        cnVERROR=`cat temp.txt |awk '{print $33}'`
        echo '<tr><td>'$REPDATE'</td><td>'$STARTTIME'</td><td>'$ENDTIME'</td><td>PUB:</td><td>'$PUB'</td><td>'$PUBERROR'</td><td>QUA:</td><td>'$QUA'</td><td>'$QUAERROR'</td><td>inPr:</td><td>'$inPr'</td><td>rem:</td><td>'$rem'</td><td>dw:</td><td>'$dw'</td><td>'$dwerror'</td><td>wlF:</td><td>'$wlF'</td><td>cnP:</td><td>'$cnP'</td><td>'$cnPERROR'</td><td>cnF:</td><td>'$cnF'</td><td>'$cnFERROR'</td><td>cnS:</td><td>'$cnS'</td><td>'$cnSERROR'</td><td>cnO:</td><td>'$cnO'</td><td>'$cnOERROR'</td><td>cnV:</td><td>'$cnV'</td><td>'$cnVERROR'</td></tr>' >> $REPORTNAME
done < "$UNIXSUMMARYLOG"
echo '</table>' >> $REPORTNAME
ftp -n $FTPSERVER <<END_SCRIPT
quote USER $USER
quote PASS $PASSWD
cd $LOCATION
put $FILE
quit
END_SCRIPT
OUTFILE="ftplist.txt"
CMDFILE="ftpcmd.txt"
echo Removing files older than $TDATE
ftp -n $FTPSERVER <<EOMYF
quote USER $USER
quote PASS $PASSWD
binary
cd $LOCATION
ls -l $OUTFILE
quit
EOMYF
if [ -f "$OUTFILE" ];then
        # Load the listing file into an array
        IFS=$'\r\n' GLOBIGNORE='*' command eval 'lista=($(cat ftplist.txt))'
        # Create the FTP command file to delete the files
        echo "user $USER $PASSWD" > $CMDFILE
        echo "binary" >> $CMDFILE
        echo "cd $LOCATION"  >> $CMDFILE
        COUNT=0
        # loop over our files
        for i in "${lista[@]}"
        do
                MDAY=`echo $i |awk '{print $1}'`
                D=`echo $MDAY |cut -c 4,5`
                M=`echo $MDAY |cut -c 1,2`
                Y=`echo $MDAY |cut -c 7,8`
                FMD="$Y-$M-$D"
                FDATE=`date -d "$FMD" +'%Y%m%d'`
                if [[ $FDATE -lt $TDATE ]];then
                        FILENAME=`echo $i |awk '{print $4}'`
                        echo "Deleting $FILENAME"
                        ftp -n $FTPSERVER <<EOMYF2
                        quote USER $USER
                        quote PASS $PASSWD
                        binary
                        cd $LOCATION
                        ls -l $OUTFILE
                        quit
                        EOMYF2
                fi
        done
        echo "quit" >> $CMDFILE
        if [[ $COUNT -gt 0 ]];then
                cat $CMDFILE | tr -d "\r" > $CMDFILE
                ftp -n $FTPSERVER < $CMDFILE > /dev/null
        else
                echo "Nothing to delete"
        fi
        #rm -f $OUTFILE $CMDFILE
fi

rm -fr $REPORTNAME
rm -fr $REPORTNAME
rm -fr $REPORTNAME
