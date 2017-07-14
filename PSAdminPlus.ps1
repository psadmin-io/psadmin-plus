#--------------------------------------------#
# psadmin-plus                               #
# https://github.com/psadmin-io/psadmin-plus #
#--------------------------------------------#

[CmdletBinding()]
Param (
  [String]$Action = $null
  [String]$Type = null
  [String]$Domain = null
)

##########################
# Actions
##########################
    
function action_app
{
    if [ $domparam = "all" ] ; then
        list=("${app_doms[@]}")
    else
        list=($domparam)
    fi
    
    for dom in "${list[@]}"
    do
        act_type=app
        print_action_info
        case $act in

        status)
            exec_cmd "psadmin -c sstatus -d $dom" 2>&1
            exec_cmd "psadmin -c cstatus -d $dom" 2>&1
            exec_cmd "psadmin -c qstatus -d $dom" 2>&1
            exec_cmd "psadmin -c pslist -d $dom" 2>&1
        ;;

        start)
            exec_cmd "psadmin -c boot -d $dom" 2>&1
        ;;

        stop)
            exec_cmd "psadmin -c shutdown -d $dom" 2>&1
        ;;

        kill)
            exec_cmd "psadmin -c shutdown! -d $dom" 2>&1
        ;;

        configure)
            exec_cmd "psadmin -c configure -d $dom" 2>&1
        ;;

        purge)    
            exec_cmd "psadmin -c purge -d $dom" 2>&1
            echo "$domain cache purged."
        ;;

        flush)
            exec_cmd "psadmin -c cleanipc -d $dom" 2>&1
        ;;

        restart)
            exec_cmd "psadmin -c shutdown -d $dom" 2>&1
            exec_cmd "psadmin -c boot -d $dom" 2>&1
        ;;

        bounce)
            exec_cmd "psadmin -c shutdown -d $dom" 2>&1
            exec_cmd "psadmin -c cleanipc -d $dom" 2>&1
            exec_cmd "psadmin -c purge -d $dom" 2>&1
            exec_cmd "psadmin -c configure -d $dom" 2>&1
            exec_cmd "psadmin -c boot -d $dom" 2>&1
        ;;

        esac
    done    
    echo ""
}

Function ActionPrcs() {
    if ( $Domain -eq "all" ) {
        #$DomainList=("${prcs_doms[@]}")
    } else {
        #$DomainList=($domparam)
    }
    
    ForEach ($dom in $DomainList) {
        #act_type=prcs
        PrintActionInfo
        switch ($Action) {
            "status" {
                        Invoke-Expression "$PS_HOME\bin\psadmin -p status -d $dom"
                     }
            "start"  {
                        Invoke-Expression "$PS_HOME\bin\psadmin -p start -d $dom"
                     }
            "stop"   {
                        Invoke-Expression "$PS_HOME\bin\psadmin -p stop -d $dom"
                     }
            "kill"   {
                        Invoke-Expression "$PS_HOME\bin\psadmin -p kill -d $dom"
                     }
            "configure" {
                        Invoke-Expression "$PS_HOME\bin\exec_cmd psadmin -p configure -d $dom"
                     }
            "flush"  {
                        Invoke-Expression "$PS_HOME\bin\psadmin -p cleanipc -d $dom"
                     }
            "restart"{
                        Invoke-Expression "$PS_HOME\bin\psadmin -p stop -d $dom"
                        Invoke-Expression "$PS_HOME\bin\psadmin -p start -d $dom"
                     }
            "bounce" {
                        Invoke-Expression "$PS_HOME\bin\psadmin -p stop -d $dom" 
                        Invoke-Expression "$PS_HOME\bin\psadmin -p cleanipc -d $dom" 
                        Invoke-Expression "$PS_HOME\bin\psadmin -p configure -d $dom" 
                        Invoke-Expression "$PS_HOME\bin\psadmin -p start -d $dom"
                     }
    #    compile)
    #        if [[ -f $PS_HOME/setup/pscbl.mak ]]; then
    #            echo "Recompiling COBOL"
    #            cd "$PS_HOME"/setup && ./pscbl.mak
    #            cd "$PS_HOME"/setup && ./pscbl.mak
    #        else
    #            echoerror "Could not find the file $PS_HOME/setup/pscbl.mak"
    #            exit 1
    #        fi
    #    ;;

    #    link)
    #        if [[ -f $PS_HOME/setup/psrun.mak ]]; then
    #            echo "Linking COBOL"
    #            cd "$PS_HOME"/setup && ./psrun.mak
    #        else
    #            echoerror "Could not find the file $PS_HOME/setup/psrun.mak"
    #            exit 1
    #        fi
    #    ;;

        }
    }
}

Function ActionWeb() {	
    if ( $Domain -eq "all" ) {
        #$DomainList = ("${web_doms[@]}")
    } else {
        #$DomainList = ($domparam)
    }
    
    ForEach ($dom in $DomainList) {
        #act_type=web
        PrintAtionInfo
        switch ($Action) {
            "status" {
                        Write-Host "Webserver status $dom"
                        Invoke-Expression "$PS_HOME\bin\psadmin -w status -d $dom"
                     }
            "start"  {
                        Write-Host "Starting webserver"
                        Invoke-Expression "$PS_HOME\bin\psadmin -w start -d $dom"
                     }
            "stop"   {
                        Write-Host "Stopping webserver"
                        Invoke-Expression "$PS_HOME\bin\psadmin -w shutdown -d $dom"
                     }
            #"purge"  {
            #            Write-Host "Purging webserver cache"
            #            Invoke-Expression "rm -rf $PS_CFG_HOME\webserv\$dom\applications\peoplesoft\PORTAL*\*\cache*\"
            #         }
            "restart" {
                            Write-Host "Stopping webserver"
                            Invoke-Expression "$PS_HOME\bin\psadmin -w shutdown -d $dom"
                            Write-Host "Starting webserver"
                            Invoke-Expression "$PS_HOME\bin\psadmin -w start -d $dom"
                      }
            "bounce"  {
                            Write-Host "Stopping webserver"
                            Invoke-Expression "$PS_HOME\bin\psadmin -w shutdown -d $dom"
                            Write-Host "Purging webserver cache"
	                        #Invoke-Expression "rm -rf $PS_CFG_HOME\webserv\$dom\applications\peoplesoft\PORTAL*\*\cache*\"
                            Write-Host "Starting webserver"
                            Invoke-Expression "$PS_HOME\bin\psadmin -w start -d $dom"
                      }
        }
    }
}

Function PrintActionInfo() {
    #echo ""	
    #echo "$(echo_color "+--------------------------------------------------------------------+" "brown")"	
    #echo "  $(echo_color "Action:" "brown") $(echo_color "$act" "lred") | $(echo_color "Type:" "brown") $(echo_color "$act_type" "lcyan") | $(echo_color "Domain:" "brown") $(echo_color "$dom" "lgreen")"			
    #echo "$(echo_color "+--------------------------------------------------------------------+" "brown")"	
    #echo ""
}

###########################
### Menus   
###########################

Function PrintHeader() {
    clear
    #echo "+-------------------------------------------------+" 
    #echo "| $(echo_color $title "lblue")   host: $(echo_color $host "lgreen") "	
    #echo "+-------------------------------------------------+"
}

Function PrintHelp{
  #  echo " "
  #  echo ". help ......................."
  #  echo ". There is no menu currently, just command line"
  #  echo ". example: psadmin-plus [action] [type] [domain]"
  #  echo ". "
  #  echo ". actions ...................."
  #  echo ". summary - PS_CFG_HOME summary, no type or domain needed"
  #  echo ". status - status of the domain"
  #  echo ". start - start the domain"
  #  echo ". stop - stop the domain"
  #  echo ". restart - stop and start the domain"
  #  echo ". purge - clear domain cache"
  #  echo ". bounce - stop, flush, purge, configure and start the domain"
  #  echo ". kill - force stop the domain"
  #  echo ". configure - configure the domain"
  #  echo ". flush - clear domain IPC"
  #  echo ". "
  #  echo ". types ......................"
  #  echo ". app"
  #  echo ". prcs"
  #  echo ". web"
  #  echo ". all"
  #  echo ". "
  #  echo ". domains....................."
  #  echo ". domain name"
  #  echo ". all"
  #
  #  read -rsp $'\nPress any key to run psadmin...\n' -n1 key_ 
}


###########################
### Misc   
###########################

Function SetDomains() {	
    web_dirs=($PS_CFG_HOME/webserv/*)
    app_dirs=($PS_CFG_HOME/appserv/*)
    prcs_dirs=($PS_CFG_HOME/appserv/prcs/*)
	
    web_doms=()
    shopt -s nullglob # handles empty dirs
    for dir in "${web_dirs[@]}"
    do
        if [ -d "$dir" ]
        then
            dirname=${dir##*/} # strip fullpath
            if [[ "$dirname" != "Search" && "$dirname" != "prcs" ]]
	    then
                web_doms+=($dirname) 
            fi
        fi
    done
	
    app_doms=()
    shopt -s nullglob # handles empty dirs
    for dir in "${app_dirs[@]}"
    do
        if [ -d "$dir" ]
        then
            dirname=${dir##*/} # strip fullpath
            if [[ "$dirname" != "Search" && "$dirname" != "prcs" ]]
	    then
                app_doms+=($dirname) 
            fi
        fi
    done
	
    prcs_doms=()
    shopt -s nullglob # handles empty dirs
    for dir in "${prcs_dirs[@]}"
    do
        if [ -d "$dir" ]
        then
            dirname=${dir##*/} # strip fullpath
            if [[ "$dirname" != "Search" && "$dirname" != "prcs" ]]
	    then
               prcs_doms+=($dirname) 
            fi
        fi
    done
}

Function CallSummary() { 
    Clear
	Invoke-Expression "$PS_HOME\bin\psadmin -envsummary"
    #read -rsp $'\nPress any key...\n' -n1 key
}

Function CallPSAdmin() { 
	Clear
	Invoke-Expression "$PS_HOME\bin\psadmin"	
}

###########################
### Main 
###########################

$Title = "psadmin-plus"
# $Host = $(hostname)


# if no action set, run menu
if (!$Action) {
	#print_header
	#print_help
	CallPSAdmin
} else {	
    if ( $Action -eq "summary" ) {
        CallSummary
    } else {
        set_domains
        case $type in
            app ) action_app;;
            prcs ) action_prcs;;
            web )  action_web;;
            all )  action_app; action_prcs; action_web;;
            * ) echo "invalid type!";;
        esac
    }
}
