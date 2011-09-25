module Clockworkd
  class Event
   attr_accessor :job, :block, :cronline, :cron_time, :next_time

    def initialize(job, block, cronline)
      @job = job
      @block = block
      @cronline = cronline
      @cron_time = CronLine.new(@cronline)
      @next_time = @cron_time.next_time
    end

    def to_s
      @job = job
    end

    def time?(t)
      if (t.to_i - @next_time.to_i) > 0
        @next_time = @cron_time.next_time
        return true
      end
      false
    end

    def run(t)
      eval(@block)
    rescue Exception => e
      raise e
    end

  end
end

