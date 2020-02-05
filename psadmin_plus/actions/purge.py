from psadmin_plus.actions.action import Action
        
class Purge(Action):

    def __init__(self):
        super().__init__()

    def _app(self,domain):
        self._psadmin(["-c","purge","-d",domain])

    def _prcs(self,domain):
        print('prcs purge coming soon! - TODO')

    def _web(self,domain):
        print('web purge coming soon! - TODO')
        #rm -rf ${PS_CFG_HOME?}/webserv/#{domain}/applications/peoplesoft/PORTAL*/*/cache*/
             