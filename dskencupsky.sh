#!/usr/bin/sh
#
# Simple Script for Initialited and Mount a New Encrypted Disk
# Split and Upload Data to SiaSky.net
# Download and recompose splited data
# Mount Encripted Disk
# Please, be careful with this script, and use only if you know what you are doing :)
#
TIMEDATE=$(date +"%y%m%d-%H%M%S")
DSKENCNAME="encryptedDisk"
DSKPATH="/mnt"
BCHFILESIZE="500MB"
DSKENCSIZE="30000M"

## Select your prefered Portal for upload your information. I tesed with siasky.net and skyportal.xyz and worked fine.
#PORTAL="https://skynet.developmomentum.com"
#PORTAL="https://sialoop.net"
#PORTAL="https://skynet.luxor.tech"
#PORTAL="https://skynethub.io"
PORTAL="https://siasky.net"
#PORTAL="https://skyportal.xyz"
#PORTAL="https://SkyDrain.net"

#SECRETPHRASE="DRSs_Pi1bn+e?5j:-#wj/7]Jf0F\*U5&meY;"

if [ $# -eq 0 ]
then
        echo "Missing options!"
        echo "(run $0 -h for help)"
        echo ""
        exit 0

fi

ECHO="false"

while getopts "iudfrmth" OPTION; do

        case $OPTION in
                i) ECHO="initialited"
                        ;;
                u) ECHO="upload"
                        ;;
                d) ECHO="download"
                        ;;
                f) ECHO="sialink"
                        ;;
                r) ECHO="rebuild"
                        ;;
                m) ECHO="mount"
                        ;;
                h) echo "Usage:"
                echo " -i "
                echo " -u "
                echo " -d "
                echo " -f siaskylink"
                echo " -r "
                echo " -m "
                echo " -h "
                echo ""
                echo " -i Initialited A new Disk Encrypted"
                echo " -u Upload Data"
                echo " -d Download Data"
                echo " -f Download a specific SiaSky Link"
                echo " -r Only Rebuild from downloaded folder"
                echo " -m Mount Encrypted Disk"
                echo " -h Prints this help"
        exit 0
        ;;
        esac

done

if [ $ECHO = "initialited" ]

then

echo "Initialiting Encryption DiskFile $DSKPATH/$DSKENCNAME"
echo "Prerequisite cryptsetup to Encrypt new volume disk"

sudo apt-get install cryptsetup

echo "Creating main file $DSKENCNAME.iso with $DSKENCSIZE"
fallocate -l $DSKENCSIZE $DSKPATH/$DSKENCNAME.'iso'

echo "Initialiting $DSKENCNAME... (Reply YES in Uppercase) And Your Secret Phrase"
sudo cryptsetup -y luksFormat $DSKPATH/$DSKENCNAME.'iso'
echo "Openning $DSKENCNAME ... Write your Phrase bellow"
sudo cryptsetup luksOpen $DSKPATH/$DSKENCNAME.'iso' $DSKENCNAME
echo "Formating /dev/mapper/$DSKENCNAME"
sudo mkfs.ext4 /dev/mapper/$DSKENCNAME
mkdir -p $DSKPATH/$DSKENCNAME
echo "Mounting $DSKPATH/$DSKENCNAME"
mount /dev/mapper/$DSKENCNAME $DSKPATH/$DSKENCNAME
echo "Congratulations your Device $DSKPATH/$DSKENCNAME is ready for write data!"

fi

if [ $ECHO = "upload" ]

then

echo "Umounting $DSKPATH/$DSKENCNAME"
umount $DSKPATH/$DSKENCNAME
cryptsetup luksClose /dev/mapper/$DSKENCNAME
mkdir -p $DSKPATH/split
echo "split $DSKPATH/$DSKENCNAME.iso $DSKPATH/split/ --bytes=$BCHFILESIZE"
split $DSKPATH/$DSKENCNAME.iso $DSKPATH/split/ --bytes=$BCHFILESIZE
ls $DSKPATH/split > /tmp/$DSKENCNAME.upload
echo "Deleting older $DSKPATH/files_uploaded.siasky"
rm -f $DSKPATH/files_uploaded.siasky
echo "Uploading Data to SiaSky.net. Please be patient, the timeline depends of your internet connection and the amount of data and SiaSky.net service"
for i in `cat /tmp/$DSKENCNAME.upload`;do curl -X POST "$PORTAL/skynet/skyfile" -F "file=@$DSKPATH/split/$i" >> $DSKPATH/files_uploaded.siasky | echo "Uploading $DSKPATH/$DSKENCNAME/$i" >> $DSKPATH/files_uploaded.siasky;done
echo "Saving a Backup of $DSKPATH/files_uploaded.siasky as $DSKPATH/files_uploaded.siasky-$TIMEDATE"
cp $DSKPATH/files_uploaded.siasky $DSKPATH/files_uploaded.siasky-$TIMEDATE
echo "Very Important!!: For retrieve and compose Data, please save outside of your computer this file $DSKPATH/files_uploaded.siasky and Your security Phrasse. Without It, you can't recovery your data"

fi

if [ $ECHO = "download" ]

then

echo "Removing older downloaded folder $DSKPATH/download and $DSKPATH/$DSKENCNAME.iso volume"
rm -rf $DSKPATH/$DSKENCNAME.'iso'
rm -rf $DSKPATH/download
mkdir -p $DSKPATH/download
echo "Downloading files from SiaSky using $DSKPATH/files_uploaded.siasky..."
for i in `cat $DSKPATH/files_uploaded.siasky |awk -F 'skylink":"' '{ print $2}'|awk -F '","merkleroot' '{ print $1}'`;do curl "$PORTAL/$i" -o $DSKPATH/download/$i;done
echo "Composing original Data $DSKPATH/$DSKENCNAME"
ls -ltrs $DSKPATH/download/ |awk '{print $10}' > /tmp/$DSKENCNAME.downloaded
for i in `cat /tmp/$DSKENCNAME.downloaded`; do cat $DSKPATH/download/$i >> $DSKPATH/$DSKENCNAME.'iso';done
echo "All done! Active your Backup Volume $DSKPATH/$DSKENCNAME.iso using Your security Phrase"
sudo cryptsetup luksOpen $DSKPATH/$DSKENCNAME.'iso' $DSKENCNAME
echo "Mounting Encrypted Disk..."
mkdir -p $DSKPATH/$DSKENCNAME
mount /dev/mapper/$DSKENCNAME $DSKPATH/$DSKENCNAME
echo "Congratulations your Device $DSKPATH/$DSKENCNAME is ready for write data!"

fi

if [ $ECHO = "sialink" ]

then

mkdir -p $DSKPATH/download
TIMESTAMP=$(ls -l --time-style="+%Y%m%d%H%M" $DSKPATH/download|grep $2|awk '{ print $6 }')
echo "Downloading Siaskylink: $DSKPATH/download/$2"
curl "$PORTAL/$2" -o $DSKPATH/download/$2
touch -m -a -t $TIMESTAMP $DSKPATH/download/$2

fi

if [ $ECHO = "rebuild" ]

then 

echo "rm -rf $DSKPATH/$DSKENCNAME.iso"
echo "Rebuilding Data $DSKPATH/$DSKENCNAME"
ls -ltrs $DSKPATH/download/ |awk '{print $10}' > /tmp/$DSKENCNAME.downloaded1
for i in `cat /tmp/$DSKENCNAME.downloaded1`; do cat $DSKPATH/download/$i >> $DSKPATH/$DSKENCNAME.'iso';done
echo "All done! Active your Backup Volume $DSKPATH/$DSKENCNAME.iso using Your security Phrase"
sudo cryptsetup luksOpen $DSKPATH/$DSKENCNAME.'iso' $DSKENCNAME
echo "Mounting Encrypted Disk..."
mkdir -p $DSKPATH/$DSKENCNAME
mount /dev/mapper/$DSKENCNAME $DSKPATH/$DSKENCNAME
echo "Congratulations your Device $DSKPATH/$DSKENCNAME is ready for write data!"

fi

if [ $ECHO = "mount" ]

then

sudo cryptsetup luksOpen $DSKPATH/$DSKENCNAME.'iso' $DSKENCNAME
echo "Mounting Encrypted Disk..."
mkdir -p $DSKPATH/$DSKENCNAME
mount /dev/mapper/$DSKENCNAME $DSKPATH/$DSKENCNAME
echo "Congratulations your Device $DSKPATH/$DSKENCNAME is ready for write data!"

fi
