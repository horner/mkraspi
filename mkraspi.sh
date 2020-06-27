:
if sudo -n true
then
  echo
else
  echo "sorry, this script needs suso access"
  exit
fi


image=`ls -Art *.img | tail -n 1`  # get the latest image
echo "Image: $image"

if [ ! -f "$image" ]; then
	echo "Go download the latest image from https://www.raspberrypi.org/downloads/raspberry-pi-os/ and place here. The file should have an .img extension"
fi

# Tell the user about disks:
diskutil list external
# get the last disk added
disk=`diskutil list  external | grep external | tail -n 1 | cut -f 1 -d" " | cut -c6-`
if [ "$disk" == "" ]; then echo "No external disks found.  Make sure there is some SD card inserted.  Try reinserting it."; exit; fi

# Ask the user if they are sure we go the right disk
while true; do
    read -p "Do you wish to install $image to /dev/$disk?  Yes or No. " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no. ";;
    esac
done

# ask them again since this could be really bad if we overwrite the wrong disk.
while true; do
    read -p "Are you sure?  It will destroy /dev/$disk.  Yes or No. " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no. ";;
    esac
done
echo;echo;echo;echo
echo "**** The rest is automated, you can go get a cup of coffee.  See ya in a couple mins. ****"
echo;echo;echo;echo
# unmount the disk
echo diskutil unmountDisk /dev/$disk
diskutil unmountDisk /dev/$disk

# write out the image, every 10 seconds showing progress
dd bs=1m if=$image of=/dev/r$disk & while pkill -INFO -x dd; do sleep 10;  echo `stat -f%z $image` total ;  done
sync

# wait for 5 seconds for the drive to come back
counter=0
while [ $counter -lt 5 ]; do
    #get the mount point for the disk
    mount=`mount | grep "^/dev/$disk" | cut -d" " -f3`
    echo mount: $mount
    if [ -f "$mount/config.txt" ]; then
        counter=5
    else
        diskutil mount ${disk}s1
        sleep 1
        counter=$(( $counter + 1 ))
    fi
done

# verify we wrote it out properly
mount=`mount | grep "^/dev/${disk}" | cut -d" " -f3`
echo Updating: $mount
if [ ! -f "$mount/config.txt" ]; then
	echo Something went wrong with the build. $mount/config.txt not found.
	exit
fi

# enable ssh
echo setting up ssh.  touch $mount/ssh
touch $mount/ssh

# add the wireless config if there
if [ -f wpa_supplicant.conf ]; then
	echo "Copying wpa_supplicant.conf"
	cp wpa_supplicant.conf $mount/wpa_supplicant.conf
fi

#eject the drive
echo "Ejecting $disk.  Go ahead and install in Pi now."
diskutil eject /dev/r$disk

echo "Afterward:"
echo "ssh pi@raspberrypi.local"
