from psadmin_plus.interface import cli
from psadmin_plus.interface.conf import Conf

def run():
  _conf = Conf()
  cli.start(_conf)

if __name__ == '__main__':
  run()

