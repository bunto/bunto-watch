# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "bunto-watch"
  spec.version       = "1.0.0"
  spec.authors       = ["Parker Moore", "Suriyaa Kudo"]
  spec.email         = ["parkrmoore@gmail.com", "SuriyaaKudoIsc@users.noreply.github.com"]
  spec.summary       = %q{Rebuild your Bunto site when a file changes with the `--watch` switch.}
  spec.homepage      = "https://github.com/bunto/bunto-watch"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").grep(%r{(bin|lib)/})
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "listen", "~> 3.0"

  require 'rbconfig'
  if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
    spec.add_runtime_dependency "wdm", "~> 0.1.0"
  end

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rubocop", "~> 0.35.1"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "bunto", ENV["BUNTO_VERSION"] ? "~> #{ENV["BUNTO_VERSION"]}" : ">= 1.0"
end
