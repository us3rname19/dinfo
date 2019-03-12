#!/bin/bash

export WHITE='\033[1;97m'
export CYAN='\033[0;36m'
export CYAN1='\033[1;36m'
export BLUE='\033[1;94m'
export GREEN='\033[1;92m'
export RED='\033[1;91m'
export RESETCOLOR='\033[1;00m'

#memory info
function memory() {
    mem_info=$(</proc/meminfo)
	mem_info=$(echo $(echo $(mem_info=${mem_info// /}; echo ${mem_info//kB/})))
	for m in $mem_info; do
		case ${m//:*} in
			"MemTotal") usedmem=$((usedmem+=${m//*:})); totalmem=${m//*:} ;;
			"ShMem") usedmem=$((usedmem+=${m//*:})) ;;
			"MemFree"|"Buffers"|"Cached"|"SReclaimable") usedmem=$((usedmem-=${m//*:})) ;;
			esac
		done
		usedmem=$((usedmem / 1024)) #Change 1000000 or 1024 to display in MB or Gib
		totalmem=$((totalmem / 1024)) #Change 1000000 or 1024 to display in MB or GiB

    mem="${usedmem}/${totalmem}MiB"
    echo $mem
}

# #cpu temp info
function cpu_temp() {
    thermal="/sys/class/hwmon/hwmon0/temp1_input"

    if [ -e $thermal ]; then
       temp=$(bc <<< "scale=1; $(cat $thermal)/1000")
    fi

    if [ -n "$temp" ]; then
       cpu="$cpu${temp}°C"
    fi

    echo "$cpu"
}

# #interface
function inter() {
    interface="$(ip -o route get to 8.8.8.8 | sed -n 's/.*dev \([a-z.0-9]\+\).*/\1/p')"
    echo $interface
}

# #ip info
function ip_info() {
    ip_menu="$(curl -s -m 10 ipinfo.io/ip)"
    co_menu="$(curl -s -m 10 ipinfo.io/country)"
    echo $ip_menu $co_menu
}

echo -e "$CYAN─$CYAN1━[Kernel: $BLUE` uname -or`
$CYAN─$CYAN1━[OS: $BLUE`cat /etc/lsb-release|awk -F'=' '{if ($2 < 10) print $2}'`
$CYAN─$CYAN1━[Hostname: $BLUE`hostname`
$CYAN─$CYAN1━[UID: $BLUE`id -u` - `whoami`

$CYAN─$CYAN1━[Interface: $BLUE$(inter)
$CYAN─$CYAN1━[MAC: $BLUE`macchanger -s $(inter)|grep 'Current MAC:'|awk -F' ' '{ print $3}'`
$CYAN─$CYAN1━[Local ip: $BLUE`ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'`
$CYAN─$CYAN1━[Public ip: $BLUE$(ip_info)

$CYAN─$CYAN1━[Location: $BLUE`pwd`
$CYAN─$CYAN1━[Shell: $BLUE`echo "$SHELL" | awk -F'/' '{print $NF}'` `echo $BASH_VERSION`
$CYAN─$CYAN1━[Packages: $BLUE`dpkg -l | grep -c '^ii'`

$CYAN─$CYAN1━[RAM: $BLUE$(memory)
$CYAN─$CYAN1━[CPU temp: $BLUE$(cpu_temp)
$CYAN────────────────────────────────────────────────
$CYAN1 Filesys        Size  Used Avail Use% Mounted on
$CYAN─────────       ────  ──── ───── ──── ──────────$BLUE
`df -h /dev/sd*|grep '/dev/sd*'`"
