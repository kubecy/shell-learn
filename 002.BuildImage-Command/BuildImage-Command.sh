#!/bin/bash

## SCRIPT NAME: build-command.sh
## FUNCTION:    Automatically build a mirror image
## CREATE TIME: 2023/02/15
## PLATFORM:    Linux
## AUTHOR:      CHENYI

INFO="\e[32m[INFO] PASS:\e[0m"
WARN="\e[33m[WARN] NOTPASS:\e[0m"

# 设置镜像名称与镜像标签 镜像仓库用户与密码
#tagName="centos7-v01"
# 输入标签，并进行输入验证
while true; do
  read -p "Please enter the mirror label [eg: centos7-v1]: " tagName
  if [ -z "$tagName" ]; then
    echo -e "${WARN} Mirror label cannot be empty, please enter again."
  else
    break
  fi
done


imageName="registry.cn-guangzhou.aliyuncs.com/basicsystemimags/os:${tagName}-$(date +"%Y%m%d")"
registry="registry.cn-guangzhou.aliyuncs.com"
username="your username"
password="your password"

######################################################################################################
print_info() {
  printf "${INFO} $1\n"
}

print_warn() {
  printf "${WARN} $1\n"
}

# 检查是否存在该镜像
imageExists=$(docker images -q "${imageName}")
if [ -z "${imageExists}" ]; then
  print_info "${imageName} non-existent"
else
  print_warn "${imageName} existent"

  # 检查是否有容器在运行该镜像
  containsRunning=$(docker ps -q --filter "ancestor=${imageName}")
  if [ -z "${containsRunning}" ]; then
    print_info "No container is running this image. Delete mirror ${imageName}"
    docker rmi "${imageName}"
    if [ $? -eq 0 ]; then
      print_info "${imageName} Mirror deleted successfully"
    else
      print_warn "${imageName} Mirror deleted failed"
    fi
  else
    print_warn "${imageName} There is a container running this image, and it will not be deleted."
    exit 1
  fi
fi

####################################################################################################
# 构建镜像
# --no-cache 不使用缓存构建
if docker build --no-cache -t "${imageName}" .; then
  print_info "Mirror compilation succeeded."

  # 登录 Docker 仓库
  if echo ${password} | docker login --username=${username} --password-stdin ${registry}; then
    print_info "Mirror warehouse login succeeded."

    # 推送镜像
    if docker push "${imageName}"; then
      print_info "Image uploaded successfully."
    else
      print_warn "Image upload failed."
    fi
  else
    print_warn "Mirror warehouse login failed."
  fi
else
  print_warn "Mirror compilation failed."
fi
