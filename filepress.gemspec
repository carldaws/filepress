require_relative "lib/filepress/version"

Gem::Specification.new do |spec|
  spec.name        = "filepress"
  spec.version     = Filepress::VERSION
  spec.authors     = ["Carl Dawson"]
  spec.email       = ["email@carldaws.com"]
  spec.homepage    = "https://github.com/carldaws/filepress"
  spec.summary     = "Write content as flat files, use it anywhere in your Rails app."
  spec.description = "Filepress lets you manage content as simple flat files, with all the power of ActiveRecord."
  spec.license     = "MIT"

  spec.metadata["allowed_push_host"]   = "https://rubygems.org"
  spec.metadata["homepage_uri"]        = spec.homepage
  spec.metadata["source_code_uri"]     = "https://github.com/carldawson/filepress"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 5.2"
end
