#!/bin/bash

isneedrotate()
{
        syslogl=0
        kernlogl=0

        if  [ -f /var/log/syslog ]
        then
                syslogl=`ls -lrt /var/log/syslog | cut -d " " -f 5`
        fi

        if [ -f /var/log/kern.log ]
        then
                kernlogl=`ls -lrt /var/log/kern.log | cut -d " " -f 5`
        fi

        if [ $syslogl -ge 5242880 -o $kernlogl -ge 5242880 ]
        then
                return 1
        fi

        return 0
}

isupstartrotate()
{
        msize=0

        for mfile in `ls /var/log/upstart/`
        do
                msize=`ls -lrt /var/log/upstart/$mfile | cut -d " " -f 5`
                if [ $msize -ge 1048576 ]
                then
                        return 1
                fi
        done

        return 0
}

while true
do
        isneedrotate
        if [ $? -eq 1 ]
        then
                cd /var/lib/logrotate
                test -e status || touch status
                head -1 status > status.clean
                sed 's/"//g' status | while read logfile date
                do
                                [ -e "$logfile" ] && echo "\"$logfile\" $date"
                done >> status.clean
                mv status.clean status

                test -x /usr/sbin/logrotate || exit 0
                /usr/sbin/logrotate /etc/logrotate.conf
        fi

        isupstartrotate
        if [ $? -eq 1 ]
        then
                test -x /usr/sbin/logrotate || exit 0
                /usr/sbin/logrotate -f /etc/logrotate.d/upstart
        fi

#### ---- remove leftover logs in tmpfs /dev/shm and set logrotate to not as aggressive
        rm /dev/shm/*.old > /dev/null
        rm /dev/shm/*.log > /dev/null
        sleep 60
done
