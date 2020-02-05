from psadmin_plus.actions.action import Action
        
class List(Action):

    def __init__(self):
        super().__init__()

    def process(self):
        print('list is coming soon! - TODO')

""" 
    puts "---"
    print "hostname:        " ; do_cmd('hostname')
    print "ps-home:         " ; do_cmd('echo ' + env('PS_HOME'))
    if PS_MULTI_HOME == "false" 
        print "ps-cfg-home:     " ; do_cmd('echo ' + env('PS_CFG_HOME'))
    end
    puts ""
    puts "PS_RUNTIME_USER:   #{PS_RUNTIME_USER}"
    puts "PS_PSA_SUDO:       #{PS_PSA_SUDO}"
    puts "PS_POOL_MGMT:      #{PS_POOL_MGMT}"
    puts "PS_HEALTH_FILE:    #{PS_HEALTH_FILE}"
    puts "PS_HEALTH_TIME:    #{PS_HEALTH_TIME}"
    puts "PS_HEALTH_TEXT:    #{PS_HEALTH_TEXT}"
    puts "PS_WIN_SERVICES:   #{PS_WIN_SERVICES}"
    puts "PS_MULT_HOME:      #{PS_MULTI_HOME}"
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
    
"""