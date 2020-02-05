from psadmin_plus.actions.action import Action
        
class Configure(Action):

    def __init__(self):
        super().__init__()

    def _app(self,domain):
        self._psadmin(["-c","configure","-d",domain])

    def _prcs(self,domain):
        self._psadmin(["-p","configure","-d",domain])

    def _web(self,domain):
        print('web configure coming soon - reload web profiles! - TODO')