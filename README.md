# psadmin-plus 
`psadmin_plus` is a rubygem helper tool for `psadmin`. By passing parameters via command line, you can run psadmin actions like start, stop, status, etc. All domains should be contained in a single `PS_CFG_HOME`. If you use multiple config homes, see branch `feature/multi-cfg-homes`.

## Example Usage
| Task | Command|
|---|---|
| help | `psa help`|
| start all domains|`psa start`|
| start all web domains|`psa start web`|
| start hdev web domain|`psa start web hdev`|

## Setup
`gem install psadmin_plus`

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
* `PS_PSA_SUDO`
    * Runs commands as `PS_RUNTIME_USER` via `sudo`, if set to `on`

## Profile Suggestions
Here are some suggested addtions to your bash profile.
* `export PS_RUNTIME_USER="ps-cfg-home-owner"`
* `export PS_POOL_MGMT="off"`
* `export PS_PSA_SUDO="on"`

## PeopleTools Support
This has been tested using:
* 8.55
