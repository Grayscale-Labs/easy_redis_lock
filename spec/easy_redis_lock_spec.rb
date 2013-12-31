require 'spec_helper'

describe EasyRedisLock::GateKeeper do

  let!(:gatekeeper) { EasyRedisLock::GateKeeper.new }

  it "should delay if the lock id exists" do
    gatekeeper.redis.set("easy_redis_lock:locked_key", 1)
    gatekeeper.should_delay?("locked_key").should be_true
  end

  it "should not delay if the lock id doesnt exist" do
    gatekeeper.should_delay?("not_locked_key").should be_false
  end

  context "redis provided" do
    it "uses that redis connection" do
      keeper = EasyRedisLock::GateKeeper.new(:redis => Redis.new(:host => "someredishost", :port => 6379))
      expect(keeper.redis.client.host).to eql("someredishost")
    end
  end

  context "redis not provided" do
    it "creates a redis connection" do
      keeper = EasyRedisLock::GateKeeper.new
      expect(keeper.redis.client.host).to eql("127.0.0.1")
    end
  end

  context "#with_lock" do
    it "should sleep the delay time if required" do
      gatekeeper.redis.set("easy_redis_lock:pop_and_lock", 1)

      gatekeeper.should_receive(:sleep).at_least(1).times.with(1.0)
      gatekeeper.with_lock("pop_and_lock", 1) {}
    end

    it "should not sleep the delay time if not locked" do
      gatekeeper.should_not_receive(:sleep)
      gatekeeper.with_lock("not_pop_and_lock", 1) {}
    end

    it "should locked the key if not locked and unlock after" do
      gatekeeper.should_not_receive(:sleep)
      gatekeeper.with_lock("not_pop_and_lock", 1) {
        gatekeeper.redis.exists("easy_redis_lock:not_pop_and_lock").should be_true
      }
      gatekeeper.redis.exists("easy_redis_lock:not_pop_and_lock").should be_false
    end

    it "should stop trying after 30 tries" do
      gatekeeper.redis.set("easy_redis_lock:pop_and_lock", 1)

      gatekeeper.should_receive(:sleep).exactly(30).times
      gatekeeper.with_lock("pop_and_lock", 1) {}

    end
  end

end