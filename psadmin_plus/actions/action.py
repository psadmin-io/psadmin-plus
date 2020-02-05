from psadmin_plus.interface.conf import Conf

class Action:

    def __init__(self):
        self.conf = Conf()

    def process(self,type,domain):
        if type == 'app':
            self._app(domain)
        elif type == 'prcs':
            self._prcs(domain)
        elif type == 'web':
            self._web(domain)
        else:
            raise ValueError('Invalid domain type provided to Action')

    def _app(self,domain):
        print('action app ' + domain)

    def _prcs(self,domain):
        print('action prcs ' + domain)

    def _web(self,domain):
        print('action web ' + domain)
