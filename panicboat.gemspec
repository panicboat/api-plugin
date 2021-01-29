$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "panicboat/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "panicboat"
  spec.version     = Panicboat::VERSION
  spec.authors     = ["panicboat"]
  spec.email       = ["admin@panicboat.net"]
  spec.homepage    = "https://panicboat.net"
  spec.summary     = ""
  spec.description = "panicboat library for panicboat.net"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "'https://panicboat.net'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.0"

  spec.add_development_dependency "mysql2"
end
