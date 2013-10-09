require 'rspec'

require_relative 'support/simplecov' if ENV['COVERAGE']
require_relative '../lib/oni'

RSpec.configure do |config|
  config.color = true
end
