require_relative 'lib/oni/version'

require 'rake/clean'
require 'bundler/gem_tasks'

CLEAN.include('coverage', 'yardoc')

Dir['./task/*.rake'].each do |task|
  import(task)
end

task :default => :test
