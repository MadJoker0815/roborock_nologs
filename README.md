# roborock_nologs
No reboots at 3am and no logfiles that fill up the disk.

These are the modified files on a Xiaomi Mi Vacuum Gen1. (will most likely work on a Gen2 (S5x) too)

The reason to include and modify these files is to not have nightly reboots, any logfiles what are filling up the memory and a healthy filesystem as much as possible.

The service Cron needs to be restarted after modifying "/etc/crontab". (use "service cron restart")

The times for the restart need to be determend by the system time. So if your Robot is running on Shanghai time it is more likely to reboot at a different time. Check the output of "uptime" and calculate back to the reboot. You will need to place the timers around them. So if your reboot is at 2am system time the timer should be placed at least 15 min before and 15 min after the reboot time. Meaning 1:45am and 2:15.

Files in /root/ have to be executeable. (use "chmod +x /root/check_all;/root/check_reboot")

Also you should stop rrwatchdoge before editing the ProcessList.conf or ProcessListMT.conf. (use "service rrwatchdoge stop". To start it after modification use "service rrwatchdoge start")
