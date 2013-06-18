# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'easy_redis_lock/version'

Gem::Specification.new do |gem|
  gem.name          = "easy_redis_lock"
  gem.version       = EasyRedisLock::VERSION
  gem.authors       = ["Hubert Liu"]
  gem.email         = ["hubert.liu@rigor.com"]
  gem.description   = "Easy redis locking gem"
  gem.summary       = "Easy redis locking gem"
  gem.homepage      = "https://github.com/Rigor/easy_redis_lock"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end