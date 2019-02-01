#! /system/bin/sh

no=0
dir_pre="/storage/disk"
blkid_cache="/data/system/blkid.cache"
blkid_tmp="/data/system/blkid.tmp"
RECOVERY_DIR="Recovery/WindowsRE"
RECOVERY_FILE="Winre.wim"

echo -n "" > $blkid_cache
echo -n "" > $blkid_tmp
chmod 666 $blkid_cache
chmod 666 $blkid_tmp

blkid > $blkid_tmp

while read line
do
    dir=$dir_pre$no
    devNode=`echo $line |grep "^/dev/block/.* TYPE=\"ntfs\"" |grep -v "WINRE_DRV" |grep -v "PBR_DRV" |awk -F ':' '{print $1}'`
    if [ "$devNode" != "" ]; then
	if [ ! -d $dir ]; then
	    mkdir $dir
	fi
	ntfs-3g $devNode $dir
	mountStatus=$?
	if [ $mountStatus -eq 0 ]; then
		if [ -d $dir/$RECOVERY_DIR ]; then
			if [ -e $dir/$RECOVERY_DIR/$RECOVERY_FILE ]; then
				diskSize=`df -H $dir |awk '{print $2}' |grep -v "Size"`
				if echo $diskSize |grep "M"; then
					umount $dir
					continue
				fi
			fi
		fi

	    raw=`blkid $devNode`
	    echo $raw" MOUNT=\""$dir"\"" >> $blkid_cache
	    ((no++))
	fi
    fi	
done < $blkid_tmp

rm $blkid_tmp

return 0
