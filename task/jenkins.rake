desc 'Runs all the tests for Jenkins'
task :jenkins => ['ci:setup:rspec', 'test']
