#!/bin/bash

#--------------------------------------------#
# psadmin-plus                               #
# https://github.com/psadmin-io/psadmin-plus #
#--------------------------------------------#

###########################
###  VARS
###########################
#PSCFGHOMES_DIR=
#PSCONFIGS_DIR=
title=psadmin-plus
host=$(hostname)
required_vars=( PSCFGHOMES_DIR PSCONFIGS_DIR )
set_editor

###########################
###  WEB
###########################
function web_status
{
    echoinfo "Webserver status"
	"$PS_HOME"/bin/psadmin -w status -d "$domain"
}

function web_start
{
    echoinfo "Starting webserver"
	"$PS_HOME"/bin/psadmin -w start -d "$domain"
}

function web_stop
{
  echoinfo "Stopping webserver"
  "$PS_HOME"/bin/psadmin -w shutdown -d "$domain"
}

function web_purge
{
  echoinfo "Purging webserver cache"
  rm -rfv "$PS_PIA_HOME/webserv/$domain/applications/peoplesoft/PORTAL*/*/cache"
}

function web_restart
{
    web_stop
    web_start
}

function web_bounce
{
    web_stop
    web_purge
    web_start
}

###########################
###  APP
###########################
function app_status
{
    "$PS_HOME"/bin/psadmin -c sstatus -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -c cstatus -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -c qstatus -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -c pslist -d "$domain" 2>&1
}

function app_start
{
   "$PS_HOME"/bin/psadmin -c boot -d "$domain" 2>&1
}

function app_stop
{
    "$PS_HOME"/bin/psadmin -c shutdown -d "$domain" 2>&1
}

function app_kill
{
    "$PS_HOME"/bin/psadmin -c shutdown! -d "$domain" 2>&1
}

function app_configure
{
    "$PS_HOME"/bin/psadmin -c configure -d "$domain" 2>&1
}

function app_purge
{
    "$PS_HOME"/bin/psadmin -c purge -d "$domain" 2>&1
    echo "$domain cache purged."
}

function app_flush
{
    "$PS_HOME"/bin/psadmin -c cleanipc -d "$domain" 2>&1
}

function app_restart
{
	"$PS_HOME"/bin/psadmin -c shutdown -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -c boot -d "$domain" 2>&1
}

function app_bounce
{
    "$PS_HOME"/bin/psadmin -c shutdown -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -c cleanipc -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -c purge -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -c configure -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -c boot -d "$domain" 2>&1
}

########################
### PRCS
########################
function prcs_status
{
    "$PS_HOME"/bin/psadmin -p status -d "$domain" 2>&1
}

function prcs_start
{
    "$PS_HOME"/bin/psadmin -p start -d "$domain" 2>&1
}

function prcs_stop
{
    "$PS_HOME"/bin/psadmin -p stop -d "$domain" 2>&1
}

function prcs_kill
{
    "$PS_HOME"/bin/psadmin -p kill -d "$domain" 2>&1
}

function prcs_configure
{
    "$PS_HOME"/bin/psadmin -p configure -d "$domain" 2>&1
}

function prcs_flush
{
    "$PS_HOME"/bin/psadmin -p cleanipc -d "$domain" 2>&1
}

function prcs_restart
{
    "$PS_HOME"/bin/psadmin -p stop -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -p start -d "$domain" 2>&1
}

function prcs_bounce
{
    "$PS_HOME"/bin/psadmin -p stop -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -p cleanipc -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -p configure -d "$domain" 2>&1
    "$PS_HOME"/bin/psadmin -p start -d "$domain" 2>&1
}

function prcs_compile
{
    if [[ -f $PS_HOME/setup/pscbl.mak ]]; then
      echoinfo "Recompiling COBOL"
      cd "$PS_HOME"/setup && ./pscbl.mak
      cd "$PS_HOME"/setup && ./pscbl.mak
    else
      echoerror "Could not find the file $PS_HOME/setup/pscbl.mak"
      exit 1
    fi
}

function prcs_link
{
    if [[ -f $PS_HOME/setup/psrun.mak ]]; then
      echoinfo "Linking COBOL"
      cd "$PS_HOME"/setup && ./psrun.mak
    else
      echoerror "Could not find the file $PS_HOME/setup/psrun.mak"
      exit 1
    fi
}

### OTHER
function set_editor
{	
	if [ -z "$EDITOR" ]; then
		EDITOR=vim
	fi
}

function validate_vars
{
	for var in ${required_vars[@]}; do
    		if [[ `printenv ${var}` = '' ]]; then
      			echo $(echo_color "${var} is not set.  Please make sure this is set before continuing." "red")
      			exit 1
    		fi
  	done
}

function is_web_cfg
{
	cfg=$1
	dir=$PSCFGHOMES_DIR/$cfg/webserv/
	if [ -d "$dir" ]; then
		subdircount=`find $dir -maxdepth 1 -type d | wc -l`
		if [ $subdircount -gt 1 ]; then  
			return 0 #true
		fi
	fi
	return 1 #false
}

# check if domain type exists
function check_web
{
    cfg=$1
	if is_web_cfg $cfg; then     
       	echo -n $(echo_color "w" "lred")
    else
		echo -n " "
    fi
}

function is_app_cfg
{
	cfg=$1
	dir=$PSCFGHOMES_DIR/$cfg/appserv/
	if [ -d "$dir" ]; then
		subdircount=`find $dir -maxdepth 1 -type d | wc -l`
		if [ $subdircount -gt 3 ]; then
			return 0 #true
		fi
	fi
	return 1 #false
}
function check_app
{
    cfg=$1
	if is_app_cfg $cfg; then
	    echo -n $(echo_color "a" "lblue")
	else
        echo -n " "
    fi
}

function is_prcs_cfg
{
	cfg=$1
	dir=$PSCFGHOMES_DIR/$cfg/appserv/prcs/
	if [ -d "$dir" ]; then
		subdircount=`find $dir -maxdepth 1 -type d | wc -l`
		if [ $subdircount -gt 1 ]; then  
			return 0 #true		
		fi
	fi
	return 1 #false
}

function check_prcs
{
    cfg=$1
	if is_prcs_cfg $cfg; then        
		echo -n $(echo_color "p" "lpurple")
	else
		echo -n " "
	fi
}

# display text in colors
function echo_color
{
	text=$1
	color=$2
	
	case $color in
		red) code="0;31m" ;;
		green) code="0;32m" ;;
		brown) code="0;33m" ;;
		blue) code="0;34m" ;;
		purple) code="0;35m" ;;
		cyan) code="0;36m" ;;
		gray) code="1;30m" ;;
		lred) code="1;31m" ;;
		lgreen) code="1;32m" ;;	
		yellow) code="1;33m" ;;
		lblue) code="1;34m" ;;
		lpurple) code="1;35m" ;;
		lcyan) code="1;36m" ;;
		lgray) code="0;37m" ;;
		*) code="0m" ;;
	esac

	echo -e "\e[$code$text\e[0m"
}

function set_cfgfile
{
	cfgtmp=$(echo ${cfgs[0]} | cut -d'-' -f1)
	cfgfile="psconfig.${cfgtmp}.sh"
}


function call_psadmin
{ 
	set_cfgfile
	clear
	cd $PSCONFIGS_DIR
	. ./$cfgfile
	psadmin
}

function call_psconfig
{
	set_cfgfile
    clear
    cd $PSCONFIGS_DIR
    $EDITOR $cfgfile
}

function print_header
{
	clear
	echo "+-------------------------------------------------+" 
	echo "| $(echo_color $title "lblue")   host: $(echo_color $host "lgreen") "	
	echo "|                cfgs: $(echo_color "${cfgs[*]}" "lgreen") "
	echo "|               modes: $(echo_color "${modes[*]}" "lgreen") "
	echo "+-------------------------------------------------+"
}

function print_menu_item
{
	item=$1
    	cfg=$2
	
	echo -n " $item - $cfg [" 
	check_web $cfg 
	check_app $cfg
	check_prcs $cfg
	echo "]"
}

function add_cfgs
{ 	
	echo todo
}

function remove_cfgs
{ 
	echo todo
}

function get_cfgs_all
{ 	
	cfgs=${#cfghomes[*]}
	# strip dups
	# cfgs=($(printf "%s\n" "${cfgs[@]}" | sort -u))
}

function get_cfgs_web
{ 
	for ((i=0; i<${#cfghomes[*]}; i++));
	do
		cfgtmp=${cfghomes[i]}
		if is_web_cfg $cfgtmp; then
			cfgs+=($cfgtmp)
		fi
	done
	# strip dups
	cfgs=($(printf "%s\n" "${cfgs[@]}" | sort -u))
}

function get_cfgs_app
{ 
	for ((i=0; i<${#cfghomes[*]}; i++));
	do
		cfgtmp=${cfghomes[i]}
		if is_app_cfg $cfgtmp; then
			cfgs+=($cfgtmp)
		fi
	done
	# strip dups	
	cfgs=($(printf "%s\n" "${cfgs[@]}" | sort -u))
}

function get_cfgs_prcs
{ 
	for ((i=0; i<${#cfghomes[*]}; i++));
	do
		cfgtmp=${cfghomes[i]}
		if is_prcs_cfg $cfgtmp; then
			cfgs+=($cfgtmp)
		fi
	done
	# strip dups
	cfgs=($(printf "%s\n" "${cfgs[@]}" | sort -u))	
}

function action_menu
{
    option=0

    until [ "$option" = "q" ]; do
	print_header

	echo " 1 - Status"
	echo " 2 - Start"
	echo " 3 - Stop"
	# not multi select?
	if [ ${#cfgs[@]} -eq 1 ]; then
		echo " 4 - psadmin"
		set_cfgfile
		echo " 5 - ${cfgfile}"
	fi
	echo "   - "
	echo " q - Quit"
	echo -e "\n"
	echo -n "Enter choice: "
	
	read option
	echo ""
	case $option in
		1 ) echo 'todo' ; press_enter;;
		2 ) echo 'todo' ; press_enter;;
		3 ) echo 'todo' ; press_enter;;
		4 ) call_psadmin; press_enter;;
		5 ) call_psconfig; press_enter;;
		q ) clear; main_menu ;;
		* ) echo "ya messed up, yo"; press_enter ;;
	esac
	done
}

function multi_menu 
{
    option=0

    until [ "$option" = "q" ]; do
	cfgs=() 	
	modes=()
    print_header

	echo " 1 - Select Domains"
	echo " 2 - All Domains"
	echo " 3 - Web Domains"
	echo " 4 - App Domains"
	echo " 5 - Prcs Domains"
	echo "   - "
	echo " q - Quit"
	echo -e "\n"
	echo -n "Enter choice: "
	
	read option
	echo ""
	case $option in
		1 ) cfgs=('todo'); modes=('todo'); action_menu; press_enter;;
		2 ) get_cfgs_web; get_cfgs_app; get_cfgs_prcs; modes=('web' 'app' 'prcs'); action_menu; press_enter;;
		3 ) get_cfgs_web; modes=('web'); action_menu; press_enter;;
		4 ) get_cfgs_app; modes=('app'); action_menu; press_enter;;
		5 ) get_cfgs_prcs; modes=('prcs'); action_menu; press_enter;;
		q ) clear; main_menu ;;
		* ) echo "ya messed up, yo"; press_enter ;;
	esac
	done
}

function main_menu 
{
	cd $PSCFGHOMES_DIR
    cfghomes=(*)
	
	option=0
	cfgs=() 
	modes=()
		
	until [ "$option" = "q" ]; do
	print_header
	echo " 0 - Multi" 
	for ((i=0; i<${#cfghomes[*]}; i++));
	do
		print_menu_item $((i+1)) ${cfghomes[i]}
	done

	echo "   - "
	echo " q - Quit"
	echo -e "\n"
	echo -n "Enter choice: "
	read option
	echo ""
	case $option in
		0 ) multi_menu; press_enter ;;
		q ) clear; exit ;;
		* ) cfgs=(${cfghomes[$((option-1))]}); modes=('web' 'app' 'prcs'); action_menu; press_enter ;;
	esac	
	done
}

# main
validate_vars
main_menu

