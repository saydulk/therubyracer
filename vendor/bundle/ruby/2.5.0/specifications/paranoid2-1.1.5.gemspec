# -*- encoding: utf-8 -*-
# stub: paranoid2 1.1.5 ruby lib

Gem::Specification.new do |s|
  s.name = "paranoid2".freeze
  s.version = "1.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["yury".freeze]
  s.date = "2014-04-14"
  s.description = "paranoid models for rails 4".freeze
  s.email = ["yury.korolev@gmail.com".freeze]
  s.homepage = "https://github.com/anjlab/paranoid2".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "paranoid models for rails 4".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>.freeze, [">= 4.1.0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
    else
      s.add_dependency(%q<activerecord>.freeze, [">= 4.1.0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>.freeze, [">= 4.1.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
  end
end
