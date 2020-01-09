# roborock_nologs
No reboots at 3am and no logfiles that fill up the disk.

These are the actual files on a Xiaomi Mi Vacuum Gen1. (will most likely work on a Gen2 (S5x) too)

The reason to include and modify these files is to not have nightly reboots, any logfiles what are filling up the memory and a healthy filesystem as much as possible.

The service Cron needs to be restarted after modifying "/etc/crontab". (use "service cron restart")
Files in /root/ have to be executeable. (use "chmod +x /root/check_all;/root/check_reboot")

Also you should stop rrwatchdoge before editing the ProcessList.conf or ProcessListMT.conf. (use "service rrwatchdoge stop". To tart it after modification use "service rrwatchdoge start")
