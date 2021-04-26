# Example of removing a web server from a pool for Health Checking
# TODO - needs cleanup
if PS_POOL_MGMT == "on" then
	# Change PS_HEALTH_TEXT and PS_HEALTH_FILE variables to match your system
	puts "Removing domain from load balanced pool..."
	case "#{OS_CONST}"
	when "linux"
		do_cmd("rm -f #{env('PS_CFG_HOME')}/webserv/#{domain}/applications/peoplesoft/PORTAL.war/#{PS_HEALTH_FILE}")
	when "windows"
		do_cmd("remove-item -force #{env('PS_CFG_HOME')}/webserv/#{domain}/applications/peoplesoft/PORTAL.war/#{PS_HEALTH_FILE} -ErrorAction SilentlyContinue")
	else
		puts " badOS - #{OS_CONST}"
	end
	sleep(PS_HEALTH_TIME.to_i)
	puts "...domain removed from pool."
	puts ""
elsif PS_POOL_MGMT == "off" then
	# set to off, no message
else
	# not set, show message
	puts "Skipping pool managment. Set PS_POOL_MGMT to 'on' to enable, 'off' to hide this message."
end