from psadmin_plus.actions.action import Action
        
class Status(Action):

    def __init__(self):
        super().__init__()

    def _app(self,domain):
        self._psadmin(["-c","sstatus","-d",domain])
        self._psadmin(["-c","cstatus","-d",domain])
        self._psadmin(["-c","qstatus","-d",domain])
        self._psadmin(["-c","pslist","-d",domain])

    def _prcs(self,domain):
        self._psadmin(["-p","status","-d",domain])

    def _web(self,domain):
        self._psadmin(["-w","status","-d",domain])
