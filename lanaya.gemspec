# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lanaya/version'

Gem::Specification.new do |spec|
  spec.name          = "lanaya"
  spec.version       = Lanaya::VERSION
  spec.authors       = ["Meck"]
  spec.email         = ["yesmeck@gmail.com"]
  spec.summary       = %q{A HTTP Debuger.}
  spec.description   = %q{Lanaya provide a easy way to let you debug HTTP requests.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'em-proxy', '~> 0.1.8'
  spec.add_dependency 'http_parser.rb', '~> 0.6.0'
  spec.add_dependency 'uuid', '~> 2.3.7'
  spec.add_dependency 'sinatra', '~> 1.4.4'
  spec.add_dependency 'sinatra-contrib', '~> 1.4.2'
  spec.add_dependency 'thin', '~> 1.5.0'
  spec.add_dependency 'skinny', '~> 0.2.3'
  spec.add_dependency 'activesupport', '~> 4.0.2'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry-nav"
end
