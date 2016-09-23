#!/usr/bin/env bash
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en
#===============================================================================
#
#          FILE: psadmin.sh
#
#   DESCRIPTION: passes the specified ps-appserver commands to the psadmin
#                executable
#
#===============================================================================

# Export the PMID in order to resolve an issue that Tuxedo has with long hostnames
PMID=$(hostname)
export PMID

action=$1
env=$2
domain=$3 # Optional

# If domain not passed, then set to env
if [ -z "$domain" ]; then
  domain=$env
fi  

required_environment_variables=( PS_HOME PS_CFG_HOME PS_APP_HOME PS_CUST_HOME TUXDIR ) #PS_PIA_HOME

function echoinfo() {
  local GC="\033[1;32m"
  local EC="\033[0m"
  printf "${GC} ?  INFO${EC}: %s\n" "$@";
}

function echoerror() {
  local RC="\033[1;31m"
  local EC="\033[0m"
  printf "${RC} ?  ERROR${EC}: %s\n" "$@" 1>&2;
}

function check_variables () {
  for var in ${required_environment_variables[@]}; do
    if [[ `printenv ${var}` = '' ]]; then
      echoerror "${var} is not set.  Please make sure this is set before continuing."
      exit 1
    fi
  done
}

function source_psconfig () {
  . /software/psconfigs/psconfig.$env.sh && cd - > /dev/null 2>&1
}

#######################
# Setup the environment
#######################
source_psconfig
check_variables

###########################
# Run the specified command
###########################

case $action in

  status)
    "$PS_HOME"/bin/psadmin -c sstatus -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -c cstatus -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -c qstatus -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -c pslist -d "$domain" 2>&1
  ;;

  start)
    "$PS_HOME"/bin/psadmin -c boot -d "$domain" 2>&1
  ;;

  stop)
    "$PS_HOME"/bin/psadmin -c shutdown -d "$domain" 2>&1
  ;;

  kill)
    "$PS_HOME"/bin/psadmin -c shutdown! -d "$domain" 2>&1
  ;;

  configure)
    "$PS_HOME"/bin/psadmin -c configure -d "$domain" 2>&1
  ;;

  purge)    
    "$PS_HOME"/bin/psadmin -c purge -d "$domain" 2>&1
    echo "$domain cache purged."
  ;;

  flush)
    "$PS_HOME"/bin/psadmin -c cleanipc -d "$domain" 2>&1
  ;;

  restart)
    "$PS_HOME"/bin/psadmin -c shutdown -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -c boot -d "$domain" 2>&1
  ;;

  bounce)
    "$PS_HOME"/bin/psadmin -c shutdown -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -c cleanipc -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -c purge -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -c configure -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -c boot -d "$domain" 2>&1
  ;;

esac