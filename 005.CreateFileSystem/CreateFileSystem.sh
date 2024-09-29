#! /bin/bash

## CREATE TIME: 2024/07/19
## SCRIPT NAME: CreateFileSystem.sh
## FUNCTION:    Server Type D, BDS, PDF Create File System

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




#### help
function usage() {
    echo -e "\033[33mUsage:\033[0m CreateFileSystem option"
    cat <<EOF
-------------------------------------------------------------------------------------
Option setups:
    setup  <type>     server type D, BDS, PDF ......



EOF
}

####
function help-info() {
    case "$1" in
        setup)
            usage-setup
            ;;
        *)
            usage
            ;;
    esac
}

####
function usage-setup(){
  echo -e "\033[33mUsage:\033[0m CreateFileSystem CreateFileSystem <type> <args>"
  cat <<EOF
Option type:
    BDS
    PDF
    D

-------------------------------------------------------------------------------------
Available args:
    01  BDS--01
    02  BDS--02 
    03  BDS--03
    04  BDS--04 

    01  PDF--01  
    02  PDF--02   
    03  PDF--03 

    01  D----01    
    02  D----02     
    03  D----03      
    04  D----04        

EOF
}

##-------------------------------------- SERVER CONFIGURATION START--------------------------------------

###################################### BDS TYPE CONFIGURATION ######################################

## BDS type 12-block straight-through disk UUID mount
function BDS-apiserver() {
   #eg: /dev/sdb /dev/sdc ...... /dev/sdn /dev/sdm 
   disk_array=(/dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg)

   #eg: /data01 /data02   ...... /data11 /data12
   mount_array=(/data01 /data02 /data03 /data04 /data05)

   for ((i=0; i<${#disk_array[@]}; i++)); do
       disk_path="${disk_array[i]}"
       mount_point="${mount_array[i]}"

       mkdir -p "$mount_point" && mkfs.xfs  -f $disk_path &> /dev/null

       if [[ $? == 0 ]]; then
           print_info "disk: $disk_path Formatted to xfs file system Successfully" &> /dev/null
       else
           print_warn "disk: $disk_path Failed for xfs file system"
           continue
       fi

       mount -t  xfs "$disk_path"  "$mount_point"
       if [[ $? == 0 ]]; then
           print_info "disk: $disk_path Successfully mounted to $mount_point" &> /dev/null
           disk_uuid=$(blkid -s UUID -o value $disk_path)
           echo "UUID=$disk_uuid  $mount_point  xfs  defaults  0 0"  >>  /etc/fstab
       else
           print_warn "mount disk: $disk_path to $mount_point fail"
       fi
   done
   echo "---------------------------------------------------------------------"
   for ((i=0; i<${#mount_array[@]}; i++)); do
       disk_path="${disk_array[i]}"
       mount_point="${mount_array[i]}"
       if mountpoint -q $mount_point; then
           print_info "disk: $disk_path successfully mounted to $mount_point"
       else
           print_warn "disk: $disk_path not mounted to $mount_point"
       fi
   done  
}

## BDS 01
function BDS01() {
    BDS-apiserver
    ##.....
}

##BDS 02
function BDS02() {
    BDS-apiserver
    ##.....
}

## BDS 03
function BDS03() {
    BDS-apiserver
    ##.....
}


###################################### PDF TYPE CONFIGURATION ######################################
## PDF 01
function PDF01() {
    echo "setting up PDF01"
    ##.....
}
## PDF 02
function PDF02() {
    echo "setting up PDF02"
    ##.....
}

###################################### D TYPE CONFIGURATION ######################################
## D 01
function D01() {
    echo "setting up D01"
    ##.....
}
## D 02
function D02() {
    echo "setting up D02"
    ##.....
}
##-------------------------------------- SERVER CONFIGURATION END --------------------------------------
function setup() {
   local func="$1$2"

   declare -A valid_types=(
       [BDS01]=BDS01
       [BDS02]=BDS02
       [BDS03]=BDS03
       [PDF01]=PDF01
       [PDF02]=PDF02
       [PDF03]=PDF03
       [D01]=D01
       [D02]=D02
       [D03]=D03
   )

   if [[ -n "${valid_types[$func]}" ]]; then
       ${valid_types[$func]}
   else
       print_warn "Unknown $1 subtype: $2"
       usage-setup
   fi
}

### Main Lines ##################################################
function main() {
  [[ "$#" -eq 0 ]] && { usage >&2; exit 1; }
  case "$1" in
      ### cluster-wide operations #######################
      (setup)
          [ "$#" -ge 3 ] || { usage-setup >&2; exit 2; }
          setup "${@:2}"
          #setup "$@"
          ;;
      (*)
          usage
          exit 0
          ;;
  esac
 }

main "$@" 
