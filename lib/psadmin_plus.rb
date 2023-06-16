#!/usr/bin/env ruby

require 'rbconfig'
require 'etc'
require 'open3'
require 'logger'
require_relative 'runner'

module PsadminPlus

    @@logger = Logger.new($stdout)
    @@logger.level = ENV['PS_PSA_DEBUG'] || "INFO"
    @@logger.formatter = proc do |severity, datetime, progname, msg|
        date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
        case severity
        when "INFO"
            green(severity.ljust(5)) + ": #{msg} \n"
        when "DEBUG"
            blue(severity.ljust(5)) + ": #{msg} \n"
        when "ERROR"
            red(severity.ljust(5)) + ": #{msg} \n"
        end
    end

    def do_help
        puts "Usage: psa [command] <type> <domain>"
        puts " "
        puts "Commands:"
        puts "        "
        puts "    help           display this help message"
        puts "    list           list domains"
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
        puts "    all,<blank>    act on web, app, and prcs domains"
        puts "    pubsub         (status only) PUBSUB group status"
        puts "    tux            (status only) Tuxedo Queue status"
        puts "        "
        puts "Domains:"
        puts "        "
        puts "    dom            act on specific domains"
        puts "    all,<blank>    act on all domains"
        puts " "
        puts "Each parameter type can be enter in a comma separated list "
        puts " "
    end

    def colorize(text, color_code); "\e[#{color_code}m#{text}\e[0m"; end
    def red(text);    colorize(text, 31);  end
    def green(text);  colorize(text, 32);  end
    def blue(text);   colorize(text, 34);  end
    def info(msg);    @@logger.info(msg);  end
    def debug(msg);   @@logger.debug(msg); end
    def error(msg);   @@logger.error(msg); end

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

    def do_is_runtime_user_nix
        result = ENV['USER'] == PS_RUNTIME_USER ? true : false
    end

    def do_is_runtime_user_win
        result = ENV['USERNAME'] == PS_RUNTIME_USER ? true : false
    end

    def env(var)
        result = "#{OS_CONST}" == "linux" ? "${#{var}}" : "${env:#{var}}" #"%#{var}%"
    end

    def do_cmd(cmd:, internal: false)
        if internal
            output = "off"
        else
            output = PS_PSA_OUTPUT
        end
        prefix = ""
        suffix = ""
        case "#{OS_CONST}"
        when "linux"
            if do_is_runtime_user_nix
                # No prefix/suffix needed
            else
                if "#{PS_PSA_SUDO}" == "on"
                    prefix = "sudo su - #{PS_RUNTIME_USER} -c '"
                    suffix = "'"
                else
                    prefix = "su - #{PS_RUNTIME_USER} -c '"
                    suffix = "'"
                end
            end
        when "windows"
            prefix = "powershell -NoProfile -Command \""
            suffix = "\""
        else
            puts "Invalid OS"
        end

        debug "Command: #{prefix}#{cmd}#{suffix}"
        runner = Runner.new("#{prefix}#{cmd}#{suffix}", realtime = output)
        runner.run

        # "internal" is used to bypass output processing for psa internal functions
        if internal
            debug "internal output"
            runner.stdout
        else
            debug "processing output"
            process_output(stdout: runner.stdout, stderr: runner.stderr, success:runner.success?)
        end
    end

    def process_output(stdout:, stderr:, success:)
        if PS_PSA_OUTPUT == "summary"
            debug "summary output - stdout"
            print_std(std: stdout)
            debug "summary output - stderr"
            print_std(std: stderr, summary: true)
            
        end

        case success
        when true
            debug "command success"
        when false
            do_output("psadmin returned an error", true)
            if PS_PSA_OUTPUT == "summary" || PS_PSA_OUTPUT == "quiet"
                print_std(std:stderr, err: true)
            end
            exit 1
        end
    end

    def print_std(std:, err: false, summary: false)
        # Standard Output
        *lines = std.split(/\n/)
        lines.each do | line |
            if summary
                if line_matches(line)
                    do_output(line, err)
                end
            else
                do_output(line, err)
            end
        end
    end

    def line_matches(line)
        debug "matching lines for summary output"
        line.include?("processes started") || 
        line.include?("process started") || 
        line.include?("processes stopped")
    end

    def do_output(line, err = false)
        utctime = ""
        # Handle Output - Check if timestamps are requested
        # - override if parameter is "internal" for internal calls
        case PS_PSA_TIMESTAMP
        when "true"
            utctime = Time.now.strftime("[%Y-%m-%d %H:%M:%S] ")
        end
        
        if !line.empty?
            if line != '> '
                if !err
                    puts (utctime + line).gsub('"', '')
                else
                    puts (utctime + red(line)).gsub('"', '')
                end
            end
        end
    end

    def do_cmd_banner(c,t,d)
        if PS_PSA_NO_BANNER != "true"
            puts ""
            puts "===[ #{c} . #{t} . #{d} ]==="
            puts ""
        end
    end

    def do_set_cfg_home(d)
        if "#{PS_MULTI_HOME}" != "false"
            if PS_MULTI_PREFIX > 0
                h = d.slice(0..PS_MULTI_PREFIX)
            else
                h = d
            end
            ENV['PS_CFG_HOME'] = "#{PS_MULTI_HOME}#{PS_MULTI_DELIMIT}#{h}"
        end
    end

    def find_apps_nix
        case "#{PS_MULTI_HOME}"
        when "false"
            apps = do_cmd(cmd: "find #{env('PS_CFG_HOME')}/appserv/*/psappsrv.ubx 2>/dev/null",internal: true).split(/\n+/)
        else
            apps = do_cmd(cmd: "find #{PS_MULTI_HOME}#{PS_MULTI_DELIMIT}*/appserv/*/psappsrv.ubx 2>/dev/null",internal: true).split(/\n+/)
        end
        apps.map! {|app| app.split("/")[-2]}
    end

    def find_prcss_nix
        case "#{PS_MULTI_HOME}"
        when "false"
            prcss = do_cmd(cmd: "find #{env('PS_CFG_HOME')}/appserv/prcs/*/psprcsrv.ubx 2>/dev/null",internal: true).split(/\n+/)
        else 
            prcss = do_cmd(cmd: "find #{PS_MULTI_HOME}#{PS_MULTI_DELIMIT}*/appserv/prcs/*/psprcsrv.ubx 2>/dev/null",internal: true).split(/\n+/)
        end
        prcss.map! {|prcs| prcs.split("/")[-2]}
    end

    def find_webs_nix
        case "#{PS_MULTI_HOME}"
        when "false"
            webs = do_cmd(cmd: "find #{env('PS_CFG_HOME')}/webserv/*/piaconfig -maxdepth 0",internal: true).split(/\n+/)
        else
            webs = do_cmd(cmd: "find #{PS_MULTI_HOME}#{PS_MULTI_DELIMIT}*/webserv/*/piaconfig -maxdepth 0",internal: true).split(/\n+/)
        end
        webs.map! {|web| web.split("/")[-2]}
    end

    def find_sites_nix(domain)
        webs = do_cmd(cmd: "find ${PS_CFG_HOME?}/webserv/#{domain}/applications/peoplesoft/PORTAL.war/WEB-INF/psftdocs/* -maxdepth 0",internal: true).split(/\n+/)
        webs.map! {|site| site.split("/")[-1]}
    end

    def find_apps_win
        case "#{PS_MULTI_HOME}"
        when "false"
            apps = do_cmd(cmd: "(get-childitem #{env('PS_CFG_HOME')}/appserv/*/psappsrv.ubx | Format-Table -property FullName -HideTableHeaders | Out-String).Trim()",internal: true).split(/\n+/)
        else
            apps = do_cmd(cmd: "(get-childitem #{PS_MULTI_HOME}#{PS_MULTI_DELIMIT}*/appserv/*/psappsrv.ubx | Format-Table -property FullName -HideTableHeaders | Out-String).Trim()",internal: true).split(/\n+/)
        end
        apps.map! {|app| app.split('\\')[-2]}
    end

    def find_prcss_win
        case "#{PS_MULTI_HOME}"
        when "false"
            prcss = do_cmd(cmd: "(get-childitem #{env('PS_CFG_HOME')}/appserv/prcs/*/psprcsrv.ubx | Format-Table -property FullName -HideTableHeaders | Out-String).Trim()",).split(/\n+/)
        else
            prcss = do_cmd(cmd: "(get-childitem #{PS_MULTI_HOME}#{PS_MULTI_DELIMIT}*/appserv/prcs/*/psprcsrv.ubx | Format-Table -property FullName -HideTableHeaders | Out-String).Trim()",internal: true).split(/\n+/)
        end
        prcss.map! {|prcs| prcs.split("\\")[-2]}
    end

    def find_webs_win
        case "#{PS_MULTI_HOME}"
        when "false"
            webs = do_cmd(cmd: "(get-childitem #{env('PS_CFG_HOME')}/webserv/*/piaconfig | Format-Table -property FullName -HideTableHeaders | Out-String).Trim()",internal: true).split(/\n+/)
        else
            webs = do_cmd(cmd: "(get-childitem #{PS_MULTI_HOME}#{PS_MULTI_DELIMIT}*/webserv/*/piaconfig | Format-Table -property FullName -HideTableHeaders | Out-String).Trim()",internal: true).split(/\n+/)
        end
        webs.map! {|web| web.split("\\")[-2]}
    end

    def find_sites_win(domain)
        #TODO
        #sites = do_cmd(cmd: "(get-childitem #{env('PS_CFG_HOME')}/webserv/#{domain}/applications/peoplesoft/PORTAL.war/WEB-INF/psftdocs | Format-Table -property FullName -HideTableHeaders | Out-String).Trim()",false).split(/\n+/)
        #sites.map! {|site| site.split("\\")[-2]}
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

    def find_sites(domain)
        sites = "#{OS_CONST}" == "linux" ? find_sites_nix(domain) : find_sites_win(domain)
    end

    def do_util
        puts "TODO: util"
    end

    def do_admin
        do_cmd(cmd: "#{PS_PSADMIN_PATH}/psadmin") 
    end

    def do_list
        puts "---"
        print "hostname:          " ; do_cmd(cmd:'hostname')
        print "ps-home:           " ; do_cmd(cmd:'echo ' + env('PS_HOME'))
        if PS_MULTI_HOME == "false" 
            print "ps-cfg-home:       " ; do_cmd(cmd:'echo ' + env('PS_CFG_HOME'))
        else
            puts "ps-cfg-home base:  #{PS_MULTI_HOME}#{PS_MULTI_DELIMIT}*"  
        end
        puts ""
        puts "PS_RUNTIME_USER:   #{PS_RUNTIME_USER}"
        puts "PS_PSA_SUDO:       #{PS_PSA_SUDO}"
        puts "PS_HOOK_INTERP:    #{PS_HOOK_INTERP}"
        puts "PS_HOOK_PRE:       #{PS_HOOK_PRE}"
        puts "PS_HOOK_POST:      #{PS_HOOK_POST}"
        puts "PS_HOOK_START:     #{PS_HOOK_START}"
        puts "PS_HOOK_STOP:      #{PS_HOOK_STOP}"
        puts "PS_WIN_SERVICES:   #{PS_WIN_SERVICES}"
        puts "PS_MULTI_HOME:     #{PS_MULTI_HOME}"
        puts "PS_PARALLEL_BOOT:  #{PS_PARALLEL_BOOT}"
        puts "PS_PSA_DEBUG:      #{PS_PSA_DEBUG}"
        puts "PS_PSA_TIMETAMP:   #{PS_PSA_TIMESTAMP}"
        puts "PS_PSA_OUTPUT:     #{PS_PSA_OUTPUT}"
        puts "PS_PSA_NO_BANNER:  #{PS_PSA_NO_BANNER}"
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

    def do_psadmin_check
        # Check to see if psadmin loads correctly
        # This will help when used on web servers that don't have Tuxedo
        debug "Checking psadmin version to validate configuration:"
        check = do_cmd(cmd: "#{PS_PSADMIN_PATH}/psadmin -v 2>&1", internal: true)
        if check.include? "error"
            # psadmin config is NOT valid
            do_output("ERROR: psadmin is not configured correctly for this environment!")
            do_output("       Some psadmin-plus actions only work when Tuxedo and psadmin are configured")
            false
        else
            # psadmin config is valid
            true
        end 
    end

    def do_summary
        if "#{PS_MULTI_HOME}" != "false"
            ENV['PS_CFG_HOME'] = "#{PS_MULTI_HOME}#{PS_MULTI_DELIMIT}#{domain}"
        end

        do_psadmin_check ? nil : exit

        do_cmd(cmd: "#{PS_PSADMIN_PATH}/psadmin -envsummary")
        #do_status("web","all")
    end

    def do_status(type, domain)
        case type
        when "app"
            do_psadmin_check ? nil : return
            do_cmd(cmd: "#{PS_PSADMIN_PATH}/psadmin -c sstatus -d #{domain}")
            do_cmd(cmd: "#{PS_PSADMIN_PATH}/psadmin -c cstatus -d #{domain}")
            do_cmd(cmd: "#{PS_PSADMIN_PATH}/psadmin -c qstatus -d #{domain}")
            do_cmd(cmd: "#{PS_PSADMIN_PATH}/psadmin -c pslist -d #{domain}")
        when "tux"
            do_psadmin_check ? nil : return
            case "#{OS_CONST}"
            when "linux"
                do_cmd(cmd: "export TUXCONFIG=#{env('PS_CFG_HOME')}/appserv/#{domain}/PSTUXCFG && echo pq | " + env('TUXDIR') + "/bin/tmadmin -r ")
            when "windows"
                do_cmd(cmd: "cmd /c 'set TUXCONFIG=\"#{ENV['PS_CFG_HOME']}/appserv/#{domain}/PSTUXCFG\" & echo 'pq' | " + env('TUXDIR') + "/bin/tmadmin -r '")
            end
        when "pubsub"
            do_psadmin_check ? nil : return
            case "#{OS_CONST}"
            when "linux"
                do_cmd(cmd: OS_SETENV + "TUXCONFIG=#{env('PS_CFG_HOME')}/appserv/#{domain}/PSTUXCFG " + OS_JOIN + " echo printserver -g PUBSUB | " + env('TUXDIR') + "/bin/tmadmin -r")
            when "windows"
                do_cmd(cmd: "$env:TUXCONFIG=\"#{ENV['PS_CFG_HOME']}/appserv/#{domain}/PSTUXCFG\";  'printserver -g PUBSUB' | . " + env('TUXDIR') + "/bin/tmadmin -r")
            end
        when "prcs"
            do_psadmin_check ? nil : return
            do_cmd(cmd: "#{PS_PSADMIN_PATH}/psadmin -p status -d #{domain}")
        when "web"
            # TODO - PIA script status? 1. psadmin, 2. script, 3. lock file, 4. service
            #do_psadmin_check ? nil : return
            do_cmd(cmd: "#{PS_PSADMIN_PATH}/psadmin -w status -d #{domain}")
            #do_cmd(cmd: "${PS_CFG_HOME?}/webserv/#{domain}/bin/singleserverStatus.sh")
            #if File.exist?("#{ENV['PS_CFG_HOME']}/webserv/#{domain}/servers/PIA/tmp/PIA.lok")
        else
            puts "Invalid type, see psa help"
        end
    end

    def do_start(type, domain)
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

        case type
        when "app"
            case "#{PS_WIN_SERVICES}"
            when "true", "tux", "app", "all"
                do_cmd(cmd: start_app_service_cmd)
            else
                do_cmd(cmd: start_app_cmd)
                case "#{PS_TRAIL_SERVICE}"
                when "true"
                    do_cmd(cmd: start_app_service_cmd)
                end
            end
            do_hookstart("start",type,domain)
        when "pubsub"
            case "#{OS_CONST}"
            when "linux"
                do_cmd(cmd: OS_SETENV + "TUXCONFIG=#{env('PS_CFG_HOME')}/appserv/#{domain}/PSTUXCFG " + OS_JOIN + " echo boot -g PUBSUB | " + env('TUXDIR') + "/bin/tmadmin -r")
            when "windows"
                do_cmd(cmd: "$env:TUXCONFIG=\"#{ENV['PS_CFG_HOME']}/appserv/#{domain}/PSTUXCFG\"; 'boot -g PUBSUB' | . " + env('TUXDIR') + "/bin/tmadmin -r")
            end
        when "prcs"
            case "#{PS_WIN_SERVICES}"
            when "true", "tux", "prcs", "all"
                do_cmd(cmd: start_prcs_service_cmd)
            else
                do_cmd(cmd: start_prcs_cmd)
                case "#{PS_TRAIL_SERVICE}"
                when "true"
                    do_cmd(cmd: start_prcs_service_cmd)
                end
            end
            do_hookstart("start",type,domain)
        when "web"
            case "#{OS_CONST}"
            when "linux"
                if File.exist?("#{ENV['PS_CFG_HOME']}/webserv/#{domain}/servers/PIA/tmp/PIA.lok")
                    puts "Domain #{domain} already started"
                else
                    do_cmd(cmd: start_web_cmd_lnx)
                    sleep 5.0
                end
            when "windows"
                case "#{PS_WIN_SERVICES}"
                when "true", "web", "all"
                    do_cmd(cmd: start_web_service_cmd)
                else
                    # Run command outside of powershell with 'false' parameter - use powershell now
                    do_cmd(cmd: start_web_cmd_win)
                    case "#{PS_TRAIL_SERVICE}"
                    when "true", "web", "all"
                        do_cmd(cmd: start_web_service_cmd)
                    end
                end
            end
            do_hookstart("start",type,domain)
        else
            puts "Invalid type, see psa help"
        end
    end

    def do_stop(type, domain)    
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
                do_cmd(cmd: stop_app_service_cmd)
            else
                do_cmd(cmd: stop_app_cmd)
                case "#{PS_TRAIL_SERVICE}"
                when "true"
                    do_cmd(cmd: stop_app_service_cmd)
                end
            end
        when "pubsub"
            do_cmd(cmd: "export TUXCONFIG=#{env('PS_CFG_HOME')}/appserv/#{domain}/PSTUXCFG && echo shutdown -g PUBSUB | " + env('TUXDIR') + "/bin/tmadmin -r")
        when "prcs"
            do_hookstop("stop",type,domain)
            case "#{PS_WIN_SERVICES}"
            when "true"
                do_cmd(cmd: stop_prcs_service_cmd)
            else
                do_cmd(cmd: stop_prcs_cmd)
                case "#{PS_TRAIL_SERVICE}"
                when "true"
                    do_cmd(cmd: stop_prcs_service_cmd)
                end
            end
        when "web"
            do_hookstop("stop",type,domain)
            case "#{OS_CONST}"
            when "linux"
                do_cmd(cmd: stop_web_cmd_lnx)
            when "windows"
                case "#{PS_WIN_SERVICES}"
                when "true"
                    do_cmd(cmd: stop_web_service_cmd)
                else
                    do_cmd(cmd: stop_web_cmd_win)
                    case "#{PS_TRAIL_SERVICE}"
                    when "true"
                        do_cmd(cmd: stop_web_service_cmd)
                    end
                end
            end
        else
            puts "Invalid type, see psa help"
        end
    end

    def do_kill(type, domain)
        case type
        when "app"
            do_cmd(cmd: "#{PS_PSADMIN_PATH}/psadmin -c shutdown! -d #{domain}")
        when "prcs"
            do_cmd(cmd: "#{PS_PSADMIN_PATH}/psadmin -p kill -d #{domain}")
        when "web"
            case "#{OS_CONST}"
            when "windows"
                do_cmd(cmd: "(gwmi win32_process | where {$_.Name -eq 'Java.exe'} | where {$_.CommandLine -match '#{domain}'}).ProcessId  -ErrorAction SilentlyContinue | % { stop-process $_ -force } -ErrorAction SilentlyContinue")
            when "linux"
                do_cmd(cmd: "kill $(ps aux|grep java|grep ${PS_CFG_HOME?}/webserv/#{domain}/piaconfig|awk ' {print $2}')")
            end
        else
            puts "Invalid type, see psa help"
        end
    end

    def do_configure(type, domain)
        case type
        when "app"
            do_cmd(cmd: "#{PS_PSADMIN_PATH}/psadmin -c configure -d #{domain}")
        when "prcs"
            do_cmd(cmd: "#{PS_PSADMIN_PATH}/psadmin -p configure -d #{domain}")
        when "web"
            do_webprof_reload("#{domain}")
        else
            puts "Invalid type, see psa help"
        end
    end

    def do_purge(type, domain)
        case type
        when "app"
            do_cmd(cmd: "#{PS_PSADMIN_PATH}/psadmin -c purge -d #{domain}")
        when "prcs"
            case "#{OS_CONST}"
            when "linux"
                do_cmd(cmd: "rm -rf ${PS_CFG_HOME?}/appserv/prcs/#{domain}/CACHE/*")
            when "windows"
                do_cmd(cmd: "Remove-Item $(Get-ChildItem ${env:PS_CFG_HOME}/appserv/prcs/#{domain}/CACHE/* | ?{ $_.PSIsContainer}) -recurse -force -ErrorAction SilentlyContinue".gsub('/','\\'))
            end
            puts "prcs cache purged"
        when "web"
            case "#{OS_CONST}"
            when "linux"
                do_cmd(cmd: "rm -rf ${PS_CFG_HOME?}/webserv/#{domain}/applications/peoplesoft/PORTAL*/*/cache*/")
                puts "web cache purged"
            when "windows"
                do_cmd(cmd: "Remove-Item $(Get-ChildItem ${env:PS_CFG_HOME}/webserv/#{domain}/applications/peoplesoft/PORTAL*/*/cache*/ | ?{ $_.PSIsContainer}) -recurse -force -ErrorAction SilentlyContinue".gsub('/','\\'))
            end
        else
            puts "Invalid type, see psa help"
        end
    end

    def do_flush(type, domain)
        case type
        when "app"
            do_cmd(cmd: "#{PS_PSADMIN_PATH}/psadmin -c cleanipc -d #{domain}")
        when "prcs"
            do_cmd(cmd: "#{PS_PSADMIN_PATH}/psadmin -p cleanipc -d #{domain}")
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
            debug "Executing domain pre command hook...\n\n"
            do_hook(command, type, domain, PS_HOOK_PRE)
            debug "\n...hook done"
            end
    end 

    def do_hookpost(command, type, domain) 
        if "#{PS_HOOK_POST}" != "false"    
            debug "Executing domain post command hook...\n\n"
            do_hook(command, type, domain, PS_HOOK_POST)
            debug "\n...hook done"
        end
    end 

    def do_hookstart(command, type, domain) 
        if "#{PS_HOOK_START}" != "false"    
            debug "Executing domain start hook...\n\n"
            do_hook(command, type, domain, PS_HOOK_START)
            debug "\n...hook done"
        end
    end 

    def do_hookstop(command, type, domain) 
        if "#{PS_HOOK_STOP}" != "false"    
            debug "Executing domain stop hook...\n\n"
            do_hook(command, type, domain, PS_HOOK_STOP)
            debug "\n...hook done"
        end
    end

    def do_webprof_reload(domain)
        puts "Reloading Web Profiles"

        case "#{OS_CONST}"
        when "linux"	
            "#{PS_PSA_DEBUG}" == "DEBUG" ? show_debug = true : show_debug = false

            find_sites(domain).each do |s|
                # set vars
                url = "${ADMINSERVER_PROTOCOL?}://${ADMINSERVER_HOSTNAME?}:${ADMINSERVER_PORT?}/psp/#{s}/?cmd=login&"
                src_env = ". ${PS_CFG_HOME?}/webserv/#{domain}/bin/setEnv.sh"
                prop_file = "${PS_CFG_HOME?}/webserv/#{domain}/applications/peoplesoft/PORTAL.war/WEB-INF/psftdocs/#{s}/configuration.properties"

                # set reload in config.props 
                do_cmd(cmd: "sed -i 's/ReloadWebProfileWithoutRestart=.*/ReloadWebProfileWithoutRestart=1/g' #{prop_file}")

                # source setEnv and ping site
                show_debug ? do_cmd(cmd: "#{src_env} ; curl -s #{url}") : do_cmd(cmd: "#{src_env} ; curl -s -o /dev/null #{url}")

                # unset reload in config.props
                do_cmd(cmd: "sed -i 's/ReloadWebProfileWithoutRestart=.*/ReloadWebProfileWithoutRestart=0/g' #{prop_file}")

                # done
                puts " - #{s}"
            end
        when "windows"
            puts "Windows support coming soon."		
            #do_cmd(cmd: ". #{env('PS_CFG_HOME')}/webserv/#{domain}/bin/setEnv.sh")

            #find_sites.each do |s|
        #    # set vars
            #    prop_file = "#{env('PS_CFG_HOME')}/webserv/#{domain}/applications/peoplesoft/PORTAL.war/WEB-INF/psftdocs/#{s}}/configuration.properties"
            #    url = "http://#{PS_PIA_HOST}.#{PS_PIA_DOMAIN}:#{PS_PIA_PORT}/psp/#{s}/?cmd=login&"
            #    # set reload in config.props 
            #    do_cmd(cmd: "sed -i 's/ReloadWebProfileWithoutRestart=.*/ReloadWebProfileWithoutRestart=1/g' #{prop_file}")
            #    # ping site
            #    do_cmd(cmd: "curl -s -o /dev/null '#{url}'")
            #    # unset reload in config.props
            #    do_cmd(cmd: "sed -i 's/ReloadWebProfileWithoutRestart=.*/ReloadWebProfileWithoutRestart=0/g' #{prop_file}")
            #    # done
            #    puts " - #{s}"
            #end
        else
            puts " badOS - #{OS_CONST}"
        end
        puts ""
    end

end # End Module