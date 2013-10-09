require 'simplecov'

SimpleCov.configure do
  root         File.expand_path('../../../', __FILE__)
  command_name 'rspec'
  project_name 'oni'

  add_filter 'spec'
  add_filter 'lib/oni/version'
end

SimpleCov.start
