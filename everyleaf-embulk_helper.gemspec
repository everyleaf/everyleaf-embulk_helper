# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'everyleaf/embulk_helper/version'

Gem::Specification.new do |spec|
  spec.name          = "everyleaf-embulk_helper"
  spec.version       = Everyleaf::EmbulkHelper::VERSION
  spec.authors       = ["yoshihara", "uu59"]
  spec.email         = ["h.yoshihara@everyleaf.com", "k@uu59.org"]
  spec.summary       = %q{Add some handy helpers for developing Embulk plugins}
  spec.description   = %q{Add some handy helpers for developing Embulk plugins}
  spec.homepage      = "https://github.com/everyleaf/everyleaf-embulk-helper"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "test-unit-rr"
  spec.add_development_dependency "pry"
  spec.add_development_dependency 'codeclimate-test-reporter'
end
