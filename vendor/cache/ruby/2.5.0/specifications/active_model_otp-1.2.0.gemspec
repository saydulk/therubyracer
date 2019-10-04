# -*- encoding: utf-8 -*-
# stub: active_model_otp 1.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "active_model_otp".freeze
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Guillermo Iguaran".freeze, "Roberto Miranda".freeze, "Heapsource".freeze]
  s.date = "2015-02-26"
  s.description = "Adds methods to set and authenticate against one time passwords. Inspired in AM::SecurePassword\"".freeze
  s.email = ["guilleiguaran@gmail.com".freeze, "rjmaltamar@gmail.com".freeze, "hello@firebase.co".freeze]
  s.homepage = "".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "Adds methods to set and authenticate against one time passwords.".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activemodel>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<rotp>.freeze, [">= 0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.4.2"])
    else
      s.add_dependency(%q<activemodel>.freeze, [">= 0"])
      s.add_dependency(%q<rotp>.freeze, [">= 0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.4.2"])
    end
  else
    s.add_dependency(%q<activemodel>.freeze, [">= 0"])
    s.add_dependency(%q<rotp>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.4.2"])
  end
end
