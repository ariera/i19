# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'i19/version'

Gem::Specification.new do |spec|
  spec.name          = "i19"
  spec.version       = I19::VERSION
  spec.authors       = ["Alejandro Riera"]
  spec.email         = ["ariera@gmail.com"]
  spec.description   = %q{find untranslated keys in your codebase and help you managing your i18n files}
  spec.summary       = %q{focus on programming, forget about micromanaging your translation files}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  # spec.executables   = ["i19"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "activesupport"
  spec.add_runtime_dependency "activemodel"
  spec.add_runtime_dependency "term-ansicolor"
  spec.add_runtime_dependency "terminal-table"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "pry-stack_explorer"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  # spec.add_development_dependency "pry"
end
