#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

require 'open3'
require 'timeout'
# rubocop: disable Metrics/AbcSize

module EasyType
  #
  # The EasyType:Daemon class, allows you to easy write a daemon for your application utility.
  # To get it working, subclass from
  #
  # rubocop:disable ClassVars
  class Daemon
    SUCCESS_SYNC_STRING     ||= /~~~~COMMAND SUCCESSFUL~~~~/
    FAILED_SYNC_STRING      ||= /~~~~COMMAND FAILED~~~~/
    TIMEOUT ||= ENV['EASY_TYPE_DAEMON_READ_TIMEOUT'] || 120 # wait 60 seconds as default

    @@daemons = {}
    #
    # Check if a daemon for this identity is running. Use this to determin if you need to start the daemon
    #
    def self.run(identity)
      daemon_for(identity) if daemonized?(identity)
    end

    ##
    # Initialize a command daemon. In the command daemon, the specified command is run in a daemon process.
    # The specified command must readiths commands from stdi and output any results from stdout.
    # A daemon proces must be identified by an identifier string. If you want to run multiple daemon processes,
    # say for connecting to an other, you can use a different name.
    #
    # If you want to run the daemon as an other user, you can specify a user name, the process will run under.
    # This must be an existing user.
    #
    # Checkout sync on how to sync the output. You can specify a timeout value to have the daemon read's
    # timed out if it dosen't get an expected answer within that time.
    #
    # rubocop: disable Lint/ReturnInVoidContext
    def initialize(identifier, command, user, filters = [], errors = [])
      return @@daemons[identifier] if @@daemons[identifier]
      initialize_daemon(user, command, filters)
      @identifier = identifier
      @@daemons[identifier] = self
      @errors = Regexp.union(errors << FAILED_SYNC_STRING)
    end
    # rubocop: enable Lint/ReturnInVoidContext

    #
    # Kill the daemon and reset the entry
    #
    def kill
      Thread.kill(@error_reader)
      Puppet.debug "Quiting daemon #{@identifier}..."
      @stdin.close
      @stdout.close
      @stderr.close
      @@daemons[@identifier] = nil
    end
    #
    # Pass a command to the daemon to execute
    #
    def execute_command(command)
      @stdin.puts command
    end

    #
    # Wait for the daemon process to return a valid sync string. YIf your command passed
    # ,return the string '~~~~COMMAND SUCCESFULL~~~~'. If it failed, return the string '~~~~COMMAND FAILED~~~~'
    #
    #
    def sync(timeout = TIMEOUT, &proc)
      Puppet.debug "Daemon syncing with timeout of #{timeout} seconds..."
      @output = ''
      loop do
        line = timed_readline(timeout)
        @output += line.gsub(@filter, '*** Filtered ***')
        break if line =~ SUCCESS_SYNC_STRING
        fail "command in deamon failed.\n #{@output}" if line =~ @errors
        yield(line) if proc
      end
      Puppet.debug @output.to_s
      @output
    end

    private

    def timed_readline(timeout)
      line = String.new
      loop do
        ready?(timeout)
        line << @stdout.read_nonblock(1)
        break line if line[-1] == "\n"
      end
      line
    end
  
    # @nodoc
    def ready?(timeout)
      timeout = nil if timeout == 0
      state = IO.select([@stdout], [], [], timeout)
      if state.nil?
        Puppet.err @output
        fail "timeout of #{timeout} seconds expired on reading output from daemon process."
      end
    end

    # @nodoc
    def self.daemonized?(identity)
      !daemon_for(identity).nil?
    end
    private_class_method :daemonized?

    # @nodoc
    def self.daemon_for(identity)
      @@daemons[identity]
    end
    private_class_method :daemon_for

    # @nodoc
    def initialize_daemon(user, command, filters = [])
      @filter = Regexp.union(filters)
      if user
        @stdin, @stdout, @stderr = Open3.popen3("su - #{user}")
        execute_command(command)
      else
        @stdin, @stdout, @stderr = Open3.popen3(command)
      end
      @error_reader = Thread.new do
        begin
          loop do
            line = @stderr.readline.gsub(@filter, '*** Filtered ***')
            Puppet.debug line
          end
        rescue RuntimeError
          Puppet.debug "We had a runtime error in the daemon."
          kill
        end
      end
      at_exit do
        Puppet.debug "Cleaning up the daemon at exit."
        kill
      end
    end
  end
  # rubocop:enable ClassVars
end
# rubocop: enable Metrics/AbcSize
