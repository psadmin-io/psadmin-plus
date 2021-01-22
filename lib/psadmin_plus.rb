#!/usr/bin/env ruby

require 'rbconfig'
require 'etc'
require 'open3'

def do_help
    puts "Usage: psa [command] <type> <domain>"
    puts " "
    puts "Commands:"
    puts "        "
    puts "    help           display this help message"
    puts "    list           list domains"
    #puts "    admin          launch psadmin"
    puts "    summary        PS_CFG_HOME summary, no type or domain needed"
    puts "    status         status of the domain"
    puts "    start          hookstart, if enabled, then start the domain"
    puts "    stop           hookstop, if enabled, stop the domain"
    puts "    restart        stop and start the domain"
    puts "    purge          clear domain cache"
    puts "    reconfigure    stop, configure, and start the domain"
    puts "    bounce         stop, flush, purge, configure and start the domain"
    puts "    kill           force stop the domain"
    puts "    configure      configure the domain"
    puts "    flush          clear domain IPC"
    puts "      "
    puts "Types:"
    puts "      "
    puts "    app            act on application domains"
    puts "    prcs           act on process scheduler domains"
    puts "    web            act on web domains"
    puts "    all,<blank>    act on all types of domains"
    puts "        "
    puts "Domains:"
    puts "        "
    puts "    dom            act on specific domains"
    puts "    all,<blank>    act on all domains"
    puts " "
    puts "Each parameter type can be enter in a comma separated list "
    puts " "
end

def do_is_runtime_user_nix
    result = ENV['USER'] == PS_RUNTIME_USER ? true : false
end

def do_is_runtime_user_win
    result = ENV['USERNAME'] == PS_RUNTIME_USER ? true : false
end

def env(var)
   result = "#{OS_CONST}" == "linux" ? "${#{var}}" : "%#{var}%"
end

def do_cmd(cmd, print = true, powershell = true)
    case "#{OS_CONST}"
    when "linux"
        if do_is_runtime_user_nix
            case "#{PS_PSA_DEBUG}"
            when "true"
                p "Command: #{cmd}"
            end
            out = `#{cmd}`
        else
            if "#{PS_PSA_SUDO}" == "on"
                case "#{PS_PSA_DEBUG}"
                when "true"
                    p "Command: sudo su - #{PS_RUNTIME_USER} -c '#{cmd}'"
                end
                out = `sudo su - #{PS_RUNTIME_USER} -c '#{cmd}'`
            else
                print "#{PS_RUNTIME_USER} "
                case "#{PS_PSA_DEBUG}"
                when "true"
                    p "Command: su - #{PS_RUNTIME_USER} -c '#{cmd}'"
                end
                out = `su - #{PS_RUNTIME_USER} -c '#{cmd}'`
            end
        end
    when "windows"
        case powershell
        when true
            case "#{PS_PSA_DEBUG}"
            when "true"
                p "Command: powershell -NoProfile -Command \"#{cmd}\""
            end
            out = `powershell -NoProfile -Command "#{cmd}"`
        else
            case "#{PS_PSA_DEBUG}"
            when "true"
                p "Command: #{cmd}"
            end
            out = `#{cmd}`
        end
    else
        out = "Invalid OS"
    end
    print ? (puts out) : result = out 
    out
end

def do_cmd_banner(c,t,d)
    puts ""
    puts "===[ #{c} . #{t} . #{d} ]==="
    puts ""
end

def find_apps_nix
    case "#{PS_MULTI_HOME}"
    when "false"
        apps = do_cmd("find #{env('PS_CFG_HOME')}/appserv/*/psappsrv.ubx",false).split(/\n+/)
    else
        apps = do_cmd("find #{PS_MULTI_HOME}/*/appserv/*/psappsrv.ubx",false).split(/\n+/)
    end
    apps.map! {|app| app.split("/")[-2]}
end

def find_prcss_nix
    case "#{PS_MULTI_HOME}"
    when "false"
        prcss = do_cmd("find #{env('PS_CFG_HOME')}/appserv/prcs/*/psprcsrv.ubx",false).split(/\n+/)
    else 
        prcss = do_cmd("find #{PS_MULTI_HOME}/*/appserv/prcs/*/psprcsrv.ubx",false).split(/\n+/)
    end
    prcss.map! {|prcs| prcs.split("/")[-2]}
end

def find_webs_nix
    case "#{PS_MULTI_HOME}"
    when "false"
        webs = do_cmd("find #{env('PS_CFG_HOME')}/webserv/*/piaconfig -maxdepth 0",false).split(/\n+/)
    else
        webs = do_cmd("find #{PS_MULTI_HOME}/*/webserv/*/piaconfig -maxdepth 0",false).split(/\n+/)
    end
    webs.map! {|web| web.split("/")[-2]}
end

def find_apps_win
    case "#{PS_MULTI_HOME}"
    when "false"
        apps = do_cmd("(get-childitem #{env('PS_CFG_HOME')}/appserv/*/psappsrv.ubx | Format-Table -property FullName -HideTableHeaders | Out-String).Trim()",false).split(/\n+/)
    else
        apps = do_cmd("(get-childitem #{PS_MULTI_HOME}/*/appserv/*/psappsrv.ubx | Format-Table -property FullName -HideTableHeaders | Out-String).Trim()",false).split(/\n+/)
    end
    apps.map! {|app| app.split('\\')[-2]}
end

def find_prcss_win
    case "#{PS_MULTI_HOME}"
    when "false"
        prcss = do_cmd("(get-childitem #{env('PS_CFG_HOME')}/appserv/prcs/*/psprcsrv.ubx | Format-Table -property FullName -HideTableHeaders | Out-String).Trim()",false).split(/\n+/)
    else
        prcss = do_cmd("(get-childitem #{PS_MULTI_HOME}/*/appserv/prcs/*/psprcsrv.ubx | Format-Table -property FullName -HideTableHeaders | Out-String).Trim()",false).split(/\n+/)
    end
    prcss.map! {|prcs| prcs.split("\\")[-2]}
end

def find_webs_win
    case "#{PS_MULTI_HOME}"
    when "false"
        webs = do_cmd("(get-childitem #{env('PS_CFG_HOME')}/webserv/*/piaconfig | Format-Table -property FullName -HideTableHeaders | Out-String).Trim()",false).split(/\n+/)
    else
        webs = do_cmd("(get-childitem #{PS_MULTI_HOME}/*/webserv/*/piaconfig | Format-Table -property FullName -HideTableHeaders | Out-String).Trim()",false).split(/\n+/)
    end
    webs.map! {|web| web.split("\\")[-2]}
end

def find_apps
    apps = "#{OS_CONST}" == "linux" ? find_apps_nix : find_apps_win
end

def find_prcss
    prcss = "#{OS_CONST}" == "linux" ? find_prcss_nix : find_prcss_win
end

def find_webs
    webs = "#{OS_CONST}" == "linux" ? find_webs_nix : find_webs_win
end

def do_util
    puts "TODO: util"
end

def do_admin
    do_cmd("#{PS_PSADMIN_PATH}/psadmin") 
end

def do_list
    puts "---"
    print "hostname:        " ; do_cmd('hostname')
    print "ps-home:         " ; do_cmd('echo ' + env('PS_HOME'))
    if PS_MULTI_HOME == "false" 
        print "ps-cfg-home:     " ; do_cmd('echo ' + env('PS_CFG_HOME'))
    end
    puts ""
    puts "PS_RUNTIME_USER:   #{PS_RUNTIME_USER}"
    puts "PS_PSA_SUDO:       #{PS_PSA_SUDO}"
    puts "PS_HOOK_INTERP:    #{PS_HOOK_INTERP}"
    puts "PS_HOOK_PRE:       #{PS_HOOK_PRE}"
    puts "PS_HOOK_POST:      #{PS_HOOK_POST}"
    puts "PS_HOOK_START:     #{PS_HOOK_START}"
    puts "PS_HOOK_STOP:      #{PS_HOOK_STOP}"
    puts "PS_HEALTH_FILE:    #{PS_HEALTH_FILE}"
    puts "PS_HEALTH_TIME:    #{PS_HEALTH_TIME}"
    puts "PS_HEALTH_TEXT:    #{PS_HEALTH_TEXT}"
    puts "PS_WIN_SERVICES:   #{PS_WIN_SERVICES}"
    puts "PS_MULTI_HOME:     #{PS_MULTI_HOME}"
    puts "PS_PARALLEL_BOOT:  #{PS_PARALLEL_BOOT}"
    puts "PS_PSA_DEBUG:      #{PS_PSA_DEBUG}"
    puts "" 
    puts "app:"
    find_apps.each do |a|
        puts "  - #{a}"
    end
    puts ""
    puts "prcs:"
    find_prcss.each do |p|
        puts "  - #{p}"
    end
    puts ""
    puts "web:"
    find_webs.each do |w|
        puts "  - #{w}"
    end
    puts ""
end

def do_summary
    if "#{PS_MULTI_HOME}" != "false"
        ENV['PS_CFG_HOME'] = "#{PS_MULTI_HOME}/#{domain}"
    end

    do_cmd("#{PS_PSADMIN_PATH}/psadmin -envsummary")
    #do_status("web","all")
end

def do_status(type, domain)
    if "#{PS_MULTI_HOME}" != "false"
        ENV['PS_CFG_HOME'] = "#{PS_MULTI_HOME}/#{domain}"
    end

    case type
    when "app"
        do_cmd("#{PS_PSADMIN_PATH}/psadmin -c sstatus -d #{domain}")
        do_cmd("#{PS_PSADMIN_PATH}/psadmin -c cstatus -d #{domain}")
        do_cmd("#{PS_PSADMIN_PATH}/psadmin -c qstatus -d #{domain}")
        do_cmd("#{PS_PSADMIN_PATH}/psadmin -c pslist -d #{domain}")
    when "prcs"
        do_cmd("#{PS_PSADMIN_PATH}/psadmin -p status -d #{domain}")
    when "web"
        do_cmd("#{PS_PSADMIN_PATH}/psadmin -w status -d #{domain}")
    else
        puts "Invalid type, see psa help"
    end
end

def do_start(type, domain)
    if "#{PS_MULTI_HOME}" != "false"
        ENV['PS_CFG_HOME'] = "#{PS_MULTI_HOME}/#{domain}"
    end

    web_service_name    = ENV['WEB_SERVICE_NAME'] || "Psft*Pia*#{domain}*"
    app_service_name    = ENV['APP_SERVICE_NAME'] || "Psft*App*#{domain}*"
    prcs_service_name   = ENV['PRCS_SERVICE_NAME'] || "Psft*Prcs*#{domain}*"

    case "#{PS_PARALLEL_BOOT}"
    when "false"
        start_app_cmd = "#{PS_PSADMIN_PATH}/psadmin -c boot -d #{domain}"
    when "true"
        start_app_cmd = "#{PS_PSADMIN_PATH}/psadmin -c parallelboot -d #{domain}"
    end
    start_app_service_cmd = "start-service #{app_service_name}"
    start_prcs_cmd = "#{PS_PSADMIN_PATH}/psadmin -p start -d #{domain}"
    start_prcs_service_cmd = "start-service #{prcs_service_name}"   
    start_web_cmd_lnx = "${PS_CFG_HOME?}/webserv/#{domain}/bin/startPIA.sh"
    start_web_cmd_win = "#{PS_PSADMIN_PATH}/psadmin -w start -d #{domain}"
    start_web_service_cmd = "start-service #{web_service_name}"

    # 10-08-2020 Dale Haman: Changing the logic used on PS_WIN_SERVICES, it will never be tux, app or all.
    case type
    when "app"
        case "#{PS_WIN_SERVICES}"
        when "true", "tux", "app", "all"
            do_cmd(start_app_service_cmd)
        else
            do_cmd(start_app_cmd)
            case "#{PS_TRAIL_SERVICE}"
            when "true"
                do_cmd(start_app_service_cmd)
            end
        end
        do_hookstart("start",type,domain)
    when "prcs"
        case "#{PS_WIN_SERVICES}"
        when "true", "tux", "prcs", "all"
            do_cmd(start_prcs_service_cmd)
        else
            do_cmd(start_prcs_cmd)
            case "#{PS_TRAIL_SERVICE}"
            when "true"
                do_cmd(start_prcs_service_cmd)
            end
        end
        do_hookstart("start",type,domain)
    when "web"
        case "#{OS_CONST}"
        when "linux"
            if File.exist?("#{ENV['PS_CFG_HOME']}/webserv/#{domain}/servers/PIA/tmp/PIA.lok")
                puts "Domain #{domain} already started"
            else
                do_cmd(start_web_cmd_lnx)
                sleep 5.0
            end
        when "windows"
            case "#{PS_WIN_SERVICES}"
            when "true", "web", "all"
                do_cmd(start_web_service_cmd)
            else
                # Run command outside of powershell with 'false' parameter
                do_cmd(start_web_cmd_win, true, false)
                case "#{PS_TRAIL_SERVICE}"
                when "true", "web", "all"
                    do_cmd(start_web_service_cmd)
                end
            end
        end
        do_hookstart("start",type,domain)
    else
        puts "Invalid type, see psa help"
    end
end

def do_stop(type, domain)
    if "#{PS_MULTI_HOME}" != "false"
        ENV['PS_CFG_HOME'] = "#{PS_MULTI_HOME}/#{domain}"
    end
    
    web_service_name    = ENV['WEB_SERVICE_NAME'] || "Psft*Pia*#{domain}*"
    app_service_name    = ENV['APP_SERVICE_NAME'] || "Psft*App*#{domain}*"
    prcs_service_name   = ENV['PRCS_SERVICE_NAME'] || "Psft*Prcs*#{domain}*"

    stop_app_cmd = "#{PS_PSADMIN_PATH}/psadmin -c shutdown -d #{domain}"
    stop_app_service_cmd = "stop-service #{app_service_name}"
    stop_prcs_cmd = "#{PS_PSADMIN_PATH}/psadmin -p stop -d #{domain}"
    stop_prcs_service_cmd = "stop-service #{prcs_service_name}"   
    stop_web_cmd_lnx = "${PS_CFG_HOME?}/webserv/#{domain}/bin/stopPIA.sh"
    stop_web_cmd_win = "#{PS_PSADMIN_PATH}/psadmin -w shutdown -d #{domain}"
    stop_web_service_cmd = "stop-service #{web_service_name}"

    case type
    when "app"
        do_hookstop("stop",type,domain)
        case "#{PS_WIN_SERVICES}"
        when "true"
            do_cmd(stop_app_service_cmd)
        else
            do_cmd(stop_app_cmd)
            case "#{PS_TRAIL_SERVICE}"
            when "true"
                do_cmd(stop_app_service_cmd)
            end
        end
    when "prcs"
        do_hookstop("stop",type,domain)
        case "#{PS_WIN_SERVICES}"
        when "true"
            do_cmd(stop_prcs_service_cmd)
        else
            do_cmd(stop_prcs_cmd)
            case "#{PS_TRAIL_SERVICE}"
            when "true"
                do_cmd(stop_prcs_service_cmd)
            end
        end
    when "web"
        do_hookstop("stop",type,domain)
        case "#{OS_CONST}"
        when "linux"
            do_cmd(stop_web_cmd_lnx)
        when "windows"
            case "#{PS_WIN_SERVICES}"
            when "true"
                do_cmd(stop_web_service_cmd)
            else
                do_cmd(stop_web_cmd_win, true, false)
                case "#{PS_TRAIL_SERVICE}"
                when "true"
                    do_cmd(stop_web_service_cmd)
                end
            end
        end
    else
        puts "Invalid type, see psa help"
    end
end

def do_kill(type, domain)
    if "#{PS_MULTI_HOME}" != "false"
        ENV['PS_CFG_HOME'] = "#{PS_MULTI_HOME}/#{domain}"
    end

    case type
    when "app"
        do_cmd("#{PS_PSADMIN_PATH}/psadmin -c shutdown! -d #{domain}")
    when "prcs"
        do_cmd("#{PS_PSADMIN_PATH}/psadmin -p kill -d #{domain}")
    when "web"
        case "#{OS_CONST}"
        when "windows"
            do_cmd("(gwmi win32_process | where {$_.Name -eq 'Java.exe'} | where {$_.CommandLine -match '#{domain}'}).ProcessId  -ErrorAction SilentlyContinue | % { stop-process $_ -force } -ErrorAction SilentlyContinue")
        when "linux"
            return #kill n/a
        end
    else
        puts "Invalid type, see psa help"
    end
end

def do_configure(type, domain)
    if "#{PS_MULTI_HOME}" != "false"
        ENV['PS_CFG_HOME'] = "#{PS_MULTI_HOME}/#{domain}"
    end

    case type
    when "app"
        do_cmd("#{PS_PSADMIN_PATH}/psadmin -c configure -d #{domain}")
    when "prcs"
        do_cmd("#{PS_PSADMIN_PATH}/psadmin -p configure -d #{domain}")
    when "web"
        return # web configure n/a
    else
        puts "Invalid type, see psa help"
    end
end

def do_purge(type, domain)
    if "#{PS_MULTI_HOME}" != "false"
        ENV['PS_CFG_HOME'] = "#{PS_MULTI_HOME}/#{domain}"
    end

    case type
    when "app"
        do_cmd("#{PS_PSADMIN_PATH}/psadmin -c purge -d #{domain}")
    when "prcs"
        do_cmd("echo purge todo")
    when "web"
        case "#{OS_CONST}"
        when "linux"
            do_cmd("rm -rf ${PS_CFG_HOME?}/webserv/#{domain}/applications/peoplesoft/PORTAL*/*/cache*/")
            puts "web cache purged"
        when "windows"
            do_cmd("Remove-Item $(Get-ChildItem ${env:PS_CFG_HOME}/webserv/#{domain}/applications/peoplesoft/PORTAL*/*/cache*/ | ?{ $_.PSIsContainer}) -recurse -force -ErrorAction SilentlyContinue".gsub('/','\\'))
        end
    else
        puts "Invalid type, see psa help"
    end
end

def do_flush(type, domain)
    if "#{PS_MULTI_HOME}" != "false"
        ENV['PS_CFG_HOME'] = "#{PS_MULTI_HOME}/#{domain}"
    end

    case type
    when "app"
        do_cmd("#{PS_PSADMIN_PATH}/psadmin -c cleanipc -d #{domain}")
    when "prcs"
        do_cmd("#{PS_PSADMIN_PATH}/psadmin -p cleanipc -d #{domain}")
    when "web"
        return # web flush n/a
    else
        puts "Invalid type, see psa help"
    end
end

def do_restart(type, domain)
    do_stop(type, domain)
    do_start(type, domain)
end

def do_reconfigure(type, domain)
    do_stop(type, domain)
    do_configure(type, domain)
    do_start(type, domain)
end

def do_bounce(type, domain)
    do_stop(type, domain)
    do_purge(type, domain)
    do_flush(type, domain)
    do_configure(type, domain)
    do_start(type, domain)
end

def do_hook(command, type, domain, script) 
    ENV['PSA_CMD'] = command
    ENV['PSA_TYPE'] = type
    ENV['PSA_DOMAIN'] = domain
    out = `#{PS_HOOK_INTERP} #{script}`
    puts out
end 

def do_hookpre(command, type, domain) 
    if "#{PS_HOOK_PRE}" != "false"    
        "#{PS_PSA_DEBUG}" == "true" ? (puts "Executing domain pre command hook...\n\n") : nil
        do_hook(command, type, domain, PS_HOOK_PRE)
        "#{PS_PSA_DEBUG}" == "true" ? (puts "\n...hook done") : nil
        end
end 

def do_hookpost(command, type, domain) 
    if "#{PS_HOOK_POST}" != "false"    
        "#{PS_PSA_DEBUG}" == "true" ? (puts "Executing domain post command hook...\n\n") : nil
        do_hook(command, type, domain, PS_HOOK_POST)
        "#{PS_PSA_DEBUG}" == "true" ? (puts "\n...hook done") : nil
    end
end 

def do_hookstart(command, type, domain) 
    if "#{PS_HOOK_START}" != "false"    
        "#{PS_PSA_DEBUG}" == "true" ? (puts "Executing domain start hook...\n\n") : nil
        do_hook(command, type, domain, PS_HOOK_START)
        "#{PS_PSA_DEBUG}" == "true" ? (puts "\n...hook done") : nil
    end
end 

def do_hookstop(command, type, domain) 
    if "#{PS_HOOK_STOP}" != "false"    
        "#{PS_PSA_DEBUG}" == "true" ? (puts "Executing domain stop hook...\n\n") : nil
        do_hook(command, type, domain, PS_HOOK_STOP)
        "#{PS_PSA_DEBUG}" == "true" ? (puts "\n...hook done") : nil
    end
end



def os
    @os ||= (
        host_os = RbConfig::CONFIG['host_os']
            case host_os
            when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
                :windows
            when /darwin|mac os/
                :macosx
            when /linux/
                :linux
            when /solaris|bsd/
                :unix
            else
                raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
            end
     )
end
