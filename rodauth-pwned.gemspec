Gem::Specification.new do |spec|
  spec.name          = "rodauth-pwned"
  spec.version       = "0.2.1"
  spec.authors       = ["Janko Marohnić"]
  spec.email         = ["janko.marohnic@gmail.com"]

  spec.summary       = "Rodauth extension for checking whether a password had been exposed in a database breach according to https://haveibeenpwned.com."
  spec.description   = "Rodauth extension for checking whether a password had been exposed in a database breach according to https://haveibeenpwned.com."
  spec.homepage      = "https://github.com/janko/rodauth-pwned"
  spec.license       = "MIT"

  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files         = Dir["README.md", "LICENSE.txt", "*.gemspec", "lib/**/*", "locales/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rodauth", "~> 2.0"
  spec.add_dependency "pwned", "~> 2.1"

  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-hooks"
  spec.add_development_dependency "tilt"
  spec.add_development_dependency "bcrypt"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "rodauth-i18n"
end
