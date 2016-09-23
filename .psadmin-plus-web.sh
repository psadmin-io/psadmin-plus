#!/usr/bin/env bash
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en
#===============================================================================
#
#          FILE: pia.sh
#
#   DESCRIPTION: executes commands to control the pia
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
  echoinfo "Checking variables"
  for var in ${required_environment_variables[@]}; do
    if [[ `printenv ${var}` = '' ]]; then
      echo "${var} is not set.  Please make sure this is set before continuing."
      exit 1
    fi
  done
}

function source_psconfig () {
  . /software/psconfigs/psconfig.$env.sh && cd - > /dev/null 2>&1
}

function start_webserver () {
  echoinfo "Starting webserver"
  "$PS_HOME"/bin/psadmin -w start -d "$domain"
}

function stop_webserver () {
  echoinfo "Stopping webserver"
  "$PS_HOME"/bin/psadmin -w shutdown -d "$domain"
}

function show_webserver_status () {
  echoinfo "Webserver status"
  "$PS_HOME"/bin/psadmin -w status -d "$domain"
}

function purge_webserver_cache () {
  echoinfo "Purging webserver cache"
  rm -rfv "$PS_PIA_HOME/webserv/$domain/applications/peoplesoft/PORTAL*/*/cache"
}

#######################
# Setup the environment
#######################
source_psconfig
check_variables

case $action in

  status)
    show_webserver_status
  ;;

  start)
    start_webserver
  ;;

  stop)
    stop_webserver
  ;;

  purge)
    purge_webserver_cache
  ;;

  restart)
    stop_webserver
    start_webserver
  ;;

  bounce)
    stop_webserver
    purge_webserver_cache
    start_webserver
  ;;

esac
