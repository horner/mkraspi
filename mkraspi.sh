:

image=`ls -Art *.img | tail -n 1`  # get the latest image
echo "Image: $image"

if [ ! -f "$image" ]
then
	echo "Go download the latest image from https://www.raspberrypi.org/downloads/raspberry-pi-os/ and place here. The file should have an .img extension"
fi

# Tell the user about disks:
diskutil list external
disk=`diskutil list  external | grep external | tail -n 1 | cut -f 1 -d" " | cut -c6-`

while true; do
    read -p "Do you wish to install $image to /dev/$disk?  Yes or No. " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no. ";;
    esac
done
while true; do
    read -p "Are you sure?  It will destroy /dev/$disk.  Yes or No. " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no. ";;
    esac
done

echo diskutil unmountDisk /dev/$disk
diskutil unmountDisk /dev/$disk
dd bs=1m if=$image of=/dev/r$disk & while pkill -INFO -x dd; do sleep 10;  echo `stat -f%z $image` total ;  done
sync

mount=`mount | grep "^/dev/$disk" | cut -d" " -f3`
echo Updating: $mount
if [ ! -f "$mount/config.txt" ]
then
	echo Something went wrong with the build. config.txt not found.
	exit
fi
echo setting up ssh.  touch $mount/ssh
touch $mount/ssh

if [ -f wpa_supplicant.conf ]; then
	echo "Copying wpa_supplicant.conf"
	cp wpa_supplicant.conf $mount/wpa_supplicant.conf
fi
exit


sudo diskutil eject /dev/r$disk
