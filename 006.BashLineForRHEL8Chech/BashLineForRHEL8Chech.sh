#!/bin/bash

## SCRIPT NAME: BashLineForRHEL8Check8.sh
## FUNCTION:    BASE LINW CHECK FOR RHEL8
## CREATE TIME: 2022/02/15
## PLATFORM:    Linux
## AUTHOR:      CHENYI

export LANG=en_US
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
INFO="\e[32m[INFO] PASS:\e[0m"
WARN="\e[33m[WARN] NOTPASS:\e[0m"

## 1.查看/etc/shadow /etc/group /etc/gshadow /etc/passwd的默认权限
CheUsePermissionFileRHEL8() {
  typeset sFileName_L="/etc/group@-rw-r--r--rootroot /etc/gshadow@----------rootroot /etc/passwd@-rw-r--r--rootroot /etc/shadow@----------rootroot"
  sResult=""
  for fileperm in ${sFileName_L};do
    file=$(echo ${fileperm} | awk -F @ '{print $1}')
    perm=$(echo ${fileperm} | awk -F @ '{print $2}')

    tperm=$(ls -l ${file} | awk '{print $1$3$4}' | sed 's@\.@@g')
    if [ ${perm} != ${tperm} ];then
      sResult="${sResult} ${file} ${tperm}"
    fi
    done

    if [ -z "${sResult}" ]; then
      printf "${INFO} CheUsePermissionFileRHEL8\n"
    else
      printf "${WARN} CheUsePermissionFileRHEL8 ${sResult}\n"
    fi 
}
CheUsePermissionFileRHEL8


## 2.查看/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin执行权限
CheUsePermissionDirRHEL8() {
  typeset sFileName_L="/bin@lrwxrwxrwxrootroot /sbin@lrwxrwxrwxrootroot /usr/bin/@dr-xr-xr-xrootroot /usr/libexec/@drwxr-xr-xrootroot /usr/local/bin/@drwxr-xr-xrootroot /usr/local/sbin/@drwxr-xr-xrootroot /usr/sbin/@dr-xr-xr-xrootroot"
  sResult=""
  for fileperm in ${sFileName_L};do
    file=$(echo ${fileperm} | awk -F @ '{print $1}')
    perm=$(echo ${fileperm} | awk -F @ '{print $2}')

    tperm=$(ls -ld ${file} | awk '{print $1$3$4}' | sed 's@\.@@g')
    if [ ${perm} != ${tperm} ];then
      sResult="${sResult} ${file} ${tperm}"
    fi
    done

    if [ -z "${sResult}" ]; then
      printf "${INFO} CheUsePermissionDirRHEL8  \n"
    else
      printf "${WARN} CheUsePermissionDirRHEL8 ${sResult}\n"
    fi
}
CheUsePermissionDirRHEL8


## 3.时钟服务器配置指向
CheChronydConfRHEL8() {
  local Ntp_serverName="cgbchina.com.cn|10.4.0.110"
  sResult1=$(cat /etc/chrony.conf /etc/ntp.conf  2> /dev/null | grep ^server | grep -E "${Ntp_serverName}" | xargs)
  sResult2=$(cat /etc/chrony.conf /etc/ntp.conf  2> /dev/null | grep ^server | xargs)
  if [ "${sResult1}" = "" ]; then
    printf "${WARN} CheChronydConfRHEL8 ${Ntp_serverName}\n"
  else
    printf "${INFO} CheChronydConfRHEL8\n"
  fi
}
CheChronydConfRHEL8


## 4.关闭SELinux设置
CheSElinuxRHEL8() {
  typeset sSElinuxStatus_L=$(cat /etc/selinux/config | grep -v "^#" | grep "SELINUX=")
  cat /etc/selinux/config | grep -v "^#" | grep -q "SELINUX=enforcing";iRC_T=$?
  if [ "${iRC_T}" = "0" ]; then
    printf "${INFO} CheSElinuxRHEL8\n"
  else
     printf "${WARN} CheSElinuxRHEL8 ${sSElinuxStatus_L}\n"
  fi
}
CheSElinuxRHEL8


## 5.检查服务是否运行与开机自启动
CheServiceStatrUpRHEL8() {
  local services=("postfix" "firewalld" "chronyd.service")

  local running_services=()
  local enabled_services=()

  for service in "${services[@]}"; do
    if systemctl is-active "${service}" &>/dev/null; then
      running_services+=("${service}")
    fi
  done

  for service in "${services[@]}"; do
    if systemctl is-enabled "${service}" &>/dev/null; then
      enabled_services+=("${service}")
    fi
  done

  if [ "${#running_services[@]}" -eq "${#services[@]}" ] && \
     [ "${#enabled_services[@]}" -eq "${#services[@]}" ]; then
    printf "${INFO} CheStatrUpRHEL8\n"
  else
    local not_running_services=()
    local not_enabled_services=()

    for service in "${services[@]}"; do
      if ! systemctl is-active "${service}" &>/dev/null; then
        not_running_services+=("${service}")
      fi
      if ! systemctl is-enabled "${service}" &>/dev/null; then
        not_enabled_services+=("${service}")
      fi
    done

    printf "${WARN} CheStatrUpRHEL8 ${not_running_services[*]} is not running, ${not_enabled_services[*]} is not enabled\n"
  fi
}
CheServiceStatrUpRHEL8
