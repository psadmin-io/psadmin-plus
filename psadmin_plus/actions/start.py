from psadmin_plus.actions.action import Action
        
class Start(Action):

    def __init__(self):
        super().__init__()

    def _app(self,domain):
        self._psadmin(["-c","boot","-d",domain])
        # TODO - parallel switch - self._psadmin(["-c","parallelboot","-d",domain])

    def _prcs(self,domain):
        self._psadmin(["-p","status","-d",domain])

    def _web(self,domain):
        self._psadmin(["-w","status","-d",domain])
