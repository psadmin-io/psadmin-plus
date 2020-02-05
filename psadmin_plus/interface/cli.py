import os

import click

import psadmin_plus.actions
##from psadmin_plus.actions.admin import Admin
#from psadmin_plus.actions.bounce import Bounce
#from psadmin_plus.actions.configure import Configure
#from psadmin_plus.actions.flush import Flush
#from psadmin_plus.actions.kill import Kill
#from psadmin_plus.actions.list import List
##from psadmin_plus.actions.poolrm import Poolrm
##from psadmin_plus.actions.pooladd import Pooladd
#from psadmin_plus.actions.purge import Purge
#from psadmin_plus.actions.restart import Restart
from psadmin_plus.actions.start import Start
from psadmin_plus.actions.status import Status
from psadmin_plus.actions.stop import Stop
#from psadmin_plus.actions.summary import Summary
#from psadmin_plus.actions.util import Util

# hack to get around python3 issues - See Click and Python3 Surrogate Handling
os.environ["LC_ALL"] = "en_US.utf-8"
os.environ["LANG"] = "en_US.utf-8"

def process():
  climain()

@click.group()
def climain():
  pass

#@click.command(name='admin',help='launch psadmin')
#def _admin():
#  Admin().process(type, domain)

@click.command(name='bounce',help='stop, flush, purge, configure and start')
@click.argument('type')
@click.argument('domain')
def _bounce(type,domain):
  Bounce().process(type, domain)

@click.command(name='configure',help='configure the domain')
@click.argument('type')
@click.argument('domain')
def _configure(type,domain):
  Configure().process(type, domain)

@click.command(name='flush',help='clear domain IPC')
@click.argument('type')
@click.argument('domain')
def _flush(type,domain):
  Flush().process(type, domain)

@click.command(name='kill',help='force stop the domain')
@click.argument('type')
@click.argument('domain')
def _kill(type,domain):
  Kill().process(type, domain)

@click.command(name='list',help='list domains')
def _list():
  List().process(type, domain)

#@click.command(name='pooladd',help='add domain to load balanced pool')
#@click.argument('type')
#@click.argument('domain')
#def _pooladd(type,domain):
#  Pooladd().process(type, domain)

#@click.command(name='poolrm',help='remove domain from load balanced pool')
#@click.argument('type')
#@click.argument('domain')
#def _poolrm(type,domain):
#  Poolrm().process(type, domain)

@click.command(name='purge',help='clear domain cache')
@click.argument('type')
@click.argument('domain')
def _purge(type,domain):
  Purge().process(type, domain)

@click.command(name='restart',help='stop and start the domain')
@click.argument('type')
@click.argument('domain')
def _restart(type,domain):
  Restart().process(type, domain)

@click.command(name='start',help='start the domain')
@click.argument('type')
@click.argument('domain')
def _start(type,domain):
  Start().process(type, domain)

@click.command(name='status',help='status of the domain')
@click.argument('type')
@click.argument('domain')
def _status(type,domain):
  Status().process(type, domain)

@click.command(name='stop',help='stop the domain')
@click.argument('type')
@click.argument('domain')
def _stop(type,domain):
  Stop().process(type, domain)

@click.command(name='summary',help='PS_CFG_HOME summary')
def _summary():
  Summary().process(type, domain)

#@click.command(name='util',help='TODO')
#def _util():
#  Util().process(type, domain)

# add commands

#process.add_command(_admin)
climain.add_command(_bounce)
climain.add_command(_configure)
climain.add_command(_flush)
climain.add_command(_kill)
climain.add_command(_list)
#climain.add_command(_pooladd)
#climain.add_command(_poolrm)
climain.add_command(_purge)
climain.add_command(_restart)
climain.add_command(_start)
climain.add_command(_status)
climain.add_command(_stop)
climain.add_command(_summary)
#climain.add_command(_util)
