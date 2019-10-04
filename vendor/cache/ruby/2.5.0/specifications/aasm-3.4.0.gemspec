# -*- encoding: utf-8 -*-
# stub: aasm 3.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "aasm".freeze
  s.version = "3.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Scott Barron".freeze, "Travis Tilley".freeze, "Thorsten Boettger".freeze]
  s.date = "2014-09-12"
  s.description = "AASM is a continuation of the acts as state machine rails plugin, built for plain Ruby objects.".freeze
  s.email = "scott@elitists.net, ttilley@gmail.com, aasm@mt7.de".freeze
  s.homepage = "https://github.com/aasm/aasm".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "State machine mixin for Ruby objects".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<sdoc>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 2.14"])
      s.add_development_dependency(%q<rr>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_development_dependency(%q<mime-types>.freeze, ["~> 1.25"])
    else
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<sdoc>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 2.14"])
      s.add_dependency(%q<rr>.freeze, [">= 0"])
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_dependency(%q<mime-types>.freeze, ["~> 1.25"])
    end
  else
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<sdoc>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 2.14"])
    s.add_dependency(%q<rr>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<mime-types>.freeze, ["~> 1.25"])
  end
end
