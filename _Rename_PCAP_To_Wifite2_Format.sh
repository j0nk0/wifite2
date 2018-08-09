#!/bin/bash
#set -x
#Rename .cap files to the new name scheme of wifite2

#Example
# handshake_Ziggo88922_B0-C2-87-E4-1D-A7_2018-07-19T06-52-27.cap
# handshake_  ESSID   _    BSSID        _YYYY-MM-DD T HH-MM-SS .cap

#Remove empty .cap files
 find -name "*.cap" -type f -empty -exec rm --interactive --verbose {} +


for i in $(find $(dirname $0) -iname "*.cap" -o -iname "*.hccapx" |grep -v ".tar")
 do

#Fix capfile
if ! [ -f $i ]; then
 echo "error! file $i not found"
 exit
else
 CAPFILE="$i"

pyrit -r "$CAPFILE" analyze &>/dev/null
 if [ $? = 1 ];then
  echo "Error found!"
  echo "Backing up file: $CAPFILE"
   tar --backup=numbered -cvf "$CAPFILE.tar" "$CAPFILE"

CAPFILEMERGED="$(dirname $CAPFILE)/$(basename $CAPFILE .cap).mergecapped"
  mergecap -w "$CAPFILEMERGED" "$CAPFILE"
  echo "Merged/Fixed file saved as: $CAPFILEMERGED"
CAPFILE="$CAPFILEMERGED"
 fi

 var_=$(pyrit -r "$CAPFILE" analyze | grep -e 'AccessPoint' | head -n1)
  ESSID=$(echo $var_| awk '{ print $4 }'|tr -d "'(" |tr -d ")'" |tr -d ":")
  BSSID=$(echo $var_| awk '{ print $3 }'|tr ":" "-"|tr [:lower:] [:upper:])
  DATE_=$(stat -c ""%y"" "$CAPFILE" | cut -d "." -f1 | tr " " "T" | tr ":" "-")

    echo "Renaming: $CAPFILE"
#       mv --backup=numbered --verbose "$CAPFILE" handshake_$(echo $ESSID)_$(echo $BSSID)_$(date -u +%G-%m-%dT%H-%M-%S).cap
#    new_name_scheme=$(handshake_$(echo $ESSID)_$(echo $BSSID)_$(date -u +%G-%m-%dT%H-%M-%S).cap)
    mv --backup=numbered --verbose "$CAPFILE" handshake_$(echo $ESSID)_$(echo $BSSID)_$(echo $DATE_).cap
fi
done

exit


#     if [ -f $new_name_scheme ];then
#      mv $new_name_scheme
#     fi

#     if ! [ -f $new_name_scheme ];then
#       mv --backup=numbered --verbose "$i" $new_name_scheme
#     else
#        echo "File $new_name_scheme exists"
#     fi
