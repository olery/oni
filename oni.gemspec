require File.expand_path('../lib/oni/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name    = 'oni'
  gem.version = Oni::VERSION
  gem.authors = [
    'Olery <info@olery.com>',
    'Yorick Peterse <yorickpeterse@gmail.com>',
    'Wilco van Duinkerken <wilcovanduinkerken@olery.com>'
  ]

  gem.summary = 'Ruby framework for building concurrent job ' \
    'processing applications.'

  gem.description = gem.summary
  gem.has_rdoc    = 'yard'

  gem.required_ruby_version = '>= 1.9.3'

  gem.files       = `git ls-files`.split("\n").sort
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files  = gem.files.grep(%r{^(test|spec|features)/})

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'kramdown'
  gem.add_development_dependency 'ci_reporter'
end
