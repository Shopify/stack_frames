# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "stack_frames/version"

Gem::Specification.new do |spec|
  spec.name          = "stack_frames"
  spec.version       = StackFrames::VERSION
  spec.authors       = ["Dylan Thacker-Smith"]
  spec.email         = ["gems@shopify.com"]

  spec.summary       = "Zero allocation backtraces using MRI's profile frames API"
  spec.homepage      = "https://github.com/Shopify/stack_frames"
  spec.license       = "MIT"

  spec.extensions    = ['ext/stack_frames/extconf.rb']
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^test/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rake-compiler', '~> 1.0'
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "stackprof", "~> 0.2.13"
end
