# -*- encoding: utf-8 -*-
# stub: padrino-gen 0.14.2 ruby lib

Gem::Specification.new do |s|
  s.name = "padrino-gen".freeze
  s.version = "0.14.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Padrino Team".freeze, "Nathan Esquenazi".freeze, "Davide D'Agostino".freeze, "Arthur Chiu".freeze]
  s.date = "2018-01-02"
  s.description = "Generators for easily creating and building padrino applications from the console".freeze
  s.email = "padrinorb@gmail.com".freeze
  s.executables = ["padrino-gen".freeze]
  s.extra_rdoc_files = ["README.rdoc".freeze]
  s.files = ["README.rdoc".freeze, "bin/padrino-gen".freeze]
  s.homepage = "http://www.padrinorb.com".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--charset=UTF-8".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "Generators for easily creating and building padrino applications".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<padrino-core>.freeze, ["= 0.14.2"])
      s.add_runtime_dependency(%q<bundler>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<padrino-helpers>.freeze, ["= 0.14.2"])
      s.add_development_dependency(%q<padrino-mailer>.freeze, ["= 0.14.2"])
    else
      s.add_dependency(%q<padrino-core>.freeze, ["= 0.14.2"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
      s.add_dependency(%q<padrino-helpers>.freeze, ["= 0.14.2"])
      s.add_dependency(%q<padrino-mailer>.freeze, ["= 0.14.2"])
    end
  else
    s.add_dependency(%q<padrino-core>.freeze, ["= 0.14.2"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
    s.add_dependency(%q<padrino-helpers>.freeze, ["= 0.14.2"])
    s.add_dependency(%q<padrino-mailer>.freeze, ["= 0.14.2"])
  end
end
