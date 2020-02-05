from psadmin_plus.actions.action import Action
        
class Flush(Action):

    def __init__(self):
        super().__init__()

    def _app(self,domain):
        self._psadmin(["-c","cleanipc","-d",domain])

    def _prcs(self,domain):
        self._psadmin(["-p","cleanipc","-d",domain])

    def _web(self,domain):
        print('web does not have a flush command - TODO')