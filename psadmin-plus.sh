#!/bin/bash

#--------------------------------------------#
# psadmin-plus                               #
# https://github.com/psadmin-io/psadmin-plus #
#--------------------------------------------#

###########################
###  WEB
###########################
function web_status
{    
    domain=$1
	add_step "\$PS_HOME/bin/psadmin -w status -d $domain" 
}

function web_start
{
    domain=$1
	add_step "\$PS_HOME/bin/psadmin -w start -d $domain"
}

function web_stop
{
    domain=$1
	add_step "\$PS_HOME/bin/psadmin -w shutdown -d $domain"
}

function web_restart
{
	domain=$1
    web_stop $domain
    web_start $domain
}

function web_purge
{
	domain=$1
	add_step "rm -rfv $PS_PIA_HOME/webserv/$domain/applications/peoplesoft/PORTAL*/*/cache"
}

function web_bounce
{
	domain=$1
    web_stop $domain
    web_purge $domain
    web_start $domain
}

function web_kill
{

	add_step "printf 'Kill not available for Web\n'"
}

function web_configuration
{
	add_step "printf 'Configuration not available for Web\n'"
}

function web_flush
{
	add_step "printf 'Flush not available for Web\n'"
}

###########################
###  APP
###########################
function app_status
{
    domain=$1
	add_step "\$PS_HOME/bin/psadmin -c sstatus -d $domain"
}

function app_start
{
    domain=$1
    add_step "\$PS_HOME/bin/psadmin -c boot -d $domain"
}

function app_stop
{
    domain=$1
    add_step "\$PS_HOME/bin/psadmin -c shutdown -d $domain"
}

function app_restart
{
    domain=$1
	app_stop $domain
	app_start $domain
}

function app_purge
{
	domain=$1
    add_step "\$PS_HOME/bin/psadmin -c purge -d $domain"
}

function app_bounce
{
	domain=$1
	app_stop $domain
	app_flush $domain
	app_purge $domain
	app_configure $domain
	app_start $domain
}

function app_kill
{
    domain=$1
	add_step "\$PS_HOME/bin/psadmin -c shutdown! -d $domain"
}

function app_configure
{
	domain=$1
    add_step "\$PS_HOME/bin/psadmin -c configure -d $domain"
}

function app_flush
{
	domain=$1
    add_step "\$PS_HOME/bin/psadmin -c cleanipc -d $domain"
}


########################
### PRCS
########################
function prcs_status
{
	domain=$1
    add_step "\$PS_HOME/bin/psadmin -p status -d $domain"
}

function prcs_start
{
    domain=$1
    add_step "\$PS_HOME/bin/psadmin -p start -d $domain"
}

function prcs_stop
{
    domain=$1
    add_step "\$PS_HOME/bin/psadmin -p stop -d $domain"
}

function prcs_restart
{
    domain=$1
	prcs_stop $domain
	prcs_start $domain
}

function prcs_purge
{
	add_step "printf 'Purge not available for Prcs\n'"
}

function prcs_bounce
{
	domain=$1
	prcs_stop $domain
	prcs_flush $domain
	prcs_configure $domain
	prcs_start $domain
}

function prcs_kill
{
	domain=$1
    add_step "\$PS_HOME/bin/psadmin -p kill -d $domain"
}

function prcs_configure
{
	domain=$1
    add_step "\$PS_HOME/bin/psadmin -p configure -d $domain" 
}

function prcs_flush
{
    domain=$1
	add_step "\$PS_HOME/bin/psadmin -p cleanipc -d $domain"
}

#TODO
#function prcs_compile
#{
#    if [[ -f $PS_HOME/setup/pscbl.mak ]]; then
#      echoinfo "Recompiling COBOL"
#      cd "$PS_HOME"/setup && ./pscbl.mak
#      cd "$PS_HOME"/setup && ./pscbl.mak
#    else
#      echoerror "Could not find the file $PS_HOME/setup/pscbl.mak"
#      exit 1
#    fi
#}

#TODO
#function prcs_link
#{
#    if [[ -f $PS_HOME/setup/psrun.mak ]]; then
#      echoinfo "Linking COBOL"
#      cd "$PS_HOME"/setup && ./psrun.mak
#    else
#      echoerror "Could not find the file $PS_HOME/setup/psrun.mak"
#      exit 1
#    fi
#}


###########################
### Menus   
###########################

function main_menu 
{
	cd $PSCFGHOMES_DIR
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
		1 ) read -rsp $'Sorry, this feature is not working yet...\n' -n1 key;; #TODO
		2 ) get_cfgs_web; get_cfgs_app; get_cfgs_prcs; types=('web' 'app' 'prcs'); action_menu;;
		3 ) get_cfgs_web; types=('web'); action_menu;;
		4 ) get_cfgs_app; types=('app'); action_menu;;
		5 ) get_cfgs_prcs; types=('prcs'); action_menu;;
		q ) clear; main_menu ;;
		* ) echo "ya messed up, yo";;
	esac
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
		echo " p - psadmin"
		set_cfgfile ${cfgs[0]}
		echo " c - $cfgfile"
	fi
	echo " q - Quit"
	echo -e "\n"
	echo -n "Enter choice: "
	
	read option
	echo ""
	case $option in
		1 ) call_action "status";;
		2 ) call_action "start" ;;
		3 ) call_action "stop";;
		4 ) call_action "restart";;
		5 ) call_action "purge";;
		6 ) call_action "bounce";;
		7 ) call_action "kill";;
		8 ) call_action "configure";;
		9 ) call_action "flush";;
		p ) call_psadmin;;
		c ) call_psconfig;;
		q ) clear; main_menu ;;
		* ) echo "ya messed up, yo";;
	esac
	done
}

function run_menu
{
	echo -n "Do you want to run now? [y/n]? "
	read runopt
	
	if [ "$runopt" == "y" ]
	then	
		> $PSAPLUS_WRK # clear file		
		for (( ii = 0; ii < ${#cmds[@]} ; ii++ ))
		do
			echo "${cmds[$ii]}" >> $PSAPLUS_WRK
		done
		$PSAPLUS_WRK
	else
		# run later
		# prompt for filename TODO
		echo "Script will save to \$PSAPLUS_WRK: $PSAPLUS_WRK"
		# validate file TODO
		# create script file
		> $PSAPLUS_WRK # clear file		
		for (( ii = 0; ii < ${#cmds[@]} ; ii++ ))
		do
			echo "${cmds[$ii]}" >> $PSAPLUS_WRK
		done
	fi
	
	cmds=()
	read -rsp $'\nDone.\n' -n1 key
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

function call_action
{
	act=$1
	# loop cfg
	for ((i=0; i<${#cfgs[*]}; i++));
	do
		cfg=${cfgs[i]}
		PS_CFG_HOME="$PSCFGHOMES_DIR/$cfg"
		set_cfgfile $cfg
		# loop type
		add_step "printf '\n========== cfg: $cfg ============\n'"	
		add_step "("
		#TODO we should have a function adding these steps I think"
		add_step "cd $PSCONFIGS_DIR" 
    		add_step ". $cfgfile "
    		for ((j=0; j<${#types[*]}; j++));
		do
			type=${types[j]}
			# loop domains
			add_step "printf '\n    ========== type: $type ============\n'"
			set_domains #$cfg $type
			for ((k=0; k<${#doms[*]}; k++));			
			do				
				dom=${doms[k]}
				add_step "printf '\n        ========== domain: $dom ============\n\n'"
				# call function by dynamic name
				${type}_${act} $dom 
				add_step "printf '\n        ====================================\n'"
			done
			add_step "printf '\n    ====================================\n'"
		done
		add_step ")"
		add_step "printf '\n====================================\n'"
	done
		
	run_menu
}

###########################
### Misc   
###########################

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

function set_cfgfile
{
	cfgtmp=$1
	cfgtmp=$(echo $cfgtmp | cut -d'-' -f1)
	cfgfile="psconfig.${cfgtmp}.sh"
}

function source_cfgfile
{
	set_cfgfile $1
	cd $PSCONFIGS_DIR
	. $cfgfile 
}

function set_domains
{	
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

function add_step
{
	step=$1
	cmds+=("$step")
}

function call_psadmin
{ 
	clear
	(source_cfgfile ${cfgs[0]} ; $PS_HOME/bin/psadmin)
}

function call_psconfig
{
    clear
	set_cfgfile ${cfgs[0]}
	cd $PSCONFIGS_DIR
    $EDITOR $cfgfile
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

###########################
### Main 
###########################
#PSCFGHOMES_DIR="$HOME/pscfghomes"
#PSCONFIGS_DIR="$HOME/psconfigs"
PS_PIA_HOME=$PS_CFG_HOME
title=psadmin-plus
host=$(hostname)
required_vars=( PSCFGHOMES_DIR PSCONFIGS_DIR )

# set workfile
if [ -z "$PSAPLUS_WRK" ]; then
	PSAPLUS_WRK="$HOME/.psadmin-plus.wrk"
	touch $PSAPLUS_WRK
	chmod +x $PSAPLUS_WRK
fi
add_step "#!/bin/bash"
add_step "# Generated by $(whoami) $(date '+%d/%m/%Y %H:%M:%S')"

# set editor
if [ -z "$EDITOR" ]; then
	EDITOR='vim'
fi

validate_vars
main_menu
