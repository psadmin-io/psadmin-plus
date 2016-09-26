#!/bin/bash

#--------------------------------------------#
# psadmin-plus                               #
# https://github.com/psadmin-io/psadmin-plus #
#--------------------------------------------#

##########################
# Actions
##########################

function action_app
{
	case $act in

	  status)
		"$PS_HOME"/bin/psadmin -c sstatus -d "$dom" 2>&1
		"$PS_HOME"/bin/psadmin -c cstatus -d "$dom" 2>&1
		"$PS_HOME"/bin/psadmin -c qstatus -d "$dom" 2>&1
		"$PS_HOME"/bin/psadmin -c pslist -d "$dom" 2>&1
	  ;;

	  start)
		"$PS_HOME"/bin/psadmin -c boot -d "$dom" 2>&1
	  ;;

	  stop)
		"$PS_HOME"/bin/psadmin -c shutdown -d "$dom" 2>&1
	  ;;

	  kill)
		"$PS_HOME"/bin/psadmin -c shutdown! -d "$dom" 2>&1
	  ;;

	  configure)
		"$PS_HOME"/bin/psadmin -c configure -d "$dom" 2>&1
	  ;;

	  purge)    
		"$PS_HOME"/bin/psadmin -c purge -d "$dom" 2>&1
		echo "$domain cache purged."
	  ;;

	  flush)
		"$PS_HOME"/bin/psadmin -c cleanipc -d "$dom" 2>&1
	  ;;

	  restart)
		"$PS_HOME"/bin/psadmin -c shutdown -d "$dom" 2>&1
		"$PS_HOME"/bin/psadmin -c boot -d "$dom" 2>&1
	  ;;

	  bounce)
		"$PS_HOME"/bin/psadmin -c shutdown -d "$dom" 2>&1
		"$PS_HOME"/bin/psadmin -c cleanipc -d "$dom" 2>&1
		"$PS_HOME"/bin/psadmin -c purge -d "$dom" 2>&1
		"$PS_HOME"/bin/psadmin -c configure -d "$dom" 2>&1
		"$PS_HOME"/bin/psadmin -c boot -d "$dom" 2>&1
	  ;;

	esac
}

function action_prcs
{
	case $act in

	  status)
		"$PS_HOME"/bin/psadmin -p status -d "$dom" 2>&1
	  ;;

	  start)
		"$PS_HOME"/bin/psadmin -p start -d "$dom" 2>&1
	  ;;

	  stop)
		"$PS_HOME"/bin/psadmin -p stop -d "$dom" 2>&1
	  ;;

	  kill)
		"$PS_HOME"/bin/psadmin -p kill -d "$dom" 2>&1
	  ;;

	  configure)
		"$PS_HOME"/bin/psadmin -p configure -d "$dom" 2>&1
	  ;;

	  flush)
		"$PS_HOME"/bin/psadmin -p cleanipc -d "$dom" 2>&1
	  ;;

	  restart)
		"$PS_HOME"/bin/psadmin -p stop -d "$dom" 2>&1
		"$PS_HOME"/bin/psadmin -p start -d "$dom" 2>&1
	  ;;

	  bounce)
		"$PS_HOME"/bin/psadmin -p stop -d "$dom" 2>&1
		"$PS_HOME"/bin/psadmin -p cleanipc -d "$dom" 2>&1
		"$PS_HOME"/bin/psadmin -p configure -d "$dom" 2>&1
		"$PS_HOME"/bin/psadmin -p start -d "$dom" 2>&1
	  ;;

	#  compile)
	#    if [[ -f $PS_HOME/setup/pscbl.mak ]]; then
	#      echo "Recompiling COBOL"
	#      cd "$PS_HOME"/setup && ./pscbl.mak
	#      cd "$PS_HOME"/setup && ./pscbl.mak
	#    else
	#      echoerror "Could not find the file $PS_HOME/setup/pscbl.mak"
	#      exit 1
	#    fi
	#  ;;

	#  link)
	#    if [[ -f $PS_HOME/setup/psrun.mak ]]; then
	#      echo "Linking COBOL"
	#      cd "$PS_HOME"/setup && ./psrun.mak
	#    else
	#      echoerror "Could not find the file $PS_HOME/setup/psrun.mak"
	#      exit 1
	#    fi
	#  ;;

	esac
}

function action_web
{	
	case $act in
		status)
			echo "Webserver status"
			"$PS_HOME"/bin/psadmin -w status -d "$dom"
		;;
		start)
			echo "Starting webserver"
			"$PS_HOME"/bin/psadmin -w start -d "$dom"
		;;
		stop)
			echo "Stopping webserver"
			"$PS_HOME"/bin/psadmin -w shutdown -d "$dom"
		;;
		purge)
			echo "Purging webserver cache"
			rm -rfv "$PS_CFG_HOME/webserv/$dom/applications/peoplesoft/PORTAL*/*/cache*"
		;;
		restart)
			echo "Stopping webserver"
			"$PS_HOME"/bin/psadmin -w shutdown -d "$dom"
			echo "Starting webserver"
			"$PS_HOME"/bin/psadmin -w start -d "$dom"
		;;
		bounce)
			echo "Stopping webserver"
			"$PS_HOME"/bin/psadmin -w shutdown -d "$dom"
			echo "Purging webserver cache"
			rm -rfv "$PS_CFG_HOME/webserv/$dom/applications/peoplesoft/PORTAL*/*/cache*"
			echo "Starting webserver"
			"$PS_HOME"/bin/psadmin -w start -d "$dom"
		;;
	esac
}

function action_menu_call
{
	act=$1
	# loop cfg
	for ((i=0; i<${#cfgs[*]}; i++));
	do
		cfg=${cfgs[i]}
		source_cfgfile; 
		# loop type
		printf "\n========== cfg: $cfg ============\n"
		(
    	for ((j=0; j<${#types[*]}; j++));
		do
			type=${types[j]}
			# loop domains
			printf "\n    ========== type: $type ============\n"
			set_domains 
			for ((k=0; k<${#doms[*]}; k++));			
			do				
				dom=${doms[k]}
				printf "\n        ========== domain: $dom ============\n\n"
				action_${type} #dynamic function call
				printf "\n        ====================================\n"
			done
			printf "\n    ====================================\n"
		done
		)
		printf "\n====================================\n"
	done	

	read -rsp $'\nDone.\n' -n1 key	
}

###########################
### Menus   
###########################

function main_menu 
{
	cd $PS_CFG_HOME_DIR
    cfghomes=(*)
	
	option=0
	cfgs=() 
	types=()
		
	until [ "$option" = "q" ]; do
	print_header
	for ((i=0; i<${#cfghomes[*]}; i++));
	do
		print_menu_item $((i+1)) ${cfghomes[i]}
	done

	echo "   - "
	echo " s - Select" 	
	echo " q - Quit"
	echo -e "\n"
	echo -n "Enter choice: "
	read option
	echo ""
	case $option in
		s ) select_menu;;
		q ) clear; exit ;;
		* ) cfgs=(${cfghomes[$((option-1))]}); types=('web' 'app' 'prcs'); action_menu;;
	esac	
	done
}

function select_menu 
{
    option=0

    until [ "$option" = "q" ]; do
	cfgs=() 	
	types=()
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
		1 ) selectdoms_menu;;
        2 ) get_cfgs_web; get_cfgs_app; get_cfgs_prcs; types=('web' 'app' 'prcs'); action_menu;;
		3 ) get_cfgs_web; types=('web'); action_menu;;
		4 ) get_cfgs_app; types=('app'); action_menu;;
		5 ) get_cfgs_prcs; types=('prcs'); action_menu;;
		q ) clear; main_menu ;;
		* ) echo "ya messed up, yo";;
	esac
	done
}

function selectdoms_menu
{
	#TODO	
    # select cfg
    option=""
    cfgs=()
    until [ "$option" = "d" ]; do
        print_header
        for ((i=0; i<${#cfghomes[*]}; i++));
	    do
		    echo " $((i+1)) -  ${cfghomes[i]}"
	    done
        echo "   - " 
        echo " d - Done "
        echo " q - Quit "
        echo -e "\n"
        echo -n "Enter choice: "

        read option
		echo ""
		case $option in
			d ) ;;
            q ) clear; select_menu;;
            * ) cfgs+=(${cfghomes[$((option-1))]});;
		esac
	    cfgs=($(printf "%s\n" "${cfgs[@]}" | sort -u))
	done

    #select type
    option=""
    types=()
    until [ "$option" = "q" ]; do
        print_header
        echo " 1 - web "
        echo " 2 - app "
        echo " 3 - prcs "
        echo "   - "
        echo " d - Done"
        echo " q - Quit"
        echo -e "\n"
        echo -n "Enter choice: "

        read option
        echo " "
        case $option in
            1 ) types+=("web");;
            2 ) types+=("app");;
            3 ) types+=("prcs");;
            d ) action_menu;;
            q ) clear; select_menu;;
            * ) ;;
        esac
    	types=($(printf "%s\n" "${types[@]}" | sort -u))
    done
}

function action_menu
{
    option=0

    until [ "$option" = "q" ]; do
	print_header

	echo " 1 - Status     6 - Bounce    "
	echo " 2 - Start      7 - Kill      "
	echo " 3 - Stop       8 - Configure "
	echo " 4 - Restart    9 - Flush     "
	echo " 5 - Purge"
	echo "   - "
	# not multi select?
	if [ ${#cfgs[@]} -eq 1 ]; then
		echo " s - summary"
		echo " p - psadmin"
		echo " e - edit psconfig.sh"
		echo " h - help"
	fi
	echo " q - Quit"
	echo -e "\n"
	echo -n "Enter choice: "
	
	read option
	echo ""
	case $option in
		1 ) action_menu_call "status";;
		2 ) action_menu_call "start" ;;
		3 ) action_menu_call "stop";;
		4 ) action_menu_call "restart";;
		5 ) action_menu_call "purge";;
		6 ) action_menu_call "bounce";;
		7 ) action_menu_call "kill";;
		8 ) action_menu_call "configure";;
		9 ) action_menu_call "flush";;
		s ) call_summary;;
		p ) call_psadmin;;
		e ) edit_psconfig;;
		h ) print_help;;
		q ) clear; main_menu ;;
		* ) echo "ya messed up, yo";;
	esac
	done
}

function print_header
{
	clear
	echo "+-------------------------------------------------+" 
	echo "| $(echo_color $title "lblue")   host: $(echo_color $host "lgreen") "	
	echo "|                cfgs: $(echo_color "${cfgs[*]}" "lpurple") "
	echo "|               types: $(echo_color "${types[*]}" "lcyan") "
	echo "+-------------------------------------------------+"
}

function print_help
{
	echo " "
	echo ". help ......................."
	echo ". "
	echo ". status - status of the domain"
	echo ". start - start the domain"
	echo ". stop - stop the domain"
	echo ". restart - stop and start the domain"
	echo ". purge - clear domain cache"
	echo ". bounce - stop, flush, purge, configure and start the domain"
	echo ". kill - force stop the domain"
	echo ". configure - configure the domain"
	echo ". flush - clear domain IPC"
	echo " "
	
	read -rsp $'\nPress any key...\n' -n1 key
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

###########################
### Misc   
###########################

function validate_vars
{
	for var in ${required_vars[@]}; do
        if [[ `printenv ${var}` = '' ]]; then
      		echo $(echo_color "${var} is not set.  Please make sure this is set before continuing." "red")
			echo $(echo_color "Example: export PS_CFG_HOME_DIR=/u01/psoft/cfg" "red")
			echo $(echo_color "Example: export PS_CUST_HOME_DIR=/u01/psoft/cust" "red")
      		exit 1
      	fi
  	done
}

function is_web_cfg
{
	cfg=$1
	dir=$PS_CFG_HOME_DIR/$cfg/webserv/
	if [ -d "$dir" ]; then
		subdircount=`find $dir -maxdepth 1 -type d | wc -l`
		if [ $subdircount -gt 1 ]; then  
			return 0 #true
		fi
	fi
	return 1 #false
}

function is_app_cfg
{
	cfg=$1
	dir=$PS_CFG_HOME_DIR/$cfg/appserv/
	if [ -d "$dir" ]; then
		subdircount=`find $dir -maxdepth 1 -type d | wc -l`
		if [ $subdircount -gt 3 ]; then
			return 0 #true
		fi
	fi
	return 1 #false
}

function is_prcs_cfg
{
	cfg=$1
	dir=$PS_CFG_HOME_DIR/$cfg/appserv/prcs/
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

function check_app
{
    cfg=$1
	if is_app_cfg $cfg; then
	    echo -n $(echo_color "a" "lblue")
	else
        echo -n " "
    fi
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

function set_domains
{	
	PS_CFG_HOME=$PS_CFG_HOME_DIR/$cfg
	case $type in
		web )  dirs=($PS_CFG_HOME/webserv/*);;
		app ) dirs=($PS_CFG_HOME/appserv/*);;
		prcs ) dirs=($PS_CFG_HOME/appserv/prcs/*);;
		* ) echo "something went wrong setting domains";;
	esac
	
	doms=()
	shopt -s nullglob # handles empty dirs
	for dir in "${dirs[@]}"
	do
		if [ -d "$dir" ]
		then
			dirname=${dir##*/} # strip fullpath
			if [[ "$dirname" != "Search" && "$dirname" != "prcs" ]]
			then
				doms+=($dirname) 
			fi
		fi
	done
}

function call_summary
{ 
	clear
	cfg=${cfgs[0]} 
	(source_cfgfile; $PS_HOME/bin/psadmin -envsummary)
	read -rsp $'\nPress any key...\n' -n1 key
}

function call_psadmin
{ 
	clear
	cfgtmp=${cfgs[0]} 
	(source_cfgfile; $PS_HOME/bin/psadmin)
}

function source_cfgfile
{
	file_psconfig=$PS_CUST_HOME_DIR/$cfg/psconfig.sh
	file_arch=$PS_CUST_HOME_DIR/$cfg/archive/psconfig.sh

	#archive
	if [ $file_psconfig -nt $file_arch ]
	then
        	echo "Archiving psconfig.sh, since it has changed."
		mv $file_arch $file_arch.$(date +%Y%m%d%H%M)
        	cp $file_psconfig $file_arch
	fi

	# source
	. $file_psconfig
}

function edit_psconfig
{
    clear
    $EDITOR $PS_CUST_HOME_DIR/${cfgs[0]}/psconfig.sh
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

###########################
### Main 
###########################
act=$1
cfg=$2
dom=$3
type=$4

# source in login profile
#export PS_CFG_HOME_DIR=/u01/psoft/cfg
#export PS_CUST_HOME_DIR=/u01/psoft/cust

title=psadmin-plus
host=$(hostname)
required_vars=( PS_CFG_HOME_DIR PS_CUST_HOME_DIR )

# set editor
if [ -z "$EDITOR" ]; then
	EDITOR='vim'
fi

validate_vars

# if no action set, run menu
if [ -z "$act" ]; then
	main_menu
else	
	source_cfgfile; 
	case $type in
			app ) action_app;;
			prcs ) action_prcs;;
			web )  action_web;;
			all )  action_app; action_prcs; action_web;;
			* ) echo "invalid type!";;
	esac
fi
