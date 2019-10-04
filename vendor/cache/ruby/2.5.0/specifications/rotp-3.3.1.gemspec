# -*- encoding: utf-8 -*-
# stub: rotp 3.3.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rotp".freeze
  s.version = "3.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mark Percival".freeze]
  s.date = "2018-03-02"
  s.description = "Works for both HOTP and TOTP, and includes QR Code provisioning".freeze
  s.email = ["mark@markpercival.us".freeze]
  s.executables = ["rotp".freeze]
  s.files = ["bin/rotp".freeze]
  s.homepage = "http://github.com/mdp/rotp".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "A Ruby library for generating and verifying one time passwords".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.5"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5"])
      s.add_development_dependency(%q<timecop>.freeze, ["~> 0.8"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.12"])
    else
      s.add_dependency(%q<rake>.freeze, ["~> 10.5"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.5"])
      s.add_dependency(%q<timecop>.freeze, ["~> 0.8"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.12"])
    end
  else
    s.add_dependency(%q<rake>.freeze, ["~> 10.5"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5"])
    s.add_dependency(%q<timecop>.freeze, ["~> 0.8"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.12"])
  end
end
