require 'rspec'

require_relative 'support/simplecov' if ENV['COVERAGE']
require_relative '../lib/oni'

RSpec.configure do |config|

  config.color = true

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.around :each do |example|
    Timeout.timeout 10 do
      example.run
    end
  end

end

