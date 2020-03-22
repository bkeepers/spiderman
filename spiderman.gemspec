require_relative 'lib/spiderman/version'

Gem::Specification.new do |spec|
  spec.name          = "spiderman"
  spec.version       = Spiderman::VERSION
  spec.authors       = ["Brandon Keepers"]
  spec.email         = ["brandon@opensoul.org"]

  spec.summary       = %q{your friendly neighborhood web crawler}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/bkeepers/spiderman"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "http", "~> 4.0"
  spec.add_runtime_dependency "nokogiri", "~> 1.10"
  spec.add_runtime_dependency "activesupport", ">= 5.0"
end
