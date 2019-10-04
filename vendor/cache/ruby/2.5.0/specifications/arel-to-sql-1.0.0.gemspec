# -*- encoding: utf-8 -*-
# stub: arel-to-sql 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "arel-to-sql".freeze
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Yaroslav Konoplov".freeze]
  s.date = "2017-03-27"
  s.description = "Adds to_sql to arel table and attribute.".freeze
  s.email = "eahome00@gmail.com".freeze
  s.homepage = "https://github.com/yivo/arel-to-sql".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "Adds to_sql to arel table and attribute.".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<arel>.freeze, [">= 6.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 12.0"])
      s.add_development_dependency(%q<test-unit>.freeze, ["~> 3.2"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.7"])
      s.add_development_dependency(%q<appraisal>.freeze, ["~> 2.1"])
    else
      s.add_dependency(%q<arel>.freeze, [">= 6.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 12.0"])
      s.add_dependency(%q<test-unit>.freeze, ["~> 3.2"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
      s.add_dependency(%q<appraisal>.freeze, ["~> 2.1"])
    end
  else
    s.add_dependency(%q<arel>.freeze, [">= 6.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.0"])
    s.add_dependency(%q<test-unit>.freeze, ["~> 3.2"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
    s.add_dependency(%q<appraisal>.freeze, ["~> 2.1"])
  end
end
