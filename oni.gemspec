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
  gem.has_rdoc    = 'yard'
  gem.license     = 'MIT'

  gem.required_ruby_version = '>= 1.9.3'

  gem.files       = `git ls-files`.split("\n").sort
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files  = gem.files.grep(%r{^(test|spec|features)/})

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'kramdown'
  gem.add_development_dependency 'aws-sdk'
end
