# -*- encoding: utf-8 -*-
# stub: method-not-implemented 1.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "method-not-implemented".freeze
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Yaroslav Konoplov".freeze]
  s.date = "2017-08-04"
  s.description = "This gem adds method `method_not_implemented` to every Ruby object. Invoking `method_not_implemented` in abstract method raises an exception if it hasn't been implemented.".freeze
  s.email = "eahome00@gmail.com".freeze
  s.homepage = "https://github.com/yivo/method-not-implemented".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "Tweaks every Ruby object with `method_not_implemented`.".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.7"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 12.0"])
      s.add_development_dependency(%q<test-unit>.freeze, ["~> 3.2"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
      s.add_dependency(%q<rake>.freeze, ["~> 12.0"])
      s.add_dependency(%q<test-unit>.freeze, ["~> 3.2"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.0"])
    s.add_dependency(%q<test-unit>.freeze, ["~> 3.2"])
  end
end
