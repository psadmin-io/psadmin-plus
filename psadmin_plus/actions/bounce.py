from psadmin_plus.actions.action import Action
        
class Bounce(Action):

    def __init__(self):
        super().__init__()

    def _app(self,domain):
        self._psadmin(["-c","shutdown","-d",domain])
        self._psadmin(["-c","purge","-d",domain])
        self._psadmin(["-c","cleanipc","-d",domain])
        self._psadmin(["-c","configure","-d",domain])
        
        if (self.conf.PS_PARALLEL_BOOT == "true"):
            self._psadmin(["-c","parallelboot","-d",domain])
        else:
            self._psadmin(["-c","boot","-d",domain])

    def _prcs(self,domain):
        self._psadmin(["-p","stop","-d",domain])
        print('prcs purge coming soon! - TODO')
        self._psadmin(["-p","cleanipc","-d",domain])
        self._psadmin(["-p","configure","-d",domain])
        self._psadmin(["-p","start","-d",domain])

    def _web(self,domain):
        self._psadmin(["-w","shutdown","-d",domain])
        print('web purge coming soon! - TODO')
        
        if (self.conf.PS_PIA_PSA == "true"):
            self._psadmin(["-w","start","-d",domain])
        else:
            self._oscmd(self.conf.PS_CFG_HOME + "/webserv/" + domain + "/bin","startPIA.sh")
