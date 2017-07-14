#Requires -Version 1

<#PSScriptInfo
    .VERSION 0.1
    .GUID TODO
    .AUTHOR psadmin.io
    .SYNOPSIS
        psadmin wrapper script
    .DESCRIPTION
        Wrapper script for psadmin utility.
    .PARAMETER Action
        Action verb to be performed
    .PARAMETER Type
        Type of domain to take action on
    .PARAMETER Domain
        Name of the domain to take action on
    .EXAMPLE
        PSAdminPlus stop app psftdb
#>

#--------------------------------------------#
# psadmin-plus                               #
# https://github.com/psadmin-io/psadmin-plus #
#--------------------------------------------#

#-----------------------------------------------------------[Parameters]----------------------------------------------------------

[CmdletBinding()]
Param(
  [String]$Action = "none",
  [String]$Type   = "none",
  [String]$Domain = "none"
)

#---------------------------------------------------------[Initialization]--------------------------------------------------------

# Valid values: "Stop", "Inquire", "Continue", "Suspend", "SilentlyContinue"
$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"

#------------------------------------------------------------[Variables]----------------------------------------------------------

If ( $Env:PS_HOME -eq '' ) { Write-Host "PS_HOME must be specified with `$env:PS_HOME" }
If ( $Env:PS_CFG_HOME -eq '' ) { Write-Host "PS_CFG_HOME must be specified with `$env:PS_HOME" }

$DEBUG = "true"

#-----------------------------------------------------------[Functions]-----------------------------------------------------------

##########################
# Actions
##########################
    
function action_app
{<#
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
        "status" {
                        Invoke-Expression "$Env:PS_HOME\psadmin -c sstatus -d $dom"
                        Invoke-Expression "psadmin -c cstatus -d $dom"
                        Invoke-Expression "psadmin -c qstatus -d $dom"
                        Invoke-Expression "psadmin -c pslist -d $dom"
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
    #>
}


Function ActionPrcs($Domain, $Action) {
    if ($DEBUG -eq "true") {Write-Host "Action Prcs - Domain: $Domain Action: $Action"}

    if ( $Domain -eq "all" ) {
        if ($DEBUG -eq "true") {Write-Host "Acting on ALL domains found"}
        #$DomainList=( TODO - find all prcs domains)
    } else {
        $DomainList=($Domain)
    }
     
    ForEach ($dom in $DomainList) {
        PrintActionInfo
        $psadmin = "$env:PS_HOME\appserv\psadmin.exe"
        switch ($Action) {
            "status" {
                        Invoke-Expression "$psadmin -p status -d $dom *>&1"
                     }
            "start"  {
                        Invoke-Expression "$psadmin -p start -d $dom"
                     }
            "stop"   {
                        Invoke-Expression "$psadmin -p stop -d $dom"
                     }
            "kill"   {
                        Invoke-Expression "$psadmin -p kill -d $dom"
                     }
            "configure" {
                        Invoke-Expression "$psadmin -p configure -d $dom"
                     }
            "flush"  {
                        Invoke-Expression "$psadmin -p cleanipc -d $dom"
                     }
            "restart"{
                        Invoke-Expression "$psadmin -p stop -d $dom"
                        Invoke-Expression "$psadmin -p start -d $dom"
                     }
            "bounce" {
                        Invoke-Expression "$psadmin -p stop -d $dom" 
                        Invoke-Expression "$psadmin -p cleanipc -d $dom" 
                        Invoke-Expression "$psadmin -p configure -d $dom" 
                        Invoke-Expression "$psadmin -p start -d $dom"
                     }
    #    compile)
    #        if [[ -f $Env:PS_HOME/setup/pscbl.mak ]]; then
    #            echo "Recompiling COBOL"
    #            cd "$Env:PS_HOME"/setup && ./pscbl.mak
    #            cd "$Env:PS_HOME"/setup && ./pscbl.mak
    #        else
    #            echoerror "Could not find the file $Env:PS_HOME/setup/pscbl.mak"
    #            exit 1
    #        fi
    #    ;;

    #    link)
    #        if [[ -f $Env:PS_HOME/setup/psrun.mak ]]; then
    #            echo "Linking COBOL"
    #            cd "$Env:PS_HOME"/setup && ./psrun.mak
    #        else
    #            echoerror "Could not find the file $Env:PS_HOME/setup/psrun.mak"
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
                        Invoke-Expression "$Env:PS_HOME\bin\psadmin -w status -d $dom"
                     }
            "start"  {
                        Write-Host "Starting webserver"
                        Invoke-Expression "$Env:PS_HOME\bin\psadmin -w start -d $dom"
                     }
            "stop"   {
                        Write-Host "Stopping webserver"
                        Invoke-Expression "$Env:PS_HOME\bin\psadmin -w shutdown -d $dom"
                     }
            #"purge"  {
            #            Write-Host "Purging webserver cache"
            #            Invoke-Expression "rm -rf $Env:PS_CFG_HOME\webserv\$dom\applications\peoplesoft\PORTAL*\*\cache*\"
            #         }
            "restart" {
                            Write-Host "Stopping webserver"
                            Invoke-Expression "$Env:PS_HOME\bin\psadmin -w shutdown -d $dom"
                            Write-Host "Starting webserver"
                            Invoke-Expression "$Env:PS_HOME\bin\psadmin -w start -d $dom"
                      }
            "bounce"  {
                            Write-Host "Stopping webserver"
                            Invoke-Expression "$Env:PS_HOME\bin\psadmin -w shutdown -d $dom"
                            Write-Host "Purging webserver cache"
	                        #Invoke-Expression "rm -rf $Env:PS_CFG_HOME\webserv\$dom\applications\peoplesoft\PORTAL*\*\cache*\"
                            Write-Host "Starting webserver"
                            Invoke-Expression "$Env:PS_HOME\bin\psadmin -w start -d $dom"
                      }
        }
    }
}

Function PrintActionInfo() {
    Write-Host "printactioninfo"	
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
    Write-Host "header"
    #echo "+-------------------------------------------------+" 
    #echo "| $(echo_color $title "lblue")   host: $(echo_color $host "lgreen") "	
    #echo "+-------------------------------------------------+"
}

Function PrintHelp{
    Write-Host "help"
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
    Write-Host "setting domains"
    <#
    web_dirs=($Env:PS_CFG_HOME/webserv/*)
    app_dirs=($Env:PS_CFG_HOME/appserv/*)
    prcs_dirs=($Env:PS_CFG_HOME/appserv/prcs/*)
	
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
    #>
}

Function CallSummary() { 
    Clear
	Invoke-Expression "$Env:PS_HOME\bin\psadmin -envsummary"
    #read -rsp $'\nPress any key...\n' -n1 key
}

Function CallPSAdmin() { 
	Clear
	Invoke-Expression "$Env:PS_HOME\bin\psadmin"	
}

#-----------------------------------------------------------[Execution]-----------------------------------------------------------

$Title = "psadmin-plus"
# $Host = $(hostname)

if ($DEBUG -eq "true") {Write-Host "Action: $Action Type: $Type Domain: $Domain"}

# if no action set, run menu
if (!$Action) {
	#print_header
	#print_help
	CallPSAdmin
} else {	
    if ( $Action -eq "summary" ) {
        CallSummary
    } Else {
        #SetDomains TODO
        switch ($Type) {
            "app"  {ActionApp  $Domain $Action}
            "prcs" {ActionPrcs $Domain $Action}
            "web"  {ActionWeb  $Domain $Action}
            "all"  {ActionApp  $Domain $Action; ActionPrcs $Domain $Action; ActionWeb $Domain $Action}
            #* ) echo "invalid type!";;
        }
    }
}
