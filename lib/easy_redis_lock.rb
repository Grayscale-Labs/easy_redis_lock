require "easy_redis_lock/version"
require 'uri'
require 'redis'

module EasyRedisLock
  class GateKeeper
    attr_reader :delay, :redis

    def initialize delay=1500
      @delay = delay
      @seconds_delay = (delay.to_f / 1000.0)
      @redis = Redis.new(redis_options)
      @lock_time = 30#s
    end

    def should_delay? delay_id
      return unless delay_id
      in_progress?(delay_id)
    end

    def mark_in_progress delay_id
      return unless delay_id
      set_progress delay_id
    end

    def with_lock delay_id=Time.now.to_i, delay=@seconds_delay, &block
      retries = 0
      begin
        while should_delay?(delay_id) do
          sleep(delay)
          retries += 1
          break if retries >= 30
        end
        mark_in_progress(delay_id)
        yield if block_given?
      ensure
        expire_lock(delay_id)
      end
    end

    private

    def redis_options
      url = URI.parse(ENV.fetch('REDIS_URL') {'redis://localhost:6379'} )
      { :host => url.host, :port => url.port }
    end

    def expire_lock delay_id
      @redis.del("easy_redis_lock:#{delay_id}")
    end

    def in_progress? delay_id
      @redis.exists("easy_redis_lock:#{delay_id}")
    end

    def set_progress delay_id
      @redis.setex("easy_redis_lock:#{delay_id}", @lock_time, 1) # auto expires after lock_time seconds (default 30s)
    end
  end
end
