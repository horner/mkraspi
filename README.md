
## Quick builder

* Download https://www.raspberrypi.org/downloads/raspberry-pi-os/
* inspect/edit [wpa_supplicant.conf](wpa_supplicant.conf) in this folder.
* Run mkraspi.sh
* put SD card in Pi.
Then:
```
ssh pi@raspberrypi.local
```
* pass: raspberry
```
sudo systemctl enable ssh
```
* [Secure the PI](https://www.raspberrypi.org/documentation/configuration/security.md)
```
sudo adduser horner
sudo usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,gpio,i2c,spi horner
sudo su - horner
sudo pkill -u pi
sudo deluser pi
sudo deluser -remove-home pi
```
* Update pi
```
sudo apt update
sudo apt full-upgrade
```

## Rasberry Pi Documentation

* https://github.com/raspberrypi/documentation/blob/master/installation/installing-images/mac.md

## Cool tools

This only works for read only acess tho:
```
brew cask install osxfuse
brew install ext4fuse
```
