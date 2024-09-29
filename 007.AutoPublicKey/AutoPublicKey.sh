#!/bin/bash

## SCRIPT NAME: AutoPublicKey.sh
## FUNCTION:    Automatically create key pairs and issue public keys
## CREATE TIME: 2021/02/15
## PLATFORM:    RHEL CentOS Ubuntu
## AUTHOR:      CHENYI

export LANG=en_US
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
INFO="\e[32m[INFO] PASS:\e[0m"
WARN="\e[33m[WARN] NOTPASS:\e[0m"


#RHEL
SelectionOsRHEL() {
  ## 1.非交互式自动创建密钥对
  AutoCreateKeyPair(){
    [ -f /root/.ssh/id_rsa ] || ssh-keygen -t rsa -f /root/.ssh/id_rsa -P '' &> /dev/null ;IRC_T=$?
    if [ "${IRC_T}" = "0" ]; then
      printf "${INFO} AutoCreateKeyPair\n"
    else
      printf "${WARN} AutoCreateKeyPair\n"
    fi
  }
  AutoCreateKeyPair


  ## 2.检查sshpass是否安装
  InstallSshpass(){
    rpm  -qa | grep sshpass &> /dev/null ; IRC1_T=$?
    if [ "${IRC1_T}" = "0" ]; then
      printf "${INFO} InstallSshpass\n"
    else
      yum -y install sshpass &> /dev/null; IRC2_T=$?
      if [ "${IRC2_T}" = "0" ]; then
        printf "${INFO} InstallSshpass sshpass installing\n"
      else
        printf "${WARN} InstallSshpass\n"
      fi
    fi
  }
  InstallSshpass
  AutoDisPpublicKeys(){
    SERVER_LIST="servers.txt"

    # 初始化变量记录成功和失败情况
    SUCCESS_COUNT=0
    FAILURE_COUNT=0
    SUCCESS_IPS=()
    FAILURE_IPS=()

    # 读取服务器列表并尝试将公钥复制到服务器
    while IFS=, read -r HOST USER PASSWORD; do
      sshpass -p "$PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no $USER@$HOST &> /dev/null
      if [ $? -eq 0 ]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        SUCCESS_IPS+=("$HOST")
      else
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        FAILURE_IPS+=("$HOST")
      fi
    done < "$SERVER_LIST"

    # 打印结果表格[32m[INFO] PASS:\e[0m
    printf "\nAutoDisPpublicKeys Results:\n"
    printf "%-15s %-10s\n" "IP"  "Status"
    printf "%-15s %-10s\n" "--------------" "--------------"

    for ip in "${SUCCESS_IPS[@]}"; do
      printf "%-15s %-10s\n" "$ip" "SUCCESS"
    done

    for ip in "${FAILURE_IPS[@]}"; do
      printf "%-15s %-10s\n" "$ip" "FAILURE"
    done

    printf "\nSummary:\n"
    printf "\e[32m[ SUCCESS: $SUCCESS_COUNT ]\e[0m \e[31m[ FAILURE: $FAILURE_COUNT ]\e[0m\n"
  }

  AutoDisPpublicKeys
}



## Ubuntu
SelectionOsUbuntu() {

  ## 1.非交互式自动创建密钥对
  AutoCreateKeyPair(){
    [ -f /root/.ssh/id_rsa ] || ssh-keygen -t rsa -f /root/.ssh/id_rsa -P '' &> /dev/null ;IRC_T=$?
    if [ "${IRC_T}" = "0" ]; then
      printf "${INFO} AutoCreateKeyPair\n"
    else
      printf "${WARN} AutoCreateKeyPair\n"
    fi
  }
  AutoCreateKeyPair


  ## 2.检查sshpass是否安装
  InstallSshpass(){
    dpkg -l | grep sshpass &> /dev/null ; IRC1_T=$?
    if [ "${IRC1_T}" = "0" ]; then
      printf "${INFO} InstallSshpass\n"
    else
      apt -y install sshpass &> /dev/null; IRC2_T=$?
      if [ "${IRC2_T}" = "0" ]; then
        printf "${INFO} InstallSshpass sshpass installing\n"
      else
        printf "${WARN} InstallSshpass\n"
      fi
    fi
  }
  InstallSshpass


  AutoDisPpublicKeys(){
    SERVER_LIST="servers.txt"

    SUCCESS_COUNT=0
    FAILURE_COUNT=0
    SUCCESS_IPS=()
    FAILURE_IPS=()

    while IFS=, read -r HOST USER PASSWORD; do
      sshpass -p "$PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no $USER@$HOST &> /dev/null
      if [ $? -eq 0 ]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        SUCCESS_IPS+=("$HOST")
      else
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        FAILURE_IPS+=("$HOST")
      fi
    done < "$SERVER_LIST"

    printf "\nAutoDisPpublicKeys Results:\n"
    printf "%-15s %-10s\n" "IP" "Status"
    printf "%-15s %-10s\n" "--------------" "--------------"

    for ip in "${SUCCESS_IPS[@]}"; do
      printf "%-15s %-10s\n" "$ip" "SUCCESS"
    done

    for ip in "${FAILURE_IPS[@]}"; do
      printf "%-15s %-10s\n" "$ip" "FAILURE"
    done

    printf "\nSummary:\n"
    printf "\e[32m[ SUCCESS: $SUCCESS_COUNT ]\e[0m \e[31m[ FAILURE: $FAILURE_COUNT ]\e[0m\n"
  }

  AutoDisPpublicKeys
}



if [ -f /etc/os-release ]; then
    . /etc/os-release
    case $ID in
        ubuntu)
            echo "os Ubuntu";SelectionOsUbuntu
            ;;
        rhel | centos | fedora)
            echo "os RHEL";SelectionOsRHEL
            ;;
        *)
            echo "os Unknown"
            ;;
    esac
else
    echo "os Unknown"
fi
