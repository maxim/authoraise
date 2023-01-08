# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'authoraise/version'

Gem::Specification.new do |spec|
  spec.name          = "authoraise"
  spec.version       = Authoraise::VERSION
  spec.authors       = ["Max Chernyak"]
  spec.email         = ["hello@max.engineer"]

  spec.summary       = %q{Authorize without false negatives.}
  spec.homepage      = "https://github.com/maxim/authoraise"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
