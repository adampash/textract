# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'textract/version'

Gem::Specification.new do |spec|
  spec.name          = "textract"
  spec.version       = Textract::VERSION
  spec.authors       = ["Adam Pash"]
  spec.email         = ["adam.pash@gmail.com"]
  spec.summary       = %q{Extracts article text from a URL}
  spec.description   = %q{Extracts article text from a URL}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "opengraph_parser"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
end
