require 'rubygems'
require 'daemons'
require 'optparse'

module Clockworkd
  class Command

    def initialize(args)
      @files_to_reopen = []
      @options = {
        :quiet => true,
        :identifier => 0,
        :pid_dir => "#{Rails.root}/tmp/pids",
        :clock_file => "#{Rails.root}/config/clockworkd.yml"
      }

      @monitor = false

      opts = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename($0)} [options] start|stop|restart|run"

        opts.on('-h', '--help', 'Show this message') do
          puts opts
          exit 1
        end
        opts.on('--clock-file=FILE', 'Specifies an alternate clockwork file with schuduling.') do |file|
          @options[:clock_file] = file
        end
        opts.on('--pid-dir=DIR', 'Specifies an alternate directory in which to store the process ids.') do |dir|
          @options[:pid_dir] = dir
        end
        opts.on('-i', '--identifier=n', 'A numeric identifier for the clockwork process.') do |n|
          @options[:identifier] = n
        end
        opts.on('-m', '--monitor', 'Start monitor process.') do
          @monitor = true
        end
        opts.on('--sleep-delay N', "Amount of time to sleep when no events are found") do |n|
          @options[:sleep_delay] = n
        end
      end
      @args = opts.parse!(args)
    end

    def daemonize
      ObjectSpace.each_object(File) do |file|
        @files_to_reopen << file unless file.closed?
      end

      dir = @options[:pid_dir]
      Dir.mkdir(dir) unless File.exists?(dir)

      process_name = "clockworkd.#{@options[:identifier]}"
      run_process(process_name, dir)
    end

    def run_process(process_name, dir)
      Daemons.run_proc(process_name, :multiple => false, :dir => dir, :dir_mode => :normal, :monitor => @monitor, :ARGV => @args) do |*args|
        run process_name
      end
    end

    def run(worker_name = nil)
      Dir.chdir(Rails.root)

      # Re-open file handles
      @files_to_reopen.each do |file|
        begin
          file.reopen file.path, "a+"
          file.sync = true
        rescue ::Exception
        end
      end

      Clockworkd::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'clockworkd.log'))
      Clockworkd::Worker.new(@options).run
    rescue => e
      Rails.logger.fatal e
      STDERR.puts e.message
      exit 1
    end

  end
end
