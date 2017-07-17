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

$DEBUG = "false"

#-----------------------------------------------------------[Functions]-----------------------------------------------------------

##########################
# Actions
##########################
    
Function ActionApp($Domain, $Action)
{
    $psadmin = "$env:PS_HOME\appserv\psadmin"
    if ($DEBUG -eq "true") {Write-Host "Action App - Domain: $Domain Action: $Action"}

    if ( $Domain -eq "all" ) {
        if ($DEBUG -eq "true") {Write-Host "Acting on ALL domains found"}
        #$DomainList=( TODO - find all prcs domains)
    } else {
        $DomainList=($Domain)
    }     
    
    ForEach ($dom in $DomainList) {
        PrintActionInfo
        switch ($Action) {
            "status" {
                        Write-Host "Appserver status $dom"
                        Invoke-Expression "$psadmin -c sstatus -d $dom *>&1"
                       # Invoke-Expression "$psadmin -c cstatus -d $dom 2>&1"
                       # Invoke-Expression "$psadmin -c qstatus -d $dom 2>&1"
                       # Invoke-Expression "$psadmin -c pslist -d $dom 2>&1"
                     }
            "start"  {
                        Invoke-Expression "$psadmin -c boot -d $dom 2>&1"
                     }
            "stop"   {
                        Invoke-Expression "$psadmin -c shutdown -d $dom 2>&1"
                     }
            "kill"   {
                        Invoke-Expression "$psadmin -c shutdown! -d $dom" 2>&1
                     }
            "configure" {
                        Invoke-Expression "$psadmin -c configure -d $dom" 2>&1
                     }
            "purge"  {
                        Invoke-Expression "$psadmin -c purge -d $dom" 2>&1
                        #echo "$domain cache purged."
                     }
            "flush"  {
                        Invoke-Expression "$psadmin -c cleanipc -d $dom" 2>&1
                     }
            "restart" {
                        Invoke-Expression "$psadmin -c shutdown -d $dom" 2>&1
                        Invoke-Expression "$psadmin -c boot -d $dom" 2>&1
                     }
            "bounce" {
                        Invoke-Expression "$psadmin -c shutdown -d $dom" 2>&1
                        Invoke-Expression "$psadmin -c cleanipc -d $dom" 2>&1
                        Invoke-Expression "$psadmin -c purge -d $dom" 2>&1
                        Invoke-Expression "$psadmin -c configure -d $dom" 2>&1
                        Invoke-Expression "$psadmin -c boot -d $dom" 2>&1
                     }
        }
    }    
}


Function ActionPrcs($Domain, $Action) {
    $psadmin = "$env:PS_HOME\appserv\psadmin.exe"
    if ($DEBUG -eq "true") {Write-Host "Action Prcs - Domain: $Domain Action: $Action"}

    if ( $Domain -eq "all" ) {
        if ($DEBUG -eq "true") {Write-Host "Acting on ALL domains found"}
        #$DomainList=( TODO - find all prcs domains)
    } else {
        $DomainList=($Domain)
    }
     
    ForEach ($dom in $DomainList) {
        PrintActionInfo
        switch ($Action) {
            "status" {
                        Invoke-Expression "$psadmin -p status -d $dom *>&1"
                     }
            "start"  {
                        Invoke-Expression "$psadmin -p start -d $dom *>&1"
                     }
            "stop"   {
                        Invoke-Expression "$psadmin -p stop -d $dom *>&1"
                     }
            "kill"   {
                        Invoke-Expression "$psadmin -p kill -d $dom *>&1"
                     }
            "configure" {
                        Invoke-Expression "$psadmin -p configure -d $dom *>&1"
                     }
            "flush"  {
                        Invoke-Expression "$psadmin -p cleanipc -d $dom *>&1"
                     }
            "restart"{
                        Invoke-Expression "$psadmin -p stop -d $dom *>&1"
                        Invoke-Expression "$psadmin -p start -d $dom *>&1"
                     }
            "bounce" {
                        Invoke-Expression "$psadmin -p stop -d $dom *>&1"
                        Invoke-Expression "$psadmin -p cleanipc -d $dom *>&1"
                        Invoke-Expression "$psadmin -p configure -d $dom *>&1"
                        Invoke-Expression "$psadmin -p start -d $dom *>&1"
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
	Write-Host ""
}

Function ActionWeb() {	
    $psadmin = "$env:PS_HOME\appserv\psadmin.exe"
    if ($DEBUG -eq "true") {Write-Host "Action Web - Domain: $Domain Action: $Action"}

    if ( $Domain -eq "all" ) {
        if ($DEBUG -eq "true") {Write-Host "Acting on ALL domains found"}
        #$DomainList=( TODO - find all prcs domains)
    } else {
        $DomainList=($Domain)
    }     
    
    ForEach ($dom in $DomainList) {
        #act_type=web
        PrintAtionInfo
        switch ($Action) {
            "status" {
                        Write-Host "Webserver status $dom"
                        Invoke-Expression "$psadmin -w status -d $dom *>&1"
                     }
            "start"  {
                        Write-Host "Starting webserver"
                        Invoke-Expression "$psadmin -w start -d $dom *>&1"
                     }
            "stop"   {
                        Write-Host "Stopping webserver"
                        Invoke-Expression "$psadmin -w shutdown -d $dom *>&1"
                     }
            #"purge"  {
            #            Write-Host "Purging webserver cache"
            #            Invoke-Expression "rm -rf $Env:PS_CFG_HOME\webserv\$dom\applications\peoplesoft\PORTAL*\*\cache*\"
            #         }
            "restart" {
                            Write-Host "Stopping webserver"
                            Invoke-Expression "$psadmin -w shutdown -d $dom *>&1"
                            Write-Host "Starting webserver"
                            Invoke-Expression "$psadmin -w start -d $dom *>&1"
                      }
            "bounce"  {
                            Write-Host "Stopping webserver"
                            Invoke-Expression "$psadmin -w shutdown -d $dom *>&1"
                            Write-Host "Purging webserver cache"
	                        #Invoke-Expression "rm -rf $Env:PS_CFG_HOME\webserv\$dom\applications\peoplesoft\PORTAL*\*\cache*\"
                            Write-Host "Starting webserver"
                            Invoke-Expression "$psadmin -w start -d $dom *>&1"
                      }
        }
    }
}

Function PrintActionInfo() {
    Write-Host "+--------------------------------------------------------------------+" -foregroundcolor "green"
    Write-Host "  Action: " -NoNewLine -foregroundcolor "white"
	Write-Host "$Action " -NoNewLine -foregroundcolor "cyan"
	Write-Host "| Type: " -NoNewLine -foregroundcolor "white"
	Write-Host "$Type " -NoNewLine -foregroundcolor "cyan"
	Write-Host "| Domain: " -NoNewLine -foregroundcolor "white"
	Write-Host "$Domain " -foregroundcolor "cyan"
    Write-Host "+--------------------------------------------------------------------+" -foregroundcolor "green"
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
    $psadmin = "$env:PS_HOME\appserv\psadmin.exe"
    Clear
	Invoke-Expression "$psadmin -envsummary *>&1"
    #read -rsp $'\nPress any key...\n' -n1 key
}

Function CallPSAdmin() { 
    $psadmin = "$env:PS_HOME\appserv\psadmin.exe"
	Clear
	Invoke-Expression "$psadmin"	
}

#-----------------------------------------------------------[Execution]-----------------------------------------------------------

$Title = "psadmin-plus"
# $Host = $(hostname)

if ($DEBUG -eq "true") {Write-Host "Action: $Action Type: $Type Domain: $Domain"}

# if no action set, run menu
if ( $Action -eq "none") {
	#print_header
	#print_help
	PrintHelp
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
