# -*- encoding: utf-8 -*-
# stub: omniauth-identity 1.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "omniauth-identity".freeze
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Bleigh".freeze]
  s.date = "2013-07-04"
  s.description = "Internal authentication handlers for OmniAuth.".freeze
  s.email = ["michael@intridea.com".freeze]
  s.homepage = "http://github.com/intridea/omniauth-identity".freeze
  s.rubygems_version = "3.0.6".freeze
  s.summary = "Internal authentication handlers for OmniAuth.".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<omniauth>.freeze, ["~> 1.0"])
      s.add_runtime_dependency(%q<bcrypt-ruby>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<maruku>.freeze, ["~> 0.6"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.4"])
      s.add_development_dependency(%q<rack-test>.freeze, ["~> 0.5"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 0.8"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 2.7"])
      s.add_development_dependency(%q<activerecord>.freeze, ["~> 3.1"])
      s.add_development_dependency(%q<mongoid>.freeze, [">= 0"])
      s.add_development_dependency(%q<mongo_mapper>.freeze, [">= 0"])
      s.add_development_dependency(%q<datamapper>.freeze, [">= 0"])
      s.add_development_dependency(%q<bson_ext>.freeze, [">= 0"])
      s.add_development_dependency(%q<couch_potato>.freeze, [">= 0"])
    else
      s.add_dependency(%q<omniauth>.freeze, ["~> 1.0"])
      s.add_dependency(%q<bcrypt-ruby>.freeze, ["~> 3.0"])
      s.add_dependency(%q<maruku>.freeze, ["~> 0.6"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.4"])
      s.add_dependency(%q<rack-test>.freeze, ["~> 0.5"])
      s.add_dependency(%q<rake>.freeze, ["~> 0.8"])
      s.add_dependency(%q<rspec>.freeze, ["~> 2.7"])
      s.add_dependency(%q<activerecord>.freeze, ["~> 3.1"])
      s.add_dependency(%q<mongoid>.freeze, [">= 0"])
      s.add_dependency(%q<mongo_mapper>.freeze, [">= 0"])
      s.add_dependency(%q<datamapper>.freeze, [">= 0"])
      s.add_dependency(%q<bson_ext>.freeze, [">= 0"])
      s.add_dependency(%q<couch_potato>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<omniauth>.freeze, ["~> 1.0"])
    s.add_dependency(%q<bcrypt-ruby>.freeze, ["~> 3.0"])
    s.add_dependency(%q<maruku>.freeze, ["~> 0.6"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.4"])
    s.add_dependency(%q<rack-test>.freeze, ["~> 0.5"])
    s.add_dependency(%q<rake>.freeze, ["~> 0.8"])
    s.add_dependency(%q<rspec>.freeze, ["~> 2.7"])
    s.add_dependency(%q<activerecord>.freeze, ["~> 3.1"])
    s.add_dependency(%q<mongoid>.freeze, [">= 0"])
    s.add_dependency(%q<mongo_mapper>.freeze, [">= 0"])
    s.add_dependency(%q<datamapper>.freeze, [">= 0"])
    s.add_dependency(%q<bson_ext>.freeze, [">= 0"])
    s.add_dependency(%q<couch_potato>.freeze, [">= 0"])
  end
end
