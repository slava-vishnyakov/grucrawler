# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grucrawler/version'

Gem::Specification.new do |spec|
  spec.name          = "grucrawler"
  spec.version       = GruCrawler::VERSION
  spec.authors       = ["Slava Vishnyakov"]
  spec.email         = ["bomboze@gmail.com"]
  spec.summary       = %q{Simple crawler using Redis as backend}
  spec.description   = %q{Simple crawler using Redis as backend}
  spec.homepage      = "https://github.com/slava-vishnyakov/grucrawler"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_dependency "typhoeus"
  spec.add_dependency "redis"
  spec.add_dependency "nokogiri"

end
