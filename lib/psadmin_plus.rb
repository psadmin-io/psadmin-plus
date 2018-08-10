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
    puts "    start          pooladd, if enabled, then start the domain"
    puts "    stop           poolrm, if enabled, stop the domain"
    puts "    restart        stop and start the domain"
    puts "    purge          clear domain cache"
    puts "    bounce         stop, flush, purge, configure and start the domain"
    puts "    kill           force stop the domain"
    puts "    configure      configure the domain"
    puts "    flush          clear domain IPC"
    puts "    poolrm         remove domain from load balanced pool  "
    puts "    pooladd        add domain to load balanced pool  "
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
            out = `#{cmd}`
        else
            if "#{PS_PSA_SUDO}" == "on"
                out = `sudo su - #{PS_RUNTIME_USER} -c '#{cmd}'`
            else
                print "#{PS_RUNTIME_USER} "
                out = `su - #{PS_RUNTIME_USER} -c '#{cmd}'`
            end
        end
    when "windows"
        case powershell
        when true
            out = `powershell -NoProfile -Command "#{cmd}"`
        else
            out = `#{cmd}`
        end
    else
        out = "Invalid OS"
    end
    print ? (puts out) : result = out 
end

def do_cmd_banner(c,t,d)
    puts ""
    puts "### #{c} - #{t} - #{d} ###"
end

def find_apps_nix
    apps = do_cmd("find #{env('PS_CFG_HOME')}/appserv/*/psappsrv.ubx",false).split(/\n+/)
    apps.map! {|app| app.split("/")[-2]}
end

def find_prcss_nix
    prcss = do_cmd("find #{env('PS_CFG_HOME')}/appserv/prcs/*/psprcsrv.ubx",false).split(/\n+/)
    prcss.map! {|prcs| prcs.split("/")[-2]}
end

def find_webs_nix
    webs = do_cmd("find #{env('PS_CFG_HOME')}/webserv/*/piaconfig -maxdepth 0",false).split(/\n+/)
    webs.map! {|web| web.split("/")[-2]}
end

def find_apps_win
    apps = do_cmd("(get-childitem #{env('PS_CFG_HOME')}/appserv/*/psappsrv.ubx | Format-Table -property FullName -HideTableHeaders | Out-String).Trim()",false).split(/\n+/)
    apps.map! {|app| app.split('\\')[-2]}
end

def find_prcss_win
    prcss = do_cmd("(get-childitem #{env('PS_CFG_HOME')}/appserv/prcs/*/psprcsrv.ubx | Format-Table -property FullName -HideTableHeaders | Out-String).Trim()",false).split(/\n+/)
    prcss.map! {|prcs| prcs.split("\\")[-2]}
end

def find_webs_win
    webs = do_cmd("(get-childitem #{env('PS_CFG_HOME')}/webserv/*/piaconfig | Format-Table -property FullName -HideTableHeaders | Out-String).Trim()",false).split(/\n+/)
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
    print "ps-cfg-home:     " ; do_cmd('echo ' + env('PS_CFG_HOME'))
    puts ""
    puts "PS_RUNTIME_USER: #{PS_RUNTIME_USER}"
    puts "PS_PSA_SUDO:     #{PS_PSA_SUDO}"
    puts "PS_POOL_MGMT:    #{PS_POOL_MGMT}"
    puts "PS_HEALTH_FILE:  #{PS_HEALTH_FILE}"
    puts "PS_HEALTH_TIME:  #{PS_HEALTH_TIME}"
    puts "PS_WIN_SERVICES: #{PS_WIN_SERVICES}"
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
    do_cmd("#{PS_PSADMIN_PATH}/psadmin -envsummary")
    #do_status("web","all")
end

def do_status(type, domain)
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

    web_service_name    = ENV['WEB_SERVICE_NAME'] || "Psft*Pia*#{domain}*"
    app_service_name    = ENV['APP_SERVICE_NAME'] || "Psft*App*#{domain}*"
    prcs_service_name   = ENV['PRCS_SERVICE_NAME'] || "Psft*Prcs*#{domain}*"

    case type
    when "app"
        case "#{PS_WIN_SERVICES}"
        when "true"
            do_cmd("start-service #{app_service_name}")
        else
            do_cmd("#{PS_PSADMIN_PATH}/psadmin -c boot -d #{domain}")
        end
    when "prcs"
        case "#{PS_WIN_SERVICES}"
        when "true"
            do_cmd("start-service #{prcs_service_name}")
        else
            do_cmd("#{PS_PSADMIN_PATH}/psadmin -p start -d #{domain}")
        end
    when "web"
        case "#{OS_CONST}"
        when "linux"
            do_cmd("#{PS_PSADMIN_PATH}/psadmin -w start -d #{domain}")
        when "windows"
            case "#{PS_WIN_SERVICES}"
            when "true"
                do_cmd("start-service #{web_service_name}")
            else
                do_cmd("#{PS_PSADMIN_PATH}/psadmin -w start -d #{domain}", true, false)
            end
        end
    else
        puts "Invalid type, see psa help"
    end
end

def do_stop(type, domain)
    
    web_service_name    = ENV['WEB_SERVICE_NAME'] || "Psft*Pia*#{domain}*"
    app_service_name    = ENV['APP_SERVICE_NAME'] || "Psft*App*#{domain}*"
    prcs_service_name   = ENV['PRCS_SERVICE_NAME'] || "Psft*Prcs*#{domain}*"

    case type
    when "app"
        case "#{PS_WIN_SERVICES}"
        when "true"
            do_cmd("stop-service #{app_service_name}")
        else
            do_cmd("#{PS_PSADMIN_PATH}/psadmin -c shutdown -d #{domain}")
        end
    when "prcs"
        case "#{PS_WIN_SERVICES}"
        when "true"
            do_cmd("stop-service #{prcs_service_name}")
        else
            do_cmd("#{PS_PSADMIN_PATH}/psadmin -p stop -d #{domain}")
        end
    when "web"
        case "#{OS_CONST}"
        when "linux"
            do_cmd("${PS_CFG_HOME?}/webserv/#{domain}/bin/stopPIA.sh")
        when "windows"
            case "#{PS_WIN_SERVICES}"
            when "true"
                do_cmd("stop-service #{web_service_name}")
            else
                do_cmd("#{PS_PSADMIN_PATH}/psadmin -w shutdown -d #{domain}", true, false)
            end
        end
    else
        puts "Invalid type, see psa help"
    end
end

def do_kill(type, domain)
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
            do_cmd("Remove-Item $(Get-ChildItem ${env:PS_CFG_HOME}/webserv/#{domain}/applications/peoplesoft/PORTAL*/*/cache*/ | ?{ $_.PSIsContainer}) -recurse -force".gsub('/','\\'))
        end
    else
        puts "Invalid type, see psa help"
    end
end

def do_flush(type, domain)
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

def do_bounce(type, domain)
    do_stop(type, domain)
    do_purge(type, domain)
    do_flush(type, domain)
    do_configure(type, domain)
    do_start(type, domain)
end

def do_pooladd(type, domain)
    if PS_POOL_MGMT == "on" then
        # Change this function to match your pool member addtion process
        puts "Adding web domain to load balanced pool..."
        do_cmd("echo 'true' > #{env('PS_CFG_HOME')}/webserv/#{domain}/applications/peoplesoft/PORTAL.war/#{PS_HEALTH_FILE}")
        sleep(PS_HEALTH_TIME.to_i)
        puts "...domain added to pool."
        puts ""
    else
        puts "Skipping pool managment. To enable, set PS_POOL_MGMT to 'on'."
    end
end 

def do_poolrm(type,domain)
    if PS_POOL_MGMT == "on" then
        # Change this function to match your pool member removal process
        puts "Removing domain from load balanced pool..."
        case "#{OS_CONST}"
        when "linux"
            do_cmd("rm -f #{env('PS_CFG_HOME')}/webserv/#{domain}/applications/peoplesoft/PORTAL.war/#{PS_HEALTH_FILE}")
        when "windows"
            do_cmd("remove-item -force #{env('PS_CFG_HOME')}/webserv/#{domain}/applications/peoplesoft/PORTAL.war/#{PS_HEALTH_FILE}")
        else
            puts " badOS - #{OS_CONST}"
        end
        sleep(PS_HEALTH_TIME.to_i)
        puts "...domain removed from pool."
        puts ""
    else
        puts "Skipping pool managment. To enable, set PS_POOL_MGMT to 'on'."
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
