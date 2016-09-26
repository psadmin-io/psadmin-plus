# psadmin-plus 
The `psadmin-plus` script is a wrapper for `psadmin`. Using an interactive menu, or passing parameters via command line, you can run psadmin actions like start, stop, status, etc. All `PS_CFG_HOME`s will be discovered and `psconfig.sh` files will be sourced automatically.

![demo](http://g.recordit.co/3UKuOWFsk9.gif)

## Menu Actions
* `status` - gives the status of a domain
* `start` - starts the domain
* `stop` - stops the domain
* `restart` - stops then starts the domain
* `purge` - clears domain cache, app and web only
* `bounce` - does a stop, flush, purge, configure, and then start
* `kill` - force stop of domain, app and prcs only
* `configure` - loads domain configureation, app and prcs only
* `flush` - runs cleanipc, app and prcs only
* `psadmin` - source psconfig.sh and run psadmin
* `psconfig` - edit psconfig.sh for environment

## Command Line 
* `psadmin-plus [action] [cfg] [domain] [type]`
    * action - same as availiable in menu
	* type - app, prcs, web, all

## Environment Variables
* `PS_CFG_HOME_DIR`
    * Directory that contains all `PS_CFG_HOMEs`
    * Current assumption is that all sub-directories are `PS_CFG_HOMEs`
* `PS_CUST_HOME_DIR`
    * Directory that contains all `PS_CUST_HOMEs`.
	* Current assumption is that custom `psconfig.sh` files are stored under `PS_CUST_HOME\[cfg]`

## Assumptions
* All directories under `$PS_CFG_HOME_DIR` are `PS_CFG_HOMEs`
* All `PS_CFG_HOMEs` have their own environment variables file for sourcing, found at `$PS_CUST_HOME/[cfg]/psconfig.sh`
* If you have more than 1 domain per `PS_CFG_HOME` and type, actions will be applied to all.
    * Example: If the `dev` cfg has 2 app domains [`APPDOM1`,`APPDOM2`], the `start` action will be applied to both `APPDOM1` and `APPDOM2`.

## PeopleTools Support
This has been tested using:
* 8.55

## Example Setup
There is an example setup script you can run against a PeoplSoft Image(PI) for testing. This script will create a few extra `PS_CFG_HOMEs` and domains to play with using psadmin-plus. Run this with a user besides `psadm2`, most likly a user you created and not delivered with the PI.

```
cd ~/
git clone git://github.com/psadmin-io/psadmin-plus
~/psadmin-plus/pi-example-setup.sh
```

