# psadmin-plus 
The `psadmin-plus` script is a wrapper for `psadmin`. By passing parameters via command line, you can run psadmin actions like start, stop, status, etc. All domains should be contained in a single `PS_CFG_HOME`. If you use multiple config homes, see branch `feature/multi-cfg-homes`.

## Example Usage
| Task | Command|
|---|---|
| help | `psadmin-plus help`|
| start all domains|`psadmin-plus start`|
| start all web domains|`psadmin-plus start web`|
| start hdev web domain|`psadmin-plus start web hdev`|

## Setup
```
git clone https://github.com/psadmin-io/psadmin-plus.git ~/psadmin-plus
~/psadmin-plus help
```

## Environment Variables
* `PS_RUNTIME_USER`
    * User that owns `PS_CFG_HOME` and should run `psadmin`
    * If not set, default is `psadm2`
* `PS_POOL_MGMT`
    * Enables load balanced pool management
    * If not set, default is `off`
* `PS_HEALTH_FILE`
    * Name of file used by Load Balancer health check
* `PS_HEALTH_TIME`
    * Health check timeout duration in seconds

## Profile Suggestions
Here are some suggested addtions to your bash profile.
* `export PS_RUNTIME_USER="ps-cfg-home-owner"`
* `alias psa="/repo/location/psadmin-plus/psadmin-plus"`

## PeopleTools Support
This has been tested using:
* 8.55
