

#
# cd /opt/oracle/psft/pt/ps_home8.55.04 && . psconfig.sh
# PS_CFG_HOME=/home/psadm2/psft/pt/8.55


webold="peoplesoft"
webnew="new_new1"
appold="APPDOM"
appnew="APPDOM"
prcsold="PRCSDOM"
prcsnew="PRCSDOM"

#TODO ps_home?
PS_HOME="/opt/oracle/psft/pt/ps_home8.55.03"

PSCONFIGS_DIR="$HOME/psconfigs"
if [ ! -d "$PSCONFIGS_DIR" ]; then
	mkdir "$PSCONFIGS_DIR"
fi

PS_CFG_OWNER=psadm2
# TODO auto detect this
PS_PI_CFG_HOME="/home/psadm2/psft/pt/8.55"
PSCFGHOMES_DIR="$HOME/pscfghomes"
if [ ! -d "$PSCFGHOMES_DIR" ]; then
	mkdir "$PSCFGHOMES_DIR"
fi

cfgs=(dev tst) #TODO

### Create PS_CFG_HOME examples
for cfg in "${cfgs[@]}"
do
	#TODO tools version?
	if [ ! -d "$PSCFGHOMES_DIR/$cfg" ]; then
		mkdir "$PSCFGHOMES_DIR/$cfg"
	fi
done

### Create psconfig examples
for cfg in "${cfgs[@]}"
do
	#TODO template or make it?
	PSCONFIG_FILE="$PSCONFIGS_DIR/psconfig.$cfg.sh"
	> "$PSCONFIG_FILE"
	echo "export PS_CFG_HOME=$PSCFGHOMES_DIR/$cfg" >> $PSCONFIG_FILE
	echo "export PS_HOME=$PS_HOME" >> $PSCONFIG_FILE
	echo "export PS_APP_HOME=/opt/oracle/psft/pt/ps_app_home" >> $PSCONFIG_FILE
	echo "export TNS_ADMIN=/opt/oracle/psft/db" >> $PSCONFIG_FILE
	echo "export ORACLE_HOME=/opt/oracle/psft/db/oracle-server/12.1.0.2" >> $PSCONFIG_FILE
	echo "export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:\$LD_LIBRARY_PATH" >> $PSCONFIG_FILE
	echo "export PATH=.:\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch:\$ORACLE_HOME/perl/bin:\$PATH" >> $PSCONFIG_FILE
	echo " " >> $PSCONFIG_FILE
	echo "TUXDIR=/opt/oracle/psft/pt/bea/tuxedo" >> $PSCONFIG_FILE
	echo "if [ -d \$TUXDIR ]; then" >> $PSCONFIG_FILE
	echo "  export TUXDIR=\$TUXDIR/tuxedo12.1.3.0.0" >> $PSCONFIG_FILE
	echo "  export PATH=\$TUXDIR/bin:\$PATH" >> $PSCONFIG_FILE
	echo "  export LD_LIBRARY_PATH=\$TUXDIR/bin:\$TUXDIR/lib:\$LD_LIBRARY_PATH" >> $PSCONFIG_FILE
	echo "fi" >> $PSCONFIG_FILE
	echo "export PATH=\$PS_HOME/appserv:\$PS_HOME/setup:\$PATH" >> $PSCONFIG_FILE
	echo "export LANG=C" >> $PSCONFIG_FILE
	echo " " >> $PSCONFIG_FILE
	echo ". $PSCONFIGS_DIR/psconfig.common.sh" >> $PSCONFIG_FILE
done
	
### Make dummy domains
for cfg in "${cfgs[@]}"
do
	((seqnbr+=10))
	(
	# VARS
	######
	. $PSCONFIGS_DIR/psconfig.$cfg.sh	
        webport="80$seqnbr"
	jolthost="localhost"
	joltport="100$seqnbr"
	webuser="PS"
	webpw="PS"
	psreports=" "
	domconnpw=""	
	piappdom="APPDOM"
	appdom="$piappdom"
	piprcsdom="PRCSDOM"
	prcsdom="$piprcsdom"
	prcsname="PSUNX$seqnbr"
	piappcfg="$PS_PI_CFG_HOME/appserv/$piappdom/psappsrv.cfg"
	appcfg="$PSCFGHOMES_DIR/$cfg/appserv/$appdom/psappsrv.cfg"
	piprcscfg="$PS_PI_CFG_HOME/appserv/prcs/$piprcsdom/psprcs.cfg"
	prcscfg="$PSCFGHOMES_DIR/$cfg/appserv/prcs/$prcsdom/psprcs.cfg"

	# WEB
	#####
	echo "Importing $cfg-web"
	psadmin -w import $PS_PI_CFG_HOME -d peoplesoft -n peoplesoft -r
 	# reconfig domain
	echo "Reconfig $cfg-web domain"
	psadmin -w configure -d peoplesoft -p 8010/443	
	# reconfig site
	echo "Reconfig $cfg-web site"
	psadmin -w configure -d peoplesoft -s ps -c "$jolthost:$joltport"/PROD/Enabled/"$psreports"/$webuser/$webpw/$domconnpw

	# APP
	#####
	echo "Importing $cfg-app"
	psadmin -c import $piappcfg -n $appdom -r
	echo "Reconfig $cfg-app domain"
	# change cfg file directly, no config option like web
	sed -i -e "s/Port=.*/Port=$joltport/" $appcfg
	psadmin -c configure -d $appdom

	# PRCS
	######
	echo "Importing $cfg-prcs"
	psadmin -p import $piprcscfg -n $prcsdom -r
	echo "Reconfig $cfg-prcs domain"
	# change cfg file directly, no config option like web
	sed -i -e "s/PrcsServerName=.*/PrcsServerName=$prcsname/" $prcscfg
	psadmin -p configure -d $prcsdom
	)
done

# Setup sourcing in user profile
