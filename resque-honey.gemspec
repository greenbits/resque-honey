# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque/plugins/honey/version'

Gem::Specification.new do |spec|
  spec.name          = 'resque-honey'
  spec.version       = Resque::Plugins::Honey::VERSION
  spec.authors       = ['Trae Robrock']
  spec.email         = ['trobrock@gmail.com']

  spec.summary       = %q{Simple resque plugin for tracking job metrics with Honeycomb.io}
  spec.description   = %q{Simple resque plugin for tracking job metrics with Honeycomb.io}
  spec.homepage      = 'https://github.com/greenbits/resque-honey'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'libhoney', '~> 1.0'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
end
