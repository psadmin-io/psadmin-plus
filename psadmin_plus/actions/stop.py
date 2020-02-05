from psadmin_plus.actions.action import Action
        
class Stop(Action):

    def __init__(self):
        super().__init__()

    def _app(self,domain):
        self._psadmin(["-c","shutdown","-d",domain])

    def _prcs(self,domain):
        self._psadmin(["-p","stop","-d",domain])

    def _web(self,domain):
        self._psadmin(["-w","shutdown","-d",domain])
