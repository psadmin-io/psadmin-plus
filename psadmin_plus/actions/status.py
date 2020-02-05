import subprocess # TODO move to Action

from psadmin_plus.actions.action import Action
        
# TODO - right now assuming run as psadm2 and all ENVs are set, psadmin in path, etc
# TODO - add a psadmin command method in Action, that takes args
# TODO - use subprocessPopen to better handle output, poll progress, etc

class Status(Action):

    def __init__(self):
        super().__init__()

    def _app(self,domain):
        subprocess.call(["psadmin", "-c","sstatus","-d",domain])
        subprocess.call(["psadmin", "-c","cstatus","-d",domain])
        subprocess.call(["psadmin", "-c","qstatus","-d",domain])
        subprocess.call(["psadmin", "-c","pslist","-d",domain])

    def _prcs(self,domain):
        subprocess.call(["psadmin", "-p","status","-d",domain])

    def _web(self,domain):
        subprocess.call(["psadmin", "-w","status","-d",domain])
