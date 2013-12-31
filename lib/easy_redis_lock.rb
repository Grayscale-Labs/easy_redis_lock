require "easy_redis_lock/version"
require 'uri'
require 'redis'

module EasyRedisLock
  class GateKeeper
    attr_reader :delay, :redis, :seconds_delay, :lock_time

    def initialize options={}
      @delay = options.fetch(:delay, 1500)
      @lock_time = options.fetch(:lock_time, 30) # seconds
      @redis = options.fetch(:redis) { Redis.new }
    end

    def should_delay? delay_key
      in_progress? delay_key
    end

    def mark_in_progress delay_key
      set_progress delay_key
    end

    def with_lock delay_key=Time.now.to_i, delay=seconds_delay, &block
      retries = 0
      begin
        while should_delay?(delay_key) do
          sleep(delay)
          retries += 1
          break if retries >= 30
        end
        mark_in_progress(delay_key)
        yield if block_given?
      ensure
        expire_lock(delay_key)
      end
    end

    def cleanup
      close_connection!
    end

    private

    def seconds_delay
      delay.to_f / 1000.0
    end

    def close_connection!
      redis.quit
    end

    def expire_lock delay_key
      redis.del("easy_redis_lock:#{delay_key}")
    end

    def in_progress? delay_key
      redis.exists("easy_redis_lock:#{delay_key}")
    end

    def set_progress delay_key
      redis.setex("easy_redis_lock:#{delay_key}", lock_time, 1) # auto expires after lock_time seconds
    end
  end
end
