# psadmin-plus 
The psadmin-plus script is a helper menu that can be used to interact with `psadmin`. It will build a dynamic menu including all `PS_CFG_HOMEs` found on a system. Based on your `PS_CFG_HOME` selections, you can run psadmin directly or run actions like start, stop, status, etc. When an action is selected from the menu, the `PS_CFG_HOME` specfic psconfig.sh file will be sourced automatically. Depending on the action selected, there is the option to `Run Now` or `Run Later` via a generated script.

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

## Environment Variables
* `PSCFGHOMES_DIR`
    * Directory that contains all PS_CFG_HOMEs
    * Current assumption is that all sub-directories are PS_CFG_HOMEs
* `PSCONFIGS_DIR`
    * Directory that contains all psconfig.sh files
* `PSAPLUS_WRK`
    * Default file used for generating scripts

## PeopleTools Support
This has been tested using:
* 8.55.04

## Example Setup
There is an example setup script you can run against a PeoplSoft Image(PI) for testing. This script will create a few extra `PS_CFG_HOMEs` and domains to play with using psadmin-plus. Run this with a user besides `psadm2`, most likly a user you created and not delivered with the PI.

```
cd ~/
git clone git://github.com/psadmin-io/psadmin-plus
~/psadmin-plus/pi-example-setup.sh
```
