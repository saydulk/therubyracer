# -*- encoding: utf-8 -*-
# stub: fusioncharts-rails 0.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "fusioncharts-rails".freeze
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["FusionCharts".freeze]
  s.date = "2015-01-07"
  s.description = "Server Wrapper for rendering FusionCharts on Rails".freeze
  s.email = ["mail@labs.fusioncharts.com".freeze]
  s.homepage = "https://github.com/fusioncharts/rails-wrapper".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "Wrapper for fusioncharts".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<rails>.freeze, [">= 3.2"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.1.0"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<rails>.freeze, [">= 3.2"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.1.0"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rails>.freeze, [">= 3.2"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.1.0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
  end
end
