# frozen_string_literal: true

require_relative "lib/filepress/version"

Gem::Specification.new do |spec|
  spec.name = "filepress"
  spec.version       = Filepress::VERSION
  spec.authors       = ["Carl Dawson"]
  spec.email         = ["email@carldaws.com"]

  spec.summary       = "Write content as flat files, use it anywhere in your Rails app."
  spec.description   = "Filepress lets you manage content as simple flat files, with all the power of ActiveRecord."
  spec.homepage      = "https://github.com/carldaws/filepress"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"]   = "https://rubygems.org"
  spec.metadata["homepage_uri"]        = spec.homepage
  spec.metadata["source_code_uri"]     = "https://github.com/carldawson/filepress"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 5.2"
end
