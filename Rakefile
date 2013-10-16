require "bundler"
Bundler.setup
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

if RUBY_VERSION < '1.9.3'
  require 'rcov/rcovtask'

  desc "Run all specs with rcov in spec directory"
  RSpec::Core::RakeTask.new(:rcov) do |t|
    t.rcov = true
    t.rcov_opts = "--output coverage/rcov --exclude '^(?!lib)'"
  #   t.rspec_opts = ["--profile", "--format progress"]
  #   t.rcov_opts  = "--failure-threshold --rails --exclude test/*,spec/*,features/*,factories/*,gems/*"
  #   t.verbose    = false
  end

  desc 'Default: run specs under rcov.'
  task :default => :rcov
else
  desc 'Default: run specs.'
  task :default => :spec
end
