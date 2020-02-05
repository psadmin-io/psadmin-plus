import os

import click

import psadmin_plus.actions
#from psadmin_plus.actions import admin
from psadmin_plus.actions import bounce
from psadmin_plus.actions import configure
from psadmin_plus.actions import flush
from psadmin_plus.actions import kill
from psadmin_plus.actions import list
#from psadmin_plus.actions import poolrm
#from psadmin_plus.actions import pooladd
from psadmin_plus.actions import purge
from psadmin_plus.actions import restart
from psadmin_plus.actions import start
from psadmin_plus.actions import status
from psadmin_plus.actions import stop
from psadmin_plus.actions import summary
#from psadmin_plus.actions import util
from psadmin_plus.interface.conf import Conf

# hack to get around python3 issues - See Click and Python3 Surrogate Handling
os.environ["LC_ALL"] = "en_US.utf-8"
os.environ["LANG"] = "en_US.utf-8"

def start(conf):
  conf = conf
  process()

@click.group()
def process():
  pass

#@click.command(name='admin',help='launch psadmin')
#def _admin():
#  getattr(actions_admin)()

@click.command(name='bounce',help='stop, flush, purge, configure and start')
@click.argument('type')
@click.argument('domain')
def _bounce(type,domain):
  getattr(actions_bounce,type)()

@click.command(name='configure',help='configure the domain')
@click.argument('type')
@click.argument('domain')
def _configure(type,domain):
  getattr(actions_configure,type)()

@click.command(name='flush',help='clear domain IPC')
@click.argument('type')
@click.argument('domain')
def _flush(type,domain):
  getattr(actions_flush,type)()

@click.command(name='kill',help='force stop the domain')
@click.argument('type')
@click.argument('domain')
def _kill(type,domain):
  getattr(actions_kill,type)()

@click.command(name='list',help='list domains')
def _list():
  getattr(actions_list)()

#@click.command(name='pooladd',help='add domain to load balanced pool')
#@click.argument('type')
#@click.argument('domain')
#def _pooladd(type,domain):
#  getattr(actions_pooladd,type)()

#@click.command(name='poolrm',help='remove domain from load balanced pool')
#@click.argument('type')
#@click.argument('domain')
#def _poolrm(type,domain):
#  getattr(actions_poolrm,type)()

@click.command(name='purge',help='clear domain cache')
@click.argument('type')
@click.argument('domain')
def _purge(type,domain):
  getattr(actions_purge,type)()

@click.command(name='restart',help='stop and start the domain')
@click.argument('type')
@click.argument('domain')
def _restart(type,domain):
  getattr(actions_restart,type)()

@click.command(name='start',help='start the domain')
@click.argument('type')
@click.argument('domain')
def _start(type,domain):
  getattr(start,type)()

@click.command(name='status',help='status of the domain')
@click.argument('type')
@click.argument('domain')
def _status(type,domain):
  getattr(actions_status,type)()

@click.command(name='stop',help='stop the domain')
@click.argument('type')
@click.argument('domain')
def _stop(type,domain):
  getattr(actions_stop,type)()

@click.command(name='summary',help='PS_CFG_HOME summary')
def _summary():
  getattr(actions_summary)()

#@click.command(name='util',help='TODO')
#def _util():
#  getattr(actions_util)()

# add commands

#process.add_command(_admin)
process.add_command(_bounce)
process.add_command(_configure)
process.add_command(_flush)
process.add_command(_kill)
process.add_command(_list)
#process.add_command(_pooladd)
#process.add_command(_poolrm)
process.add_command(_purge)
process.add_command(_restart)
process.add_command(_start)
process.add_command(_status)
process.add_command(_stop)
process.add_command(_summary)
#process.add_command(_util)
