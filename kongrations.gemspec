# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kongrations/version'

Gem::Specification.new do |spec|
  spec.name          = 'kongrations'
  spec.version       = Kongrations::VERSION
  spec.authors       = ['Danilo Albuquerque']
  spec.email         = ['danilospalbuquerque@gmail.com']

  spec.summary       = 'Migrations for Kong APIs, plugin and consumers.'
  spec.description   = 'Migrations like for your Kong APIs, plugin and consumers.
                        It enables you to create files which describes the operations to be performed on Kong.'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.executables << 'kongrations'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'pry', '0.11.3'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '3.7.0'
  spec.add_development_dependency 'rubocop', '0.54.0'
  spec.add_development_dependency 'webmock', '3.3.0'
end
