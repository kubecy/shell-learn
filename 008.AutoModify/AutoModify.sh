#!/usr/bin/env bash

## SCRIPT NAME: AutoModify.sh
## FUNCTION:    Automatically Modify Content
## CREATE TIME: 2023/10/15
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


if [ "$#" -ne 4 ]; then
    print_warn "用法: $0 [目录绝对路径]  [筛选值]  [源值]  [目标值]."
    exit 1
fi


MODIFYFILE_PWD="$1"
FILTER_VALUE="$2"
SOUR_VALUE="$3"
DEST_VALUE="$4"
ALLFILE=($(find ${MODIFYFILE_PWD} -type f))
TOTAL_COUNT=${#ALLFILE[@]}  
S_FILETERED_COUNT=0
F_FILETERED_COUNT=0
COUNT=0

for FILE in "${ALLFILE[@]}"; do
    if grep -q "^${FILTER_VALUE}" ${FILE}; then
        ((COUNT++)) 
        #sed -i "s#^${SOUR_VALUE}#${DEST_VALUE}#g" ${FILE}
        sed -i "s#^\(readahead.*\)${SOUR_VALUE}#\1${DEST_VALUE}#" "${FILE}"
        #sed -i "s#^\(\readahead}.*\)${SOUR_VALUE}#\1${DEST_VALUE}#" "${FILE}"
        if [ $? -eq 0 ]; then
            ((S_FILETERED_COUNT++))
            SUCCESS_FILES+=("${FILE}")
        else
            ((F_FILETERED_COUNT++))
            FAIL_FILES+=("${FILE}") 
        fi
    fi
done


printf "%-15s %-10s\n" "----------------------------------------------------"
echo "在${MODIFYFILE_PWD}目录下含子目录下的文件一共有 ${TOTAL_COUNT} 个文件."
echo "通过以${FILTER_VALUE}开头筛选, 一共有 ${COUNT} 个文件满足需求."
printf "%-15s %-10s\n" "----------------------------------------------------"

echo "修改成功的文件数: ${S_FILETERED_COUNT}, 文件如下:"
for SUCCESS_FILE in "${SUCCESS_FILES[@]}"; do
    print_info "${SUCCESS_FILE}"
done

echo "修改失败的文件数: ${F_FILETERED_COUNT}, 文件如下:"
for FAIL_FILE in "${FAIL_FILES[@]}"; do
    print_warn "${FAIL_FILE}"
done
