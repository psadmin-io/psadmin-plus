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
  [String]$Action = "help",
  [String]$Type   = "all",
  [String]$Domain = "all"
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
    
Function GetDomainsApp()
{
    return (Get-ChildItem $Env:PS_CFG_HOME/appserv | ?{ $_.PSIsContainer } | ?{ $_.PSIsContainer } | Where-Object {$_.name -ne "Search" -and $_.name -ne "prcs"})
}

Function GetDomainsPrcs()
{
    return (Get-ChildItem $Env:PS_CFG_HOME/appserv/prcs | ?{ $_.PSIsContainer })
}

Function GetDomainsWeb()
{
    return (Get-ChildItem $Env:PS_CFG_HOME/webserv | ?{ $_.PSIsContainer })
}

Function ActionApp($Domain, $Action)
{
    $psadmin = "$env:PS_HOME\appserv\psadmin"
    if ($DEBUG -eq "true") {Write-Host "Action App - Domain: $Domain Action: $Action"}

    if ( $Domain -eq "all" ) {
        if ($DEBUG -eq "true") {Write-Host "Acting on ALL domains found"}
		$DomainList = GetDomainsApp
    } else {
        $DomainList=($Domain)
    }     
    
    ForEach ($dom in $DomainList) {
        PrintActionInfo "$Action" "app" "$dom"
        switch ($Action) {
            "status" {
                        Write-Host "Appserver status $dom"
                        Invoke-Expression "$psadmin -c sstatus -d $dom"
                        Invoke-Expression "$psadmin -c cstatus -d $dom"
                        Invoke-Expression "$psadmin -c qstatus -d $dom"
                        Invoke-Expression "$psadmin -c pslist -d $dom"
                     }
            "start"  {
                        Invoke-Expression "$psadmin -c boot -d $dom"
                     }
            "stop"   {
                        Invoke-Expression "$psadmin -c shutdown -d $dom"
                     }
            "kill"   {
                        Invoke-Expression "$psadmin -c shutdown! -d $dom"
                     }
            "configure" {
                        Invoke-Expression "$psadmin -c configure -d $dom"
                     }
            "purge"  {
                        Invoke-Expression "$psadmin -c purge -d $dom"
                        #echo "$domain cache purged."
                     }
            "flush"  {
                        Invoke-Expression "$psadmin -c cleanipc -d $dom"
                     }
            "restart" {
                        Invoke-Expression "$psadmin -c shutdown -d $dom *>&1"
                        Invoke-Expression "$psadmin -c boot -d $dom *>&1"
                     }
            "bounce" {
                        Invoke-Expression "$psadmin -c shutdown -d $dom"
                        Invoke-Expression "$psadmin -c cleanipc -d $dom"
                        Invoke-Expression "$psadmin -c purge -d $dom"
                        Invoke-Expression "$psadmin -c configure -d $dom"
                        Invoke-Expression "$psadmin -c boot -d $dom"
                     }
        }
    }    
}


Function ActionPrcs($Domain, $Action) {
    $psadmin = "$env:PS_HOME\appserv\psadmin.exe"
    if ($DEBUG -eq "true") {Write-Host "Action Prcs - Domain: $Domain Action: $Action"}

    if ( $Domain -eq "all" ) {
        if ($DEBUG -eq "true") {Write-Host "Acting on ALL domains found"}
		$DomainList = GetDomainsPrcs
    } else {
        $DomainList=($Domain)
    }
     
    ForEach ($dom in $DomainList) {
        PrintActionInfo "$Action" "prcs" "$dom"
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
		$DomainList = GetDomainsWeb
    } else {
        $DomainList=($Domain)
    }     
    
    ForEach ($dom in $DomainList) {
        PrintActionInfo "$Action" "web" "$dom"
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

Function PrintActionInfo($Action_, $Type_, $Domain_) {
    Write-Host ""
    Write-Host "+--------------------------------------------------------------------+" -foregroundcolor "green"
    Write-Host "  Action: " -NoNewLine -foregroundcolor "white"
    Write-Host "$Action_ " -NoNewLine -foregroundcolor "cyan"
    Write-Host "| Type: " -NoNewLine -foregroundcolor "white"
    Write-Host "$Type_ " -NoNewLine -foregroundcolor "cyan"
    Write-Host "| Domain: " -NoNewLine -foregroundcolor "white"
    Write-Host "$Domain_ " -foregroundcolor "cyan"
    Write-Host "+--------------------------------------------------------------------+" -foregroundcolor "green"
}

Function PrintDomainList() {
    Write-Host ""
    Write-Host "+--------------------------------------------------------------------+" -foregroundcolor "green"
    Write-Host "app: $(GetDomainsApp)"  -foregroundcolor "cyan"
    Write-Host "prcs: $(GetDomainsPrcs)"  -foregroundcolor "cyan"
    Write-Host "web: $(GetDomainsWeb)"  -foregroundcolor "cyan"
    Write-Host "+--------------------------------------------------------------------+" -foregroundcolor "green"
}

Function PrintHelp{
  Write-Host " "
  Write-Host ". help ......................."
  Write-Host ". There is no menu currently, just command line"
  Write-Host ". example: PSAdminPlus.ps1 [action] [type] [domain]"
  Write-Host ". "
  Write-Host ". actions ...................."
  Write-Host ". summary - PS_CFG_HOME summary, no type or domain needed"
  Write-Host ". status - status of the domain"
  Write-Host ". start - start the domain"
  Write-Host ". stop - stop the domain"
  Write-Host ". restart - stop and start the domain"
  Write-Host ". purge - clear domain cache"
  Write-Host ". bounce - stop, flush, purge, configure and start the domain"
  Write-Host ". kill - force stop the domain"
  Write-Host ". configure - configure the domain"
  Write-Host ". flush - clear domain IPC"
  Write-Host ". "
  Write-Host ". types ......................"
  Write-Host ". app"
  Write-Host ". prcs"
  Write-Host ". web"
  Write-Host ". all"
  Write-Host ". "
  Write-Host ". domains....................."
  Write-Host ". domain name"
  Write-Host ". all"
  Write-Host ""
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

if ($DEBUG -eq "true") {Write-Host "Action: $Action Type: $Type Domain: $Domain"}

switch ($Action) {
	"help" {PrintHelp;
                Write-Host -NoNewLine 'Press any key to launch psadmin...';
	        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
	        CallPSAdmin
                }
        "summary"  {CallSummary}
        "list"     {PrintDomainList}  
        default    {switch ($Type) {
                        "app"  {ActionApp  $Domain $Action}
                        "prcs" {ActionPrcs $Domain $Action}
                        "web"  {ActionWeb  $Domain $Action}
                        "all"  {ActionApp  $Domain $Action; ActionPrcs $Domain $Action; ActionWeb $Domain $Action}
                        default {Write-Host "invalid type!"}
                        }
                   }
}
