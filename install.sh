#!/bin/sh
# This file is provided to remove nightly reboots on a Xiaomi Vacuum Robot and will use a time of about 3am where the reboot normally happens.
# If your reboot is been done at a different time, please modify /etc/crontab afterwards.

echo 'Before installing, please check if the cron jobs have not been set yet. Otherwise it will add a different line in /etc/crontab.'
echo "Press Enter to continue"
read button

echo 'Install cron tasks.'

echo '#!/bin/bash

#### ---- unmount logging folder ---- ####
umount /mnt/data/rockrobo/rrlog

#### ---- following lines check Filesystem ---- ####
umount /mnt/updbuf
umount /mnt/data
umount /mnt/reserve
umount /mnt/default
fsck -y /dev/mmcblk0p10
fsck -y /dev/mmcblk0p1
fsck -y /dev/mmcblk0p11
fsck -y /dev/mmcblk0p6
mount /dev/mmcblk0p10 /mnt/updbuf
mount /dev/mmcblk0p1 /mnt/data
mount /dev/mmcblk0p11 /mnt/reserve
mount -o ro /dev/mmcblk0p6 /mnt/default
fstrim -v /
fstrim -v /mnt/updbuf
fstrim -v /mnt/data
fstrim -v /mnt/reserve
fstrim -v /mnt/default

#### ---- create new logging folder from tmpfs and link logs to /dev/null ---- ####
mountpoint -q /mnt/data/rockrobo/rrlog || mount -t tmpfs -o size=5m ext4 /mnt/data/rockrobo/rrlog
ln -s /dev/null /mnt/data/rockrobo/rrlog/watchdog.log
ln -s /dev/null /mnt/data/rockrobo/rrlog/rrlog.log
ln -s /dev/null /mnt/data/rockrobo/rrlog/miio.log

#### ---- remove existing .log and .old files ---- ####
rm /dev/shm/*.old -f

#### ---- check if reboot/remount has occured to reset the symlinks for log files ---- ####
        rm /dev/shm/*.log' > /root/check_all

echo '#!/bin/bash
#### ---- stopping rrwatchdoge after startup ---- ####
sleep 30
service rrwatchdoge stop

#### ---- create new logging folder from tmpfs and link logs to /dev/null ---- ####
mountpoint -q /mnt/data/rockrobo/rrlog || mount -t tmpfs -o size=5m ext4 /mnt/data/rockrobo/rrlog
ln -s /dev/null /mnt/data/rockrobo/rrlog/watchdog.log
ln -s /dev/null /mnt/data/rockrobo/rrlog/rrlog.log
ln -s /dev/null /mnt/data/rockrobo/rrlog/miio.log

#### ---- remove existing .log and .old files ---- ####
rm /dev/shm/*.old -f

#### ---- check if reboot/remount has occured to reset the symlinks for log files ---- ####
        rm /dev/shm/*.log

#### ---- finally start rrwatchdoge ---- ####
service rrwatchdoge start' > /root/check_reboot

echo '#!/bin/bash

echo "`date` ---"

if [ ! -d "$1" ]; then
  echo "$1 : not a directory"
  exit
fi

items="$1"/*
for item in $items
do
  if [ -d "$item" ]; then
    echo "Removing directory $item..."
    rm -fr "$item"
  elif [ -f "$item" ]; then
    if [[ $item == *".log" ]]; then
      echo "Shrinking log $item..."
      echo "$(tail -20 "$item")" > "$item"
    else
      echo "Removing file $item..."
      rm "$item"
    fi
  fi
done' > /opt/rockrobo/rrlog/logclean.sh

## wait for files to be written and released
sleep 1

chmod +x /root/check_all
chmod +x /root/check_reboot
chmod +x /opt/rockrobo/rrlog/logclean.sh

grep -qxF '#### ---- create symlinks and check once a week, also deactivate services from 2am to 4am' /etc/crontab || echo '#### ---- create symlinks and check once a week, also deactivate services from 2am to 4am' >> /etc/crontab
grep -qxF '#### ---- edit this time to be around your system reboot time. (it might run in a differen timezone than your valetudo timers)' /etc/crontab || echo '#### ---- edit this time to be around your system reboot time. (it might run in a differen timezone than your valetudo timers)' >> /etc/crontab
grep -qxF '@reboot         root    /root/check_reboot' /etc/crontab || echo '@reboot         root    /root/check_reboot' >> /etc/crontab
grep -qxF '0 2     * * *   root    service rrwatchdoge stop' /etc/crontab || echo '0 2     * * *   root    service rrwatchdoge stop' >> /etc/crontab
grep -qxF '15 2    * * 1   root    /root/check_all' /etc/crontab || echo '15 2    * * 1   root    /root/check_all' >> /etc/crontab
grep -qxF '0 4     * * *   root    service rrwatchdoge start' /etc/crontab || echo '0 4     * * *   root    service rrwatchdoge start' >> /etc/crontab
grep -qxF '#### ---- found in valetudo prebuilt FW from rand256' /etc/crontab || echo '#### ---- found in valetudo prebuilt FW from rand256' >> /etc/crontab
grep -qxF '*/5 * * * * root /opt/rockrobo/rrlog/logclean.sh /mnt/data/rockrobo/rrlog >> /mnt/data/rockrobo/rrlog/lclean.log 2>&1' /etc/crontab || echo '*/5 * * * * root /opt/rockrobo/rrlog/logclean.sh /mnt/data/rockrobo/rrlog >> /mnt/data/rockrobo/rrlog/lclean.log 2>&1' >> /etc/crontab

service cron restart

## modify logrotate.sh to be not as aggressive and delete old log files.
echo 'Modify logrotate.sh to be not as aggressive and delete old log files.'

cp /usr/bin/logrotate.sh /usr/bin/logrotate.sh.old
sed -i '/sleep 5/ i #### ---- remove leftover logs in tmpfs /dev/shm and set logrotate to not as aggressive' /usr/bin/logrotate.sh 
sed -i '/sleep 5/ i rm /dev/shm/*.old > /dev/null' /usr/bin/logrotate.sh
sed -i '/sleep 5/ i rm /mnt/data/rockrobo/rrlog/*REL -R > /dev/null' /usr/bin/logrotate.sh
sed -i '/sleep 5/ i rm /mnt/data/rockrobo/rrlog/*.gz > /dev/null' /usr/bin/logrotate.sh
sed -i 's/sleep 5/sleep 60/gI' /usr/bin/logrotate.sh

service logrotate restart

echo 'Executing check_reboot script takes aprox. 1 min.'

/root/check_reboot

sleep 15

echo 'ALL DONE!'
echo 'Please check your robot for function'

