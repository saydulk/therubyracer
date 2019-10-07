# -*- encoding: utf-8 -*-
# stub: datagrid 1.5.9 ruby lib

Gem::Specification.new do |s|
  s.name = "datagrid".freeze
  s.version = "1.5.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Bogdan Gusiev".freeze]
  s.date = "2019-05-10"
  s.description = "This allows you to easily build datagrid aka data tables with sortable columns and filters".freeze
  s.email = "agresso@gmail.com".freeze
  s.extra_rdoc_files = ["LICENSE.txt".freeze]
  s.files = ["LICENSE.txt".freeze]
  s.homepage = "http://github.com/bogdan/datagrid".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0".freeze)
  s.rubygems_version = "3.0.6".freeze
  s.summary = "Ruby gem to create datagrids".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>.freeze, [">= 4.0"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_development_dependency(%q<jeweler>.freeze, [">= 2.1.2"])
      s.add_development_dependency(%q<pry-byebug>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 3"])
      s.add_development_dependency(%q<nokogiri>.freeze, [">= 0"])
      s.add_development_dependency(%q<sqlite3>.freeze, ["~> 1.3.6"])
      s.add_development_dependency(%q<sequel>.freeze, [">= 0"])
      s.add_development_dependency(%q<mongoid>.freeze, [">= 0"])
      s.add_development_dependency(%q<bson>.freeze, [">= 0"])
      s.add_development_dependency(%q<bson_ext>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rails>.freeze, [">= 4.0"])
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_dependency(%q<jeweler>.freeze, [">= 2.1.2"])
      s.add_dependency(%q<pry-byebug>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, [">= 3"])
      s.add_dependency(%q<nokogiri>.freeze, [">= 0"])
      s.add_dependency(%q<sqlite3>.freeze, ["~> 1.3.6"])
      s.add_dependency(%q<sequel>.freeze, [">= 0"])
      s.add_dependency(%q<mongoid>.freeze, [">= 0"])
      s.add_dependency(%q<bson>.freeze, [">= 0"])
      s.add_dependency(%q<bson_ext>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>.freeze, [">= 4.0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<jeweler>.freeze, [">= 2.1.2"])
    s.add_dependency(%q<pry-byebug>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 3"])
    s.add_dependency(%q<nokogiri>.freeze, [">= 0"])
    s.add_dependency(%q<sqlite3>.freeze, ["~> 1.3.6"])
    s.add_dependency(%q<sequel>.freeze, [">= 0"])
    s.add_dependency(%q<mongoid>.freeze, [">= 0"])
    s.add_dependency(%q<bson>.freeze, [">= 0"])
    s.add_dependency(%q<bson_ext>.freeze, [">= 0"])
  end
end
