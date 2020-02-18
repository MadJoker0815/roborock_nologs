# roborock_nologs
No reboots at 3am and no logfiles that fill up the disk.

These are the modified files on a Xiaomi Mi Vacuum Gen1. (will most likely work on a Gen2 (S5x) too)

The reason to include and modify these files is to not have nightly reboots, any logfiles what are filling up the memory and a healthy filesystem as much as possible.

The service Cron needs to be restarted after modifying "/etc/crontab". (use "service cron restart")

The times must depend on the system time. So if your robot is running at Shanghai time, it is more likely that it will reboot at a different time. Check the output of "uptime" and calculate back to the time of reboot. You have to place the timers around them. So if your reboot happens at 2am, the timer should be set at least 15 minutes before and 15 minutes after the restart. That is, 1:45am and 2:15am not the configured 2:00am to 4:00am.

Files in /root/ have to be executeable. (use "chmod +x /root/check_all;/root/check_reboot")

Also you should stop rrwatchdoge before editing the ProcessList.conf or ProcessListMT.conf. (use "service rrwatchdoge stop". To start it after modification use "service rrwatchdoge start")


For easy installation I added the "install.sh" script. This will make the modifications if needed.
Just copy the install.sh anywhere on your robot and run it with "sh install.sh".
Remember to check your regular reboot time and adjust the times in /etc/crontab after the executuion.

This script only runs on firmwares Gen1 < 4xxx and Gen2 < 2xxx. Please do not use it if you are running higher firmware versions.
