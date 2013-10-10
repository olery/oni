require_relative 'lib/oni/version'

require 'bundler/gem_tasks'
require 'ci/reporter/rake/rspec'

Dir['./task/*.rake'].each do |task|
  import(task)
end

task :default => :test
