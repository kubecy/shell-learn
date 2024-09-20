#!/usr/bin/env bash

#set -o nounset
#set -o errexit
INFO="\e[32m[INFO]:\e[0m"
WARN="\e[31m[WARN]:\e[0m"

print_info() {
  printf "${INFO} $1\n"
}
print_warn() {
  printf "${WARN} $1\n"
}

NowPwd=$(pwd)
if [ ! -e "$NowPwd/LinuxCheckLog" ]; then
    mkdir "${NowPwd}/LinuxCheckLog"
fi  # 修复了这里的 if 语句

LogDIR="${NowPwd}/LinuxCheckLog"
BakFile="${LogDIR}/sysinfo.$(date +%Y%m%d%H%M)"

BakSysInfoRHEL72() {
    echo "====================Kernel====================" >> "$BakFile"
    uname -nrs >> "$BakFile"
    echo "" >> "$BakFile"
    echo "====================NetworkIP====================" >> "$BakFile"
    ifconfig | grep -E -v 'RX|lo|TX|txqueuelen|MTU|inet6|Loopback|127.0.0.1' >> "$BakFile"
    echo "" >> "$BakFile"
    echo "====================route table====================" >> "$BakFile"
    netstat -rn | awk '{print $1, "\t",$2,"\t",$3}' >> "$BakFile"
    echo "" >> "$BakFile"
    cat /etc/sysconfig/static-routes >> "$BakFile"
    echo "" >> "$BakFile"
    echo "====================PV VG LV FS====================" >> "$BakFile"
    df -Ph | grep -v "/run/user" | awk '{print $1,"\t",$6}' >> "$BakFile"
    cat /etc/fstab >> "$BakFile"
    pvdisplay >> "$BakFile"
    vgdisplay >> "$BakFile"
    lvdisplay >> "$BakFile"
    cp /etc/fstab /etc/fstab.bak
    echo >> "$BakFile"
    echo "====================crontab====================" >> "$BakFile"
    find /var/spool/cron/. -type f -exec cat "{}" \; >> "$BakFile"
    echo "" >> "$BakFile"
    echo "====================/etc/hosts====================" >> "$BakFile"
    cat /etc/hosts >> "$BakFile"
    echo "" >> "$BakFile"
    echo "====================rc.local====================" >> "$BakFile"
    cat /etc/rc.d/rc.local >> "$BakFile"
    echo "" >> "$BakFile"
    echo "====================service-status====================" >> "$BakFile"
    systemctl list-unit-files | sort >> "$BakFile"
    echo "" >> $BakFile
    echo "====================Users====================" >> "$BakFile"
    cut -d: -f1 /etc/passwd >> "$BakFile"
    echo "" >> "$BakFile"
}

BakSysInfoRHEL() {
    echo "====================Kernel====================" >> "$BakFile"
    uname -nrs >> "$BakFile"
    echo "" >> "$BakFile"
    echo "====================NetworkIP====================" >> "$BakFile"
    ifconfig | grep -E -v 'RX|lo|TX|txqueuelen|MTU|inet6|Loopback|127.0.0.1' >> "$BakFile"
    echo "" >> "$BakFile"
    echo "====================route table====================" >> "$BakFile"
    netstat -rn | awk '{print $1, "\t",$2,"\t",$3}' >> "$BakFile"
    echo "" >> "$BakFile"
    cat /etc/sysconfig/static-routes >> "$BakFile"
    echo "" >> "$BakFile"
    echo "====================PV VG LV FS====================" >> "$BakFile"
    df -Ph | grep -v "/run/user" | awk '{print $1,"\t",$6}' >> "$BakFile"
    cat /etc/fstab >> "$BakFile"
    pvdisplay >> "$BakFile"
    vgdisplay >> "$BakFile"
    lvdisplay >> "$BakFile"
    cp /etc/fstab /etc/fstab.bak
    echo >> "$BakFile"
    echo "====================crontab====================" >> "$BakFile"
    find /var/spool/cron/. -type f -exec cat "{}" \; >> "$BakFile"
    echo "" >> "$BakFile"
    echo "====================/etc/hosts====================" >> "$BakFile"
    cat /etc/hosts >> "$BakFile"
    echo "" >> "$BakFile"
    echo "====================rc.local====================" >> "$BakFile"
    cat /etc/rc.d/rc.local >> "$BakFile"
    echo "" >> "$BakFile"
    echo "====================service-status====================" >> "$BakFile"
    systemctl list-unit-files | sort >> "$BakFile"
    echo "" >> $BakFile
    echo "====================Users====================" >> "$BakFile"
    cut -d: -f1 /etc/passwd >> "$BakFile"
    echo "" >> "$BakFile"
    echo "====================chkconfig list====================" >> "$BakFile"
    chkconfig --list >> $BakFile
    echo "" >> "$BakFile"
}

CheckSysInfoRHEL72() {
    ifconfig | grep -E -v 'RX|lo|TX|txqueuelen|MTU|inet6|Loopback|127.0.0.1' > ${LogDIR}/${1}_ipinfobak
    netstat -rn | awk '{print $1, "\t",$2,"\t",$3}' | sort > ${LogDIR}/${1}_routeinfobak
    df -Ph | grep -v "/run/user" | awk '{print $1,"\t",$6}' | sort > ${LogDIR}/${1}_fsinfobak
    systemctl list-unit-files | grep -v "session-" | grep -v "unit files listed" | sort > ${LogDIR}/${1}_serviceinfobak
}

CheckSysInfoRHEL() {
    ifconfig | grep -E -v 'RX|lo|TX|txqueuelen|MTU|inet6|Loopback|127.0.0.1' > ${LogDIR}/${1}_ipinfobak
    netstat -rn | awk '{print $1, "\t",$2,"\t",$3}' | sort > ${LogDIR}/${1}_routeinfobak
    df -Ph | grep -v "/run/user" | awk '{print $1,"\t",$6}' | sort > ${LogDIR}/${1}_fsinfobak
    systemctl list-unit-files | grep -v "session-" | grep -v "unit files listed" | sort > ${LogDIR}/${1}_serviceinfobak
}

Cama3start() {
    cd /home/cama3/cama-control/bin
    ./startcamaagent.sh
    cd -
}

Cama4start() {
    if [ -e /home/cama4/agent/release/bin ]; then
        echo "Starting Cama4......"
    else
        echo "Cama4 Not Install......"; return 0
    fi
    cd /home/cama4/agent/release/bin
    sh afastart > /dev/null
    sleep 5
    ps -ef | grep "cama4" | grep -v grep > /dev/null
    if [ $? -ne 0 ]; then
        echo "Cama4 start failed......"
    else
        echo "Cama4 is started......"
    fi
    cd - > /dev/null
}

EntegorAgentstart() {
    if [ -e /home/ideal/EntegorAgent ]; then
        echo "Starting EntegorAgent......"
    else
        echo "EntetgorAgent Not Install......"; return 0
    fi
    cd /home/ideal/EntegorAgent
    sh startAgent.sh > /dev/null
    ps -ef | grep "/home/ideal/EntegorAgent/jre/bin/java" | grerp -v grep > /dev/null
    if [ $? -ne 0 ]; then
        echo "EntegorAgent is start"
    else 
        echo "EntegorAgent is start"
    fi
    cd - /dev/null
}

CheckFileSystem(){
    cat /etc/fstab |grep mapper | egrep -v "swap|#" |awk '{print $1,$3,$2}'sort > t_fstab.txt
    df -PTh | grep mapper | awk '{print $1,$2,$7}' | sort > t_df_Ph.txt
    diff t_fstab.txt  t_df_Ph.txt 
    if [ $? -ne 0 ]; then
        echo "FileSystem Check Failed, Please Check the fstab file"
    else
        echo "Check Success, Now You Can reboot"
    fi
}

DBcheck() {
    if [ -z `cat /etc/redhat-release | grep "7." | awk '{print $1}'` ]; then
        DBcheck6
    else
        DBcheck7
    fi
}

DBcheck7() {
    cat /etc/autostart.sh | grep ifconfig | grep -v grep > /dev/null
    if [ $? -ne 0 ]; then
        exit 0
    fi
    echo ""
    print_warn "====================warnning===================="
    print_warn "This is a database server"
    echo ""
    cat /etc/autostart.sh | grep ifconfig | grep ^"#" | grep -v grep  /dev/null
    if [ $? -ne 0 ]; then
        print_warn "This is primary node"
    else
        print_warn "This is backup node"
    fi
    echo ""
    print_warn "Check flow IP"
    print_warn "====================warnning===================="
}

DBcheck6() {
    cat /etc/rc.d/rc.local | grep ifconfig | grep -v grep > /dev/null
    if [ $? -ne 0 ]; then
        exit 0
    fi
    echo ""
    print_warn "====================warnning===================="
    print_warn "This is a database server"
    echo ""

    cat /etc/rc.d/rc.local | grep ifconfig | grep ^"#" | grep -v grep > /dev/null
    if [ $? -ne 0 ]; then
        print_warn "This is primary node"
    else
        print_warn "This is backup node"
    fi
    echo ""
    print_warn "Check flow IP"
    print_warn "====================warnning===================="
}

before() {
    export LANG=en_US.UTF-8
    if [ -e /etc/redhat-release ]; then
        echo "Start backup information before reboot"
    else
        echo "Not redhat"; return 0
    fi
    
    if [ -z `cat /etc/redhat-release | grep "7." | awk '{print $1}'` ]; then
        BakSysInfoRHEL
        CheckSysInfoRHEL old
    else
        BakSysInfoRHEL72
        CheckSysInfoRHEL72 old
   fi
   echo "Backup complete! You can check it in this file"; ls ${BakFile}
   echo ""
   echo "Now check the filesystem between fstab and df -h"
   CheckFileSystem    
}

after() {
   clear
   export LANG=en_US.UTF-8
   if [ -e /etc/redhat-release ]; then
       echo "Start verify information"
   else
       echo "Not redhat"; return 0
   fi
   
   backupOK=`find ${LogDIR}/. -ctime -1 -type f -print | grep old | awk 'NR==1 {print $1}'`
   if [ -z $backupOK ]; then
       echo "Not find backup file"; return 0
   fi

   if [ -z `cat /etc/redhat-release | grep "7." | awk '{print $1}'` ]; then
       CheckSysInfoRHEL new
   else
      CheckSysInfoRHEL72 new
   fi
 
   verifylog=${LogDIR}/verifyinfolog
   echo "" >> ${verifylog}
   echo "====================verifylog.$(date +%Y%m%d%H%M)====================" >> ${verifylog}
   echo "[1] IP verifying" | tee -a ${verifylog}
   diff -w $LogDIR/old_ipinfobak $LogDIR/new_ipinfobak >> ${verifylog}
   diff -w $LogDIR/old_ipinfobak $LogDIR/new_ipinfobak
   if [ $? -ne 0 ]; then
       echo "[error] IP information verify failed. Please check the file named ifcfg-ethX !"
   else
       echo  "IP verify success!"
   fi

   echo "" |tee -a ${verifylog}
   echo "[2] Route verifying .." |tee -a ${verifylog}
   diff -w $LogDIR/old_routeinfobak $LogDIR/new_routeinfobak >> ${verifylog}
   diff -w $LogDIR/old_routeinfobak $LogDIR/new_routeinfobak
   if [ $? -ne 0 ]; then
       echo "[error] Route information verify failed. Please check the file named static-routes and ifcfg-ethX!"
   else
       echo "Route verify success!"
   fi
   echo "" |tee -a ${verifylog}

   echo  "[3] Filesystem verifying ." | tee -a  ${verifylog}
   diff -w $LogDIR/old_fsinfobak $LogDIR/new_fsinfobak >> ${verifylog}
   diff -w $LogDIR/old_fsinfobak $LogDIR/new_fsinfobak
   if [ $? -ne 0 ]; then
       echo  "[error] Filesystem information verify failed. Please check the file named fstab and rc.local!"
   else
       echo "Filesystem verify success!"
   fi
   echo "" |tee -a ${verifylog}
   echo "[4] Service verifying…."|tee -a  ${verifylog}
   diff -w $LogDIR/old_serviceinfobak $LogDIR/new_serviceinfobak >> ${verifylog}
   diff -w $LogDIR/old_serviceinfobak $LogDIR/new_serviceinfobak
   if [ $? -ne 0 ]; then
       echo "[error] Services verify failed. Please check started configuration!"
   else
       echo "Service verify success!"
   fi
   echo "" | tee -a  ${verifylog}
   echo "Verify Complete! You can check the verify log in this file!"ls $LogDIR/verifyinfolog
   echo "" |tee -a $verifylog
   echo "[cama]Now check cama4.." | tee -a $verifylog
   ps -ef | grep "cama4"|grep -v grep >/dev/null
   if [ $? -ne 0 ]; then 
        echo "Cama4 not start,starting"
        cama4start
   else
        echo "Cama4 is running!"
   fi
   echo "" |tee -a $verifylog
   echo "[EntegorAgent]Now check EntegorAgent....." | tee -a  $verifylog
   ps -ef | grep "/home/ideal/EntegorAgent/jre/bin/java" | grep -v grep > /dev/null
   if [ $? -ne 0 ]; then 
        echo "EntegorAgent not start,starting"
        EntegorAgentstart
   else 
        echo "EntegorAgentstart is running!"
   fi
   DBcheck
}

if [ "$1" == "before" ]; then
   before
elif [ "$1" == "after" ]; then
   after
else
   echo "Usage: $0 [ before | after ]"

   exit 1
fi
























