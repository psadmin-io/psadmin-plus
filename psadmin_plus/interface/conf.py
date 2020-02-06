import os

class Conf:

    # defaults
    OS               = "linux"
    PS_PIA_PSA       = "true"
    PS_PARALLEL_BOOT = "false"
    PS_HOME          = os.environ["PS_HOME"]
    PS_CFG_HOME      = os.environ["PS_CFG_HOME"]
    #PS_RUNTIME_USER     = ENV['PS_RUNTIME_USER'] || "psadm2"
    #PS_POOL_MGMT        = ENV['PS_POOL_MGMT'] || "on"
    #PS_HEALTH_FILE      = ENV['PS_HEALTH_FILE'] || "health.html"
    #PS_HEALTH_TIME      = ENV['PS_HEALTH_TIME'] || "60"
    #PS_HEALTH_TEXT      = ENV['PS_HEALTH_TEXT'] || "true"
    #PS_PSA_SUDO         = ENV['PS_PSA_SUDO'] || "on"
    #PS_PSADMIN_PATH     = "#{OS_CONST}" == "linux" ? "#{env('PS_HOME')}/bin" : "cmd /c #{env('PS_HOME')}/appserv"
    #PS_WIN_SERVICES     = ENV['PS_WIN_SERVICES'] || "false"
    #PS_TRAIL_SERVICE    = ENV['PS_TRAIL_SERVICE'] || "false"
    #PS_MULTI_HOME       = ENV['PS_MULTI_HOME'] || "false"
    #PS_PSA_DEBUG        = ENV['PS_PSA_DEBUG']  || "false"

    def __init__(self):
        pass

    def __private():
        pass
