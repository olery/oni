require File.expand_path('../lib/oni/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name    = 'oni'
  gem.version = Oni::VERSION
  gem.authors = ['Yorick Peterse <yorickpeterse@olery.com>']
  gem.summary = 'Ruby framework for building concurrent job ' \
    'processing applications.'

  gem.description = gem.summary
  gem.has_rdoc    = 'yard'

  gem.required_ruby_version = '>= 1.9.3'

  gem.files       = `git ls-files`.split("\n").sort
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files  = gem.files.grep(%r{^(test|spec|features)/})
end
