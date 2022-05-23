# Example of adding a web server from a pool for Health Checking
# TODO - needs cleanup
if PS_POOL_MGMT == "on" then
	# Change PS_HEALTH_TEXT and PS_HEALTH_FILE variables to match your system
	puts "Adding web domain to load balanced pool..."
	do_cmd("echo '#{PS_HEALTH_TEXT}' > #{env('PS_CFG_HOME')}/webserv/#{domain}/applications/peoplesoft/PORTAL.war/#{PS_HEALTH_FILE}")
	sleep(PS_HEALTH_TIME.to_i)
	puts "...domain added to pool."
	puts ""
elsif PS_POOL_MGMT == "off" then
	# set to off, no message
else
	# not set, show message
	puts "Skipping pool managment. Set PS_POOL_MGMT to 'on' to enable, 'off' to hide this message."
end