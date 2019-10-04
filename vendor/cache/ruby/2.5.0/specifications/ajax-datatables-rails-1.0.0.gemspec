# -*- encoding: utf-8 -*-
# stub: ajax-datatables-rails 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "ajax-datatables-rails".freeze
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Joel Quenneville".freeze, "Antonio Antillon".freeze]
  s.date = "2018-08-25"
  s.description = "A wrapper around datatable's ajax methods that allow synchronization with server-side pagination in a rails app".freeze
  s.email = ["joel.quenneville@collegeplus.org".freeze, "antillas21@gmail.com".freeze]
  s.homepage = "https://github.com/jbox-web/ajax-datatables-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "A gem that simplifies using datatables and hundreds of records via ajax".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, [">= 4.2"])
      s.add_development_dependency(%q<rails>.freeze, [">= 4.2"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<pg>.freeze, ["< 1.0"])
      s.add_development_dependency(%q<mysql2>.freeze, [">= 0"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_development_dependency(%q<activerecord-oracle_enhanced-adapter>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<generator_spec>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry>.freeze, [">= 0"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_development_dependency(%q<database_cleaner>.freeze, [">= 0"])
      s.add_development_dependency(%q<factory_bot>.freeze, [">= 0"])
      s.add_development_dependency(%q<faker>.freeze, [">= 0"])
      s.add_development_dependency(%q<appraisal>.freeze, [">= 0"])
    else
      s.add_dependency(%q<railties>.freeze, [">= 4.2"])
      s.add_dependency(%q<rails>.freeze, [">= 4.2"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<pg>.freeze, ["< 1.0"])
      s.add_dependency(%q<mysql2>.freeze, [">= 0"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_dependency(%q<activerecord-oracle_enhanced-adapter>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<generator_spec>.freeze, [">= 0"])
      s.add_dependency(%q<pry>.freeze, [">= 0"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<database_cleaner>.freeze, [">= 0"])
      s.add_dependency(%q<factory_bot>.freeze, [">= 0"])
      s.add_dependency(%q<faker>.freeze, [">= 0"])
      s.add_dependency(%q<appraisal>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<railties>.freeze, [">= 4.2"])
    s.add_dependency(%q<rails>.freeze, [">= 4.2"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<pg>.freeze, ["< 1.0"])
    s.add_dependency(%q<mysql2>.freeze, [">= 0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    s.add_dependency(%q<activerecord-oracle_enhanced-adapter>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<generator_spec>.freeze, [">= 0"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<database_cleaner>.freeze, [">= 0"])
    s.add_dependency(%q<factory_bot>.freeze, [">= 0"])
    s.add_dependency(%q<faker>.freeze, [">= 0"])
    s.add_dependency(%q<appraisal>.freeze, [">= 0"])
  end
end
