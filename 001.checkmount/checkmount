#!/usr/bin/env bash

## SCRIPT NAME: checkmount
## FUNCTION:    NFS mount automatic check
## CREATE TIME: 2023/11/15
## PLATFORM:    Linux
## AUTHOR:      CHENYI


INFO="\e[32m[INFO]:\e[0m"
WARN="\e[33m[WARN]:\e[0m"
print_info() {
  printf "${INFO} %s\n" "$1"
}
print_warn() {
  printf "${WARN} %s\n" "$1"
}

if [ $# -eq 0 ]; then
    print_warn "用法：checkmount [ mount_command ]"
    #print_warn "mount_command: 原先的挂载命令"
    print_warn "示例：checkmount mount -t nfs -o actimeo=3,vers=3 192.168.1.38:/redhat8.5 /nas/iso"   
    exit 1
fi

## 挂载命令
MOUNT_CMD="$*"

## 从挂载命令中提取挂载路径
MOUNT_POINT=$(echo "$MOUNT_CMD" | awk '{print $NF}')

## 定义日志变量
NFS_SHARE=$(echo "$MOUNT_CMD" | awk '{print $(NF-1)}')
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
UPTIME=$(uptime -p)
IP_ADDRESSES=$(ip addr show | grep -oP '(?<=inet) [\d.]+' | grep -v '^127\.')
NFS_MOUNT_RECORD="/var/log/nfs_mount_record.log"
tail -n 150 "$NFS_MOUNT_RECORD" > /tmp/nlogtmp.tmp && mv /tmp/nlogtmp.tmp "$NFS_MOUNT_RECORD"


## 前置检查函数
check_mount() {
    MOUNT_CMD_CHK=$(echo "$MOUNT_CMD" | awk '{print $1}')
    if [ "$MOUNT_CMD_CHK" != "mount" ]; then
        print_warn "错误: 使用的是不挂载命令，请不带参数执行 checkmount 查看示例"
        echo "NFS_MOUNT_FALL|$TIMESTAMP|$UPTIME|$(hostname)|$IP_ADDRESSES|$NFS_SHARE|$MOUNT_POINT|Err-CMD" >> "$NFS_MOUNT_RECORD"
        return 1
        
    fi
    if [[ "$MOUNT_POINT" == */ ]]; then
        print_warn "错误: 请检查挂载点字符串，勿以 '/' 结尾, 挂载终止 "
        echo "NFS_MOUNT_FALL|$TIMESTAMP|$UPTIME|$(hostname)|$IP_ADDRESSES|$NFS_SHARE|$MOUNT_POINT|Err-CMD" >> "$NFS_MOUNT_RECORD"
        return 1
    fi
    MOUNTED=$(mount | awk '{print $3}' | grep "^${MOUNT_POINT}$")
    if [ -n "$MOUNTED" ]; then
        print_warn "错误: 挂载点 ${MOUNT_POINT} 已存在挂载内容"
        echo "NFS_MOUNT_FALL|$TIMESTAMP|$UPTIME|$(hostname)|$IP_ADDRESSES|$NFS_SHARE|$MOUNT_POINT|Err-MOUNTED" >> "$NFS_MOUNT_RECORD"
        return 1
    fi

    PARENT_MOUNT=$(mount | awk '{print $3}' | grep -F "$MOUNT_POINT/")
    if [ -n "$PARENT_MOUNT" ]; then
        print_warn "错误: 存在嵌套挂载在 ${MOUNT_POINT} 路径下"
        echo "NFS_MOUNT_FALL|$TIMESTAMP|$UPTIME|$(hostname)|$IP_ADDRESSES|$NFS_SHARE|$MOUNT_POINT|Err-PARENT" >> "$NFS_MOUNT_RECORD"
        return 1
    fi
    return 0
}

check_mount


if [ $? -eq 0 ]; then
    ## 检查挂载命令中是否包含：号，用于判断是否为NFS挂载
    if echo "$MOUNT_CMD" | grep -q ":"; then

 
        ## 提取NFS服务器地址
        NFS_SERVER=$(echo "$MOUNT_CMD" | awk -F ':' '{print $1}' | awk '{print $NF}')


        ## 执行showmount 命令进行检查
        #print_info "检查rpc的连通性"
        SHOWMOUNT_OUTPUT=$(showmount -e "$NFS_SERVER")
        if [ $? -ne 0 ]; then
            print_warn "错误: 无法连接到NFS服务器$NFS_SERVER 或 权限不足"
            echo "NFS_MOUNT_FALL|$TIMESTAMP|$UPTIME|$(hostname)|$IP_ADDRESSES|$NFS_SHARE|$MOUNT_POINT|Err-RPC" >> "$NFS_MOUNT_RECORD"
            exit 1
        else 
            print_info "检查rpc的连通性"
        fi
    fi

    # 执行挂载操作
    $MOUNT_CMD

    ## 根据挂载命令输出日志并显示对应的信息
    MOUNT_RET=$?
    MOUNT_INFO=$(df -Th | grep "$MOUNT_POINT")
    MOUNTED=$(df -Th | grep "$MOUNT_POINT" | awk '{print $NF}')
    if [ -n "$MOUNTED" ] && [ $MOUNT_RET -eq 0 ]; then
        print_info "挂载成功"
        echo "NFS_MOUNT_SUCCESS|$TIMESTAMP|$UPTIME|$(hostname)|$IP_ADDRESSES|$NFS_SHARE|$MOUNT_POINT|Success" >> "$NFS_MOUNT_RECORD"
        print_info "挂载情况：$MOUNT_INFO"

        ## 将挂载写入开机自启脚本
        WATCHTXT=$(echo "checkmount $MOUNT_CMD")
        if ! grep -Fxq "$WATCHTXT" /etc/autostart.sh; then
            echo "$WATCHTXT" >> /etc/autostart.sh
            print_info "已将挂载写入开机自启脚本"
        else
            print_warn "自启动脚本已存在挂载点，未写入启动脚本"
        fi
    else
        ERROR_MESSAGE=$($MOUNT_CMD 2>&1)
        echo "NFS_MOUNT_FALL|$TIMESTAMP|$UPTIME|$(hostname)|$IP_ADDRESSES|$NFS_SHARE|$MOUNT_POINT|Err-MESSAGE" >> "$NFS_MOUNT_RECORD"
        print_warn "命令错误, 请检查"
        exit 1
    fi
else
    print_warn "由于上述错误，挂载命令未执行"
fi
