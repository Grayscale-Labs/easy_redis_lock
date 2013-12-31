# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'easy_redis_lock/version'

Gem::Specification.new do |spec|
  spec.name          = "easy_redis_lock"
  spec.version       = EasyRedisLock::VERSION
  spec.authors       = ["Hubert Liu"]
  spec.email         = ["hubert.liu@rigor.com"]
  spec.description   = "Easy redis locking gem"
  spec.summary       = "Easy redis locking gem"
  spec.homepage      = "https://github.com/Rigor/easy_redis_lock"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fakeredis"
  spec.add_dependency "redis"
end