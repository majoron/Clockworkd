require 'logger'

module Clockworkd
  class Worker
    cattr_accessor :clock_file, :sleep_delay, :logger
    self.clock_file = "#{::Rails.root}/config/clockworkd.yml"
    self.sleep_delay = 5

    self.logger = if defined?(::Rails)
      ::Rails.logger
    elsif defined?(RAILS_DEFAULT_LOGGER)
      RAILS_DEFAULT_LOGGER
    end

    # name_prefix is ignored if name is set directly
    attr_accessor :events

    def initialize(options={})
      self.events = []

      @quiet = options.has_key?(:quiet) ? options[:quiet] : true
      self.class.clock_file = options[:clock_file] if options.has_key?(:clock_file)
      self.class.sleep_delay = options[:sleep_delay] if options.has_key?(:sleep_delay)
    end

    # Every worker has a unique name which by default is the pid of the process. There are some
    # advantages to overriding this with something which survives worker retarts:  Workers can#
    # safely resume working on tasks which are locked by themselves. The worker will assume that
    # it crashed before.
    def name
      return @name unless @name.nil?
      "host:#{Socket.gethostname} pid:#{Process.pid}" rescue "pid:#{Process.pid}"
    end

    # Sets the name of the worker.
    # Setting the name to nil will reset the default worker name
    def name=(val)
      @name = val
    end


    def run
      trap('TERM') { log 'Exiting...'; $exit = true }
      trap('INT')  { log 'Exiting...'; $exit = true }

      # Load scheduling
      log "Load file with scheduling #{self.class.clock_file.to_s}"
      yml_file = YAML::load(File.open(self.class.clock_file))
      yml_file.each do |key, value|
        job = key
        block = value["block"]
        cronline = value["cron"]
        self.events << Event.new(job, block, cronline)
      end

      # Start a processing
      log "Starting clock for #{self.events.size} events: [ " + self.events.map { |e| e.to_s }.join(' ') + " ]"
      loop do
        tick
        break if $exit
        sleep(self.class.sleep_delay)
        break if $exit
      end
    end

    def tick(t=Time.now)
      to_run = self.events.select do |event|
        event.time?(t)
      end

      to_run.each do |event|
        log "Triggering #{event} with cronline #{event.cronline} and next time: #{event.next_time}"
        begin
          event.run(t)
        rescue Exception => e
          log "Unable to execute #{event} with error: #{e.to_s}", Logger::ERROR
          raise e
        end
      end

      to_run
    end

    def log(text, level = Logger::INFO)
      text = "[Worker(#{name})] #{text}"
      puts text unless @quiet
      logger.add level, "#{Time.now.strftime('%FT%T%z')}: #{text}" if logger
    end


  end
end
