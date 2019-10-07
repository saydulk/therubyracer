# -*- encoding: utf-8 -*-
# stub: grape-entity 0.5.2 ruby lib

Gem::Specification.new do |s|
  s.name = "grape-entity".freeze
  s.version = "0.5.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Bleigh".freeze]
  s.date = "2016-11-14"
  s.description = "Extracted from Grape, A Ruby framework for rapid API development with great conventions.".freeze
  s.email = ["michael@intridea.com".freeze]
  s.homepage = "https://github.com/ruby-grape/grape-entity".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "A simple facade for managing the relationship between your model and API.".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<multi_json>.freeze, [">= 1.3.2"])
      s.add_development_dependency(%q<maruku>.freeze, [">= 0"])
      s.add_development_dependency(%q<yard>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 2.9"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    else
      s.add_dependency(%q<multi_json>.freeze, [">= 1.3.2"])
      s.add_dependency(%q<maruku>.freeze, [">= 0"])
      s.add_dependency(%q<yard>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 2.9"])
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<multi_json>.freeze, [">= 1.3.2"])
    s.add_dependency(%q<maruku>.freeze, [">= 0"])
    s.add_dependency(%q<yard>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 2.9"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
  end
end
