# -*- encoding: utf-8 -*-
# stub: validates_zipcode 0.2.2 ruby lib

Gem::Specification.new do |s|
  s.name = "validates_zipcode".freeze
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Gil".freeze]
  s.date = "2019-08-15"
  s.description = "Adds zipcode validation methods to ActiveModel considering different country zipcode formats.".freeze
  s.email = ["dgilperez@gmail.com".freeze]
  s.homepage = "http://github.com/dgilperez/validates_zipcode".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.rubygems_version = "3.0.6".freeze
  s.summary = "Localizable zipcode validation for Rails.".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activemodel>.freeze, [">= 3.2.0"])
      s.add_development_dependency(%q<appraisal>.freeze, [">= 0"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 12.2.1"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
    else
      s.add_dependency(%q<activemodel>.freeze, [">= 3.2.0"])
      s.add_dependency(%q<appraisal>.freeze, [">= 0"])
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, ["~> 12.2.1"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<activemodel>.freeze, [">= 3.2.0"])
    s.add_dependency(%q<appraisal>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.2.1"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
  end
end
