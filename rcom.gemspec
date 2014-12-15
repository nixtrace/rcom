# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rcom/version'

Gem::Specification.new do |spec|
  spec.name          = "rcom"
  spec.version       = Rcom::VERSION
  spec.authors       = ["Marco Lisci"]
  spec.email         = ["info@badshark.io"]
  spec.summary       = %q{Redis inter-service messaging.}
  spec.description   = %q{Redis inter-service messaging: request-response, publish-subscribe and tasks.}
  spec.homepage      = "https://github.com/badshark/rcom"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_dependency "redis", "~> 3.1.0"
  spec.add_dependency "msgpack", "~> 0.5.9"
end
