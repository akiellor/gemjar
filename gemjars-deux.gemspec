# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gemjars/deux/version'

Gem::Specification.new do |spec|
  spec.name          = "gemjars-deux"
  spec.version       = Gemjars::Deux::VERSION
  spec.authors       = ["Andrew Kiellor"]
  spec.email         = ["akiellor@gmail.com"]
  spec.description   = %q{Manage a gemjars repository.}
  spec.summary       = %q{Manage a gemjars repository.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "aws-sdk", "~> 1.8.5"
  spec.add_runtime_dependency "builder", "~> 3.0.0"
  spec.add_runtime_dependency "celluloid", "~> 0.13.0"
  spec.add_runtime_dependency "clamp", "~> 0.6.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec", "~> 2.11.0"
  spec.add_development_dependency "nokogiri", "~> 1.5.9"
  spec.add_development_dependency "rake"
end
