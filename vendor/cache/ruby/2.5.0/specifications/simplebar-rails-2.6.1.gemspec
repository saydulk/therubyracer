# -*- encoding: utf-8 -*-
# stub: simplebar-rails 2.6.1 ruby lib

Gem::Specification.new do |s|
  s.name = "simplebar-rails".freeze
  s.version = "2.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Thomas Hutterer".freeze]
  s.date = "2018-04-12"
  s.description = "    SimpleBar is a plugin that tries to solve a long time problem : how to get custom scrollbars for your web-app?\n    This gem allows for its easy inclusion into the rails asset pipeline.\n".freeze
  s.email = ["thutterer@suse.de".freeze]
  s.homepage = "https://github.com/thutterer/simplebar-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "The SimpleBar Javascript library for the Rails asset pipeline.".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, [">= 3.1"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.14"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    else
      s.add_dependency(%q<railties>.freeze, [">= 3.1"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.14"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    end
  else
    s.add_dependency(%q<railties>.freeze, [">= 3.1"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.14"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
  end
end
