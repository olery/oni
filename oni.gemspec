require File.expand_path('../lib/oni/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name    = 'oni'
  gem.version = Oni::VERSION
  gem.authors = [
    'Yorick Peterse',
    'Wilco van Duinkerken'
  ]

  gem.summary     = 'Framework for building concurrent daemons in Ruby.'
  gem.description = gem.summary
  gem.license     = 'MIT'

  gem.required_ruby_version = '>= 1.9.3'

  gem.files = Dir.glob([
    'doc/**/*',
    'lib/**/*.rb',
    'README.md',
    'LICENSE',
    'oni.gemspec',
    '.yardopts'
  ]).select { |file| File.file?(file) }

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'kramdown'
  gem.add_development_dependency 'pry'

  gem.add_dependency 'rexml' # needed by aws-sdk
  gem.add_dependency 'aws-sdk-sqs', '~> 1.0'
end
