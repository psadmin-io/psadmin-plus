from psadmin_plus.actions.action import Action
        
class Start(Action):

    def __init__(self):
        super().__init__()

    def _app(self,domain):
        if self.conf.PS_PARALLEL_BOOT == "true":
            self._psadmin(["-c","parallelboot","-d",domain])
        else:
            self._psadmin(["-c","boot","-d",domain])

    def _prcs(self,domain):
        self._psadmin(["-p","start","-d",domain])

    def _web(self,domain):
        if self.conf.PS_PIA_PSA == "true":
            self._psadmin(["-w","start","-d",domain])
        else:
            self._oscmd(self.conf.PS_CFG_HOME + "/webserv/" + domain + "/bin","startPIA.sh")

