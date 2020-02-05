from psadmin_plus.actions.action import Action

class Start(Action):

    def __init__(self):
        super().__init__()

    def _app(self,domain):
        print('start app ' + domain)
        print(self.conf.test) 

    def _prcs(self,domain):
        print('start prcs ' + domain)

    def _web(self,domain):
        print('start web ' + domain)
