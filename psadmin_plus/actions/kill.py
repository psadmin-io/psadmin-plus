from psadmin_plus.actions.action import Action
        
class Kill(Action):

    def __init__(self):
        super().__init__()

    def _app(self,domain):
        self._psadmin(["-c","shutdown!","-d",domain])

    def _prcs(self,domain):
        self._psadmin(["-p","kill","-d",domain])

    def _web(self,domain):
        print('kill for web coming soon! - TODO')