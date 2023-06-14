require 'open3'

class Runner
  attr_reader :cmd, :exit_status, :stdout, :stderr, :realtime

  # Run a command, return runner instance
  # @param cmd [String,Array<String>] command to execute
  def self.run(*cmd)
    Runner.new(*cmd).run
  end

  # Run a command, raise Runner::Error if it fails
  # @param cmd [String,Array<String>] command to execute
  # @raise [Runner::Error]
  def self.run!(*cmd)
    Runner.new(*cmd).run!
  end

  # Run a command, return true if it succeeds, false if not
  # @param cmd [String,Array<String>] command to execute
  # @return [Boolean]
  def self.run?(*cmd)
    Runner.new(*cmd).run?
  end

  Error = Class.new(StandardError)

  # @param cmd [String,Array<String>] command to execute
  def initialize(cmd, realtime = false)
    @cmd = cmd.is_a?(Array) ? cmd.join(' ') : cmd
    @stdout = +''
    @stderr = +''
    @realtime = realtime
    @exit_status = nil
  end

  # @return [Boolean] success or failure?
  def success?
    case exit_status
    when 0
        true
    when 40 # stop an already stopped domain
        true
    else
        false
    end
  end

  # Run the command, return self
  # @return [Runner]
  def run
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      if realtime == "all" || realtime == "summary"
        until [stdout, stderr].all?(&:eof?)
          readable = IO.select([stdout, stderr])
          next unless readable&.first

          readable.first.each do |stream|
            data = +''
            # rubocop:disable Lint/HandleExceptions
            begin
              stream.read_nonblock(1024, data)
            rescue EOFError
              # ignore, it's expected for read_nonblock to raise EOFError
              # when all is read
            end

            if stream == stdout
              @stdout << data
              if realtime == "all"
                $stdout.write(data)
              end
            else
              @stderr << data
              if realtime == "all"
                $stderr.write(data)
              end
            end
          end
        end
      end
      @exit_status = wait_thr.value.exitstatus
    end

    self
  end

  # Run the command and return stdout, raise if fails
  # @return stdout [String]
  # @raise [Runner::Error]
  def run!
    return run.stdout if run.success?

    raise(Error, "command failed, exit: %d - stdout: %s / stderr: %s" % [exit_status, stdout, stderr])
  end

  # Run the command and return true if success, false if failure
  # @return success [Boolean]
  def run?
    run.success?
  end
end