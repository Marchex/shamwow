# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shamwow/version'

Gem::Specification.new do |spec|
  spec.name          = "shamwow"
  spec.version       = Shamwow::VERSION
  spec.authors       = ["Jimmy Carter"]
  spec.email         = ["jcarter@marchex.com"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.summary       = %q{Marchex adhoc systems information aggregator}
  spec.homepage      = 'https://github.marchex.com/marchex/shamwow'
  spec.license       = 'MIT'

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
