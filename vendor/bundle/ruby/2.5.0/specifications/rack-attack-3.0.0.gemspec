# -*- encoding: utf-8 -*-
# stub: rack-attack 3.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rack-attack".freeze
  s.version = "3.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Aaron Suggs".freeze]
  s.date = "2014-03-15"
  s.description = "A rack middleware for throttling and blocking abusive requests".freeze
  s.email = "aaron@ktheory.com".freeze
  s.homepage = "http://github.com/kickstarter/rack-attack".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--charset=UTF-8".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2".freeze)
  s.rubygems_version = "3.0.6".freeze
  s.summary = "Block & throttle abusive requests".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_development_dependency(%q<rack-test>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<activesupport>.freeze, [">= 3.0.0"])
      s.add_development_dependency(%q<redis-activesupport>.freeze, [">= 0"])
      s.add_development_dependency(%q<dalli>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rack>.freeze, [">= 0"])
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_dependency(%q<rack-test>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<activesupport>.freeze, [">= 3.0.0"])
      s.add_dependency(%q<redis-activesupport>.freeze, [">= 0"])
      s.add_dependency(%q<dalli>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rack>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<rack-test>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 3.0.0"])
    s.add_dependency(%q<redis-activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<dalli>.freeze, [">= 0"])
  end
end
