# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yard-lucid/version'

Gem::Specification.new do |spec|
  spec.name          = "yard-lucid"
  spec.version       = YardLucid::VERSION
  spec.authors       = ["Jeff Nyman"]
  spec.email         = ["jeffnyman@gmail.com"]

  spec.summary       = %q{YARD Documentation Generator for Gherkin-based Repositories}
  spec.description   = %q{YARD Documentation Generator for Gherkin-based Repositories}
  spec.homepage      = "https://github.com/jeffnyman/yard-lucid"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"

  spec.add_runtime_dependency "yard"
  spec.add_runtime_dependency "gherkin", "~> 5.0"
  spec.add_runtime_dependency "cucumber", "~> 3.0"

  spec.post_install_message = %{
(::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::)
  Yard-Lucid #{YardLucid::VERSION} has been installed.
(::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::)
  }
end
