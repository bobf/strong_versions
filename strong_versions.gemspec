# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'strong_versions/version'

Gem::Specification.new do |spec|
  spec.name          = 'strong_versions'
  spec.version       = StrongVersions::VERSION
  spec.authors       = ['Bob Farrell']
  spec.email         = ['robertanthonyfarrell@gmail.com']

  spec.summary       = 'Enforce strict versioning on your Gemfile'
  spec.description   = 'Ensure your gems are appropriately versioned'
  spec.homepage      = 'https://github.com/bobf/strong_versions'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end

  spec.bindir        = 'bin'
  spec.executables   = []
  spec.require_paths = ['lib']

  spec.add_dependency 'colorize', '~> 0.8'
  spec.add_dependency 'i18n', '>= 0.5.0'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'byebug', '~> 10.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
  spec.add_development_dependency 'rubocop', '~> 0.60.0'
end
