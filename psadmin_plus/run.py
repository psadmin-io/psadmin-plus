from psadmin_plus.interface import cli, conf

def run():
  conf = Conf()
  cli.process(conf)

if __name__ == '__main__':
  run()

