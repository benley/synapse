# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'synapse/version'

Gem::Specification.new do |gem|
  gem.name          = 'synapse-aurora'
  gem.version       = Synapse::VERSION
  gem.authors       = ['Martin Rhoads']
  gem.email         = ['martin.rhoads@airbnb.com']
  gem.summary       = 'Fork of Airbnb Synapse with support for Apache Aurora'
  gem.description   = <<-EOF
Synapse is Airbnb's new system for service discovery.  Synapse solves the
problem of automated fail-over in the cloud, where failover via network
re-configuration is impossible.  The end result is the ability to connect
internal services together in a scalable, fault-tolerant way.

This is a forked version which adds support for Apache Aurora service
announcements.
EOF
  gem.homepage      = 'https://github.com/benley/synapse'
  gem.license       = 'MIT'

  gem.files         = Dir['*', 'bin/*', 'config/**/*', 'lib/**/*', 'spec/**/*']
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})

  gem.add_runtime_dependency 'aws-sdk', '~> 1.39'
  gem.add_runtime_dependency 'docker-api', '~> 1.7', '>= 1.7.2'
  gem.add_runtime_dependency 'zk', '~> 1.9', '>= 1.9.4'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-nav'
end
