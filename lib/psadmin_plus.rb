#!/usr/bin/env ruby

require 'rbconfig'
require 'etc'

def do_help
    puts "Usage: psa [command] <type> <domain>"
    puts " "
    puts "Commands:"
    puts "        "
    puts "    help           display this help message"
    puts "    list           list domains"
    puts "    admin          launch psadmin"
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

def do_is_runtime_user
    result = Etc.getlogin == PS_RUNTIME_USER ? true : false
end

def do_cmd(cmd)
    case "#{OS_CONST}"
    when "linux"
        if do_is_runtime_user
            out = `"#{cmd}"`
        else
            if "#{PS_PSA_SUDO}" == "on"
                out = `sudo su - #{PS_RUNTIME_USER} -c "#{cmd}"`
            else
                print "#{PS_RUNTIME_USER} "
                out = `su - #{PS_RUNTIME_USER} -c "#{cmd}"`
            end
        end
    when "windows"
        out = `"#{cmd}"`
    else
        out = "Invalid OS"
    end
    puts out
end

def find_apps
    apps = Dir.glob("#{ENV['PS_CFG_HOME']}/appserv/*/psappsrv.ubx")
    apps.map! {|app| app.split("/")[-2]}
end

def find_prcss
    prcss = Dir.glob("#{ENV['PS_CFG_HOME']}/appserv/prcs/*/psprcsrv.ubx")
    prcss.map! {|prcs| prcs.split("/")[-2]}
end

def find_webs
    webs = Dir.glob("#{ENV['PS_CFG_HOME']}/webserv/*/piaconfig")
    webs.map! {|web| web.split("/")[-2]}
end

def do_util
    puts "TODO: util"
end

def do_list
    puts "---"
    puts "hostname:      TODO"
    puts "ps-home:       #{ENV['PS_HOME']}"
    puts "ps-cfg-home:   #{ENV['PS_CFG_HOME']}"
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
    do_cmd("psadmin -envsummary")
    #do_status("web","all")
end

def do_status(type, domain)
    puts "status - #{type} - #{domain}"
    case type
    when "app"
        do_cmd("psadmin -c sstatus -d #{domain}")
        do_cmd("psadmin -c cstatus -d #{domain}")
        do_cmd("psadmin -c qstatus -d #{domain}")
        do_cmd("psadmin -c pslist -d #{domain}")
    when "prcs"
        do_cmd("psadmin -p status -d #{domain}")
    when "web"
        do_cmd("psadmin -w status -d #{domain}")
    else
        puts "Invalid type, see psa help"
    end
end

def do_start(type, domain)
    case type
    when "app"
        do_cmd("psadmin -c boot -d #{domain}")
    when "prcs"
        do_cmd("psadmin -p start -d #{domain}")
    when "web"
        do_cmd("${PS_CFG_HOME?}/webserv/#{domain}/bin/startPIA.sh")
        #psadmin -w start -d #{domain}") # TODO - this isn't working, do we want it?
    else
        puts "Invalid type, see psa help"
    end
end

def do_stop(type, domain)
    case type
    when "app"
        do_cmd("psadmin -c shutdown -d #{domain}")
    when "prcs"
        do_cmd("psadmin -p stop -d #{domain}")
    when "web"
        do_cmd("${PS_CFG_HOME?}/webserv/#{domain}/bin/stopPIA.sh")
    else
        puts "Invalid type, see psa help"
    end
end

def do_kill(type, domain)
    case type
    when "app"
        do_cmd("psadmin -c shutdown! -d #{domain}")
    when "prcs"
        do_cmd("psadmin -p kill -d #{domain}")
    when "web"
        return # web kill n/a
    else
        puts "Invalid type, see psa help"
    end
end

def do_configure(type, domain)
    case type
    when "app"
        do_cmd("psadmin -c configure -d #{domain}")
    when "prcs"
        do_cmd("psadmin -p configure -d #{domain}")
    when "web"
        return # web configure n/a
    else
        puts "Invalid type, see psa help"
    end
end

def do_purge(type, domain)
    case type
    when "app"
        do_cmd("psadmin -c purge -d #{domain}")
    when "prcs"
        do_cmd("echo purge todo")
    when "web"
        do_cmd("rm -rf ${PS_CFG_HOME?}/webserv/#{domain}/applications/peoplesoft/PORTAL*/*/cache*/")
        puts "web cache purged"
    else
        puts "Invalid type, see psa help"
    end
end

def do_flush(type, domain)
    case type
    when "app"
        do_cmd("psadmin -c cleanipc -d #{domain}")
    when "prcs"
        do_cmd("psadmin -p cleanipc -d #{domain}")
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
        do_cmd("echo 'true' > ${PS_CFG_HOME?}/webserv/#{domain}/applications/peoplesoft/PORTAL.war/${PS_HEALTH_FILE?}")
        sleep(PS_HEALTH_TIME.to_i)
        puts "...domain added to pool."
        puts ""
    else
        puts "Skipping pool managment. To enable, set $PS_POOL_MGMT to 'on'."
    end
end 

def do_poolrm(type,domain)
    if PS_POOL_MGMT == "on" then
        # Change this function to match your pool member removal process
        puts "Removing domain from load balanced pool..."
        do_cmd("rm -f \${PS_CFG_HOME?}/webserv/#{domain}/applications/peoplesoft/PORTAL.war/${PS_HEALTH_FILE?}")
        sleep(PS_HEALTH_TIME.to_i)
        puts "...domain removed from pool."
        puts ""
    else
        puts "Skipping pool managment. To enable, set $PS_POOL_MGMT to 'on'."
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
