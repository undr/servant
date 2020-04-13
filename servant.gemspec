# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'servant/version'

Gem::Specification.new do |spec|
  spec.name          = 'servant'
  spec.version       = Servant::VERSION
  spec.authors       = ['undr']
  spec.email         = ['undr@yandex.ru']

  spec.summary       = %q{Build an army of servants and command them.}
  spec.description   = %q{Build an army of servants and command them.}
  spec.homepage      = 'https://github.com/undr/servant'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel'

  spec.add_development_dependency 'bundler', '>= 2.0'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'rspec-collection_matchers'
end
