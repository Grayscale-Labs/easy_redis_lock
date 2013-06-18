# EasyRedisLock

    A simple redis locking gem to help with race conditions.

## Installation

Add this line to your application's Gemfile:

    gem 'easy_redis_lock', :git => 'git://github.com/Rigor/easy_redis_lock.git'

And then execute:

    $ bundle

## Usage

  Easy:
  ```ruby
  EasyRedisLock::GateKeeper.new.with_lock("unique_lock_key") { # code to wrap in the redis lock }
  ```

  ```ruby
  @record = Record.find(99)
  EasyRedisLock::GateKeeper.new.with_lock(@record.id) do
    status = @record.run_count > 5 ? "done" : "in progress"
    @record.update_attribute(:status, status)
  end
  ```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
