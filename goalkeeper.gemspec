# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'goalkeeper/version'

Gem::Specification.new do |spec|
  spec.name          = "goalkeeper"
  spec.version       = Goalkeeper::VERSION
  spec.authors       = ["John Weir"]
  spec.email         = ["john@smokinggun.com"]
  spec.summary       = %q{A Todo App for your application.}
  spec.description   = %q{Goalkeeper is a system for validation that specific goals have been met by an application.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "redis", "~> 3"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
