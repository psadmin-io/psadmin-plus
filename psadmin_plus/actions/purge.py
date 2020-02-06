from psadmin_plus.actions.action import Action
        
class Purge(Action):

    def __init__(self):
        super().__init__()

    def _app(self,domain):
        self._psadmin(["-c","purge","-d",domain])

    def _prcs(self,domain):
        print('prcs purge coming soon!')

    def _web(self,domain):
        print('web coming soon! TODO')
        #self._oscmd2(["ls","-vl",self.conf.PS_CFG_HOME + "/webserv/" + domain + "/applications/peoplesoft/PORTAL*/*/cache*/"])
        #self._oscmd2(["ls","-vl","/opt/oracle/psft/home/psadm2/psft/pt/8.57/webserv/peoplesoft/applications/peoplesoft/PORTAL*/*/cache*/"])
