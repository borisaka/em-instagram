# -*- encoding: utf-8 -*-
require File.expand_path('../lib/em-instagram/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "em-instagram"
  s.version     = EventMachine::Instagram::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = '2013-04-03'
  s.authors     = ["Joe Pym", "S. Brent Faulkner"]
  s.email       = ["joe@joepym.com", "sbfaulkner@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{}
  s.description = %q{}

  s.required_rubygems_version = ">= 1.3.4"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "eventmachine"
  s.add_dependency 'eventmachine_httpserver'
  s.add_dependency 'em-http-request'
  s.add_dependency 'json' if RUBY_VERSION == '1.8.7'

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  if RUBY_VERSION < '1.9.3'
    s.add_development_dependency('rcov')
  else
    s.add_development_dependency('simplecov')
    s.add_development_dependency('simplecov-rcov')
  end
end
