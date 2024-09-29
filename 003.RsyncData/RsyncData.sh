#!/bin/bash

INFO="\e[32m[INFO] \e[0m"
WARN="\e[33m[WARN] \e[0m"

print_info() {
    printf "${INFO} $1\n"
}
print_warn() {
    printf "${WARN} $1\n"
}

if [ $# -ne 1 ]; then
    print_warn "Usage: $0 Enter the file or directory to be synchronized"
    exit 1
elif [ ! -e "$1" ]; then
    print_warn "[ $1 ] Directory or file does not exist"
    exit 1
fi

## 获取绝对路径
Parentpath=$(dirname "$(realpath "$1")")

## 获取子路径
Subpath=$(realpath "$1")

## 目标主机
HOSTS=(
    "HOST01"
    "HOST02"
    "HOST03"
    "HOST04"
    "HOST05"
)

for HOST in "${HOSTS[@]}"
do
    ## 将输出变绿色
    tput setaf 2
    printf "====== Rsyncing ${HOST} ======\n"
    ## 恢复颜色

    tput setaf 7
    rsync -apz "${Subpath}" "$(whoami)"@"${HOST}":"${Parentpath}" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        print_info "Rsync to ${HOST} completed successfully!  targetPath: [ ${Subpath} ] \n"
    else
        print_warn "Rsync to ${HOST} failed! \n"
    fi
done
