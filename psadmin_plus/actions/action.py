import glob
import subprocess

from psadmin_plus.interface.conf import Conf

# we are assuming linux, run as psadm2, psadmin in patch, etc 

class Action:

    def __init__(self):
        self.conf = Conf()

    def process(self, type, domain):
        if type == 'app':
            domains = self._get_apps(domain)
            for dom in domains:
                self._app(dom)
        elif type == 'prcs':
            domains = self._get_prcs(domain)
            for dom in domains:
                self._prcs(dom)
        elif type == 'web':
            domains = self._get_webs(domain)
            for dom in domains:
                self._web(dom)
        elif not type:          # No type given
            domains = self._get_apps(domain)
            for dom in domains:
                self._app(dom)
            domains = self._get_prcs(domain)
            for dom in domains:
                self._prcs(dom)
            domains = self._get_webs(domain)
            for dom in domains:
                self._web(dom)
        else:
            raise ValueError('Invalid domain type provided to Action')

    def _app(self, domain):
        print('action app ' + domain)

    def _prcs(self, domain):
        print('action prcs ' + domain)

    def _web(self, domain):
        print('action web ' + domain)

    def _psadmin(self, args):
        subprocess.call(["psadmin"] + args)

    def _oscmd(self, path, args):
        subprocess.call(args, cwd=path)
    
    def _oscmd2(self, args):
        subprocess.call(args)

    def _get_apps(self, dom):
        if dom:
            apps=[dom]
        else:
            apps = glob.glob(self.conf.PS_CFG_HOME + '/appserv/*/PSTUXCFG')
            apps = [i.split('/')[-2] for i in apps]        

        return apps
        
    def _get_prcs(self, dom):
        if dom:
            prcs=[dom]
        else:
            prcs = glob.glob(self.conf.PS_CFG_HOME + '/appserv/prcs/*/PSTUXCFG')
            prcs = [i.split('/')[-2] for i in prcs]        

        return prcs
        
    def _get_webs(self, dom):
        if dom:
            webs=[dom]
        else:
            webs = glob.glob(self.conf.PS_CFG_HOME + '/webserv/*/config/config.xml')
            webs = [i.split('/')[-3] for i in webs]        

        return webs
