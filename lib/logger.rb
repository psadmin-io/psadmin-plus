module Logging
  protected

  def info(msg)
    logger.info msg
  end

  def warn(msg)
    logger.warn msg
  end

  def debug(msg)
    logger.debug msg
  end

  def logger
    @logger ||= Logger.new(STDOUT).tap do |logger|
      log_level_from_env = ENV['PS_PSA_DEBUG']
      logger.level = Logger.const_get(log_level_from_env)
      logger.formatter = proc do |severity, datetime, progname, msg|
          date_format = Time.now.strftime("[%Y-%m-%d %H:%M:%S] ") 
          "#{cmd} (#{severity}): #{msg}\n"
    end
  end
end