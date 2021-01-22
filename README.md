# psadmin-plus 

`psadmin_plus` is a RubyGem helper tool for `psadmin`. By passing parameters via command line, you can run `psadmin` actions like start, stop, status, etc. All domains should be contained in a single `PS_CFG_HOME`. If you use multiple `PS_CFG_HOME` homes, see the [Multi Config Homes](#multi-config-homes) section on how to enable support.

# Example Usage

| Task                          | Command                |
| ----------------------------- | ---------------------- |
| help                          | `psa help`             |
| list domains                  | `psa list`             |
| start all domains             | `psa start`            |
| start all web domains         | `psa start web`        |
| start hdev web domain         | `psa start web hdev`   |
| clear hrdev cache and restart | `psa bounce app hrdev` |

# Setup

## gem install
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

## git clone
If you don't want to use the `gem` install, do a `git` clone install of this repo instead. Then add `psadmin-plus/bin` to your `PATH`. This can be helpful when doing development or adjusting `psadmin-plus` to better fit your needs.

```
cd ~
git clone https://github.com/psadmin-io/psadmin-plus.git
cd psadmin-plus
export PATH:$PATH:~/psadmin-plus/bin
psa help
```

## Environment Variables

* `PS_RUNTIME_USER`
    * User that owns `PS_CFG_HOME` and should run `psadmin`
    * If not set, default is `psadm2`
* `PS_PSA_SUDO`
    * Runs commands as `PS_RUNTIME_USER` via `sudo`, if set to `on`
    * Options are: `on`, `off`
    * If not set, default is `off`
* `PS_MULTI_HOMES`
    * Set this value to the base folder where your `PS_CFG_HOME` are stored. 
    * Use Unix path separators on all platforms. E.g, `PS_MULTI_HOME=/opt/oracle/psft/cfg` or `PS_MULTI_HOME=c:/psft/cfg`
    * Option is any valid path or `false`
    * If not set, default is `false`
* `PS_MULTI_DELIMIT`
    * Set this value to specifiy how `PS_CFG_HOME` directories are structured. 
    * By default, `/` is used for when a pattern of `<PS_MULTI_HOMES>/<DOMAIN_NAME>` is used.
        * Example
        ```
        # c:/ps_cfg_home/hrdev
        # c:/ps_cfg_home/hrtst
        PS_MULTI_HOMES="c:/ps_cfg_home"
        PS_MULTI_DELIMIT="/"
        ```
    * If a base directory pattern is not used, a custom delimiter can be used between `<PS_MULTI_HOMES>` and `<DOMAIN_NAME>`.
        * Example
        ```
        # c:/ps_cfg_home-hrdev
        # c:/ps_cfg_home-hrtst
        PS_MULTI_HOMES="c:/ps_cfg_home"
        PS_MULTI_DELIMIT="-"
        ```
    * If not set, default is `/`
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
* `PS_HOOK_INTERP`
    * Sets the interpreter to be used for hook scripts.
    * Options are: `ruby`, `bash`, `Powershell -File`, etc
    * If not set, default is `ruby`
* `PS_HOOK_PRE`|`PS_HOOK_POST`
    * Sets the hook script to run pre or post command.
    * Examples are found in `lib/hooks`.
    * If not set, default is `false` and no hook is triggered.
* `PS_HOOK_STOP`
    * Sets the hook script to run before the `stop` command.
    * Examples are found in `lib/hooks`.
    * If not set, default is `false` and no hook is triggered.
* `PS_HOOK_START`
    * Sets the hook script to run after the `start` command.
    * Examples are found in `lib/hooks`.
    * If not set, default is `false` and no hook is triggered.
    
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

# Features

## General
* Execute against `web`, `app`, `pubsub`, and `prcs` domain types.
* Types and Domains can be given in a comma separated list.
    * Example: `psa status app,prcs hrdev,hrtst`
* Web Profiles can be reloaded without a domain restart by using `psa configure web`
* Supports Service Accounts or User Accounts. `psa` can run commands as a service account so domains are started under the correct account.
* Supports Windows Services as well as `psadmin` for domains on Windows

## Multi Config Homes

* Support for multiple PS_CFG_HOME folders.
* Multiple `PS_CFG_HOME`s: The multi-config home support is limited to a single domain under `PS_CFG_HOME`, and the domain name must match the folder for `PS_CFG_HOME`. If your domain is named `HRDEV`, then the `PS_CFG_HOME` must end with that domain name. (E.g, `c:\psft\cfg\HRDEV`)

## Hooks
Hooks give you the ability to execute custom scripts in the `psadmin-plus` execution stream. Hook behavior is controlled by `PS_HOOKS_*` variables, [see Environment Variables](#environment-variables). You can select what type of scripts will be executed - examples: ruby, bash, powershell. You have the option to run scripts pre or post commands, as well as when using `start` or `stop`. 

# Troubleshooting

* SSL issues in Ruby scripts.
    * Review CA Certificates and `SSL_CERT_FILE` variable
        * Linux example: `export SSL_CERT_FILE=/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem`
        * Windows example: [CA Setup](https://gist.github.com/iversond/e56e608cf8fa65f7160416f4c434da57#file-enableRubyGems-ps1)
