# psadmin-plus 

`psadmin_plus` is a RubyGem helper tool for `psadmin`. By passing parameters via command line, you can run `psadmin` actions like start, stop, status, etc. All domains should be contained in a single `PS_CFG_HOME`. If you use multiple `PS_CFG_HOME` homes, see the [Multi Config Homes](###multi-config-homes) section on how to enable support.

## Example Usage

| Task                          | Command                |
| ----------------------------- | ---------------------- |
| help                          | `psa help`             |
| list domains                  | `psa list`             |
| start all domains             | `psa start`            |
| start all web domains         | `psa start web`        |
| start hdev web domain         | `psa start web hdev`   |
| clear hrdev cache and restart | `psa bounce app hrdev` |

## Setup

`gem install psadmin_plus`

*Hey, I don't have ruby installed!*

* [Use ruby included with Puppet on Windows](https://gist.github.com/iversond/e56e608cf8fa65f7160416f4c434da57#file-enableRubyGems-ps1)
* Use ruby included with Puppet on Linux
    * Install ruby for user `psadm2` using the `--user-install` command.
        ```
        $ /opt/puppetlabs/puppet/bin/gem install psadmin_plus --user-install
        $ echo 'export PATH=$PATH:~/.gem/ruby/2.4.0/bin' >> ~/.bashrc
        $ . ~/.bashrc
        ```

## Environment Variables

# TODO - add hooks

* `PS_RUNTIME_USER`
    * User that owns `PS_CFG_HOME` and should run `psadmin`
    * If not set, default is `psadm2`
* `PS_POOL_MGMT`
    * Enables load balanced pool management
    * Options are: `on`, `off`
    * If not set, default is `off`
* `PS_HEALTH_FILE`
    * Name of file used by Load Balancer health check
    * Options are: any valid filename
    * If not set, default is `heath.html`
* `PS_HEALTH_TEXT`
    * The content of the health check file
    * Options are: any valid string. Use single quotes if the string has spaces or special characters.
    * If not set, default is `true`
* `PS_HEALTH_TIME`
    * Health check timeout duration in seconds
    * Options are: any integer
    * If not set, default is 60 seconds
* `PS_PSA_SUDO`
    * Runs commands as `PS_RUNTIME_USER` via `sudo`, if set to `on`
    * Options are: `on`, `off`
    * If not set, default is `off`
* `PS_MULTI_HOMES`
    * Set this value to the base folder where your `PS_CFG_HOME` are stored. 
    * Use Unix path separators on all platforms. E.g, `PS_MULTI_HOME=/opt/oracle/psft/cfg` or `PS_MULTI_HOME=c:/psft/cfg`
    * Option is any valid path or `false`
    * If not set, default is `false`
* `PS_WIN_SERVICES`
    * Use Windows Services to start/stop web, app and prcs domains.
    * Options are: `all`, `tux`, `web`, `app`, `prcs`
    * If not set, default is `false`. `psadmin` is used to start/stop domains.
    * The default service name is the DPK standard: `Psft<Type><Domain>Service`
    * To override the default name, set the environment variables:
        1. `WEB_SERVICE_NAME`
        1. `APP_SERVICE_NAME`
        1. `PRCS_SERVICE_NAME`
    * The override names must include `#{domain}` somewhere in the name. That is used by `psadmin-plus` to call the correct domain. E.g, `WEB_SERVICE_NAME="#{domain}-pia"`
* `PS_TRAIL_SERVICES`
    * On Windows, you can use this option to set the Windows service after starting/stopping a domain via psadmin. This lets you start/stop and view the domain output but keep the Windows service status in sync.
    * Options are: `true`, `false`
    * If note set, default is `false`
* `PS_PSA_CONF`
    * The location of a configuration file for `psadmin-plus`
    * Options are: a valid path to the config file
    * If not set, default is `~/.psa.conf`

## Configuration File

You can store the `psadmin-plus` configuration in a file instead of environment variables. 

1. Create the file `~/.psa.conf`
1. Add your configuration as `envVar=value` pairs on each line 

```
PS_POOL_MGMT=on
PS_MULTI_HOMES=/opt/oracle/psft/cfg
PS_HEALTH_FILE=host.html
```

## Profile Suggestions

Here are some suggested additions to your bash profile.

* `export PS_RUNTIME_USER="<ps-cfg-home-owner>"`
* `export PS_POOL_MGMT="off"`
* `export PS_PSA_SUDO="on"`

Or set `PS_PSA_CONF` if you want to use a configuration file in a custom location

`export PS_PSA_CONF=/u01/app/psa.conf`

## Features

### General
* Supports Service Accounts or User Accounts. `psa` can run commands as a service account so domains are started under the correct account.
* Supports Windows Services as well as `psadmin` for domains on Windows

### Multi Config Homes

* Support for multiple PS_CFG_HOME folders.
* Multiple `PS_CFG_HOME`s: The multi-config home support is limited to a single domain under `PS_CFG_HOME`, and the domain name must match the folder for `PS_CFG_HOME`. If your domain is named `HRDEV`, then the `PS_CFG_HOME` must end with that domain name. (E.g, `c:\psft\cfg\HRDEV`)

### Hooks

* TODO
