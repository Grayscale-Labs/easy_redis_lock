require "easy_redis_lock/version"

module EasyRedisLock
  class Gatekeeper
    attr_reader :delay

    REDIS_URL = URI.parse(ENV.fetch('REDIS_URL'))
    REDIS_HOST = REDIS_URL.host
    REDIS_PORT = REDIS_URL.port

    def initialize delay=1500 # ms
      @delay = delay
      @seconds_delay = (delay.to_f / 1000.0)
      @redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT)
      @lock_time = 30000 #ms
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
        if should_delay?(delay_id)
          sleep(delay)
          retries += 1
          expire_lock(delay_id) and return if retries > 30
          retry
        else
          mark_in_progress(delay_id)
          yield if block_given?
        end
      ensure
        expire_lock(delay_id)
      end
    end

    private

    def expire_lock delay_id
      @redis.del("redis_lock:#{delay_id}")
    end

    def in_progress? delay_id
      @redis.exists("redis_lock:#{delay_id}")
    end

    def set_progress delay_id
      @redis.psetex("redis_lock:#{delay_id}", @lock_time, 1) # auto expires after lock_time seconds (default 30s)
    end
  end
end
