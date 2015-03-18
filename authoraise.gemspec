# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'authoraise/version'

Gem::Specification.new do |spec|
  spec.name          = "authoraise"
  spec.version       = Authoraise::VERSION
  spec.authors       = ["Maxim Chernyak"]
  spec.email         = ["max@bitsonnet.com"]

  spec.summary       = %q{Authorize without false negatives.}
  spec.homepage      = "https://github.com/maxim/authoraise"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "minitest"
end
