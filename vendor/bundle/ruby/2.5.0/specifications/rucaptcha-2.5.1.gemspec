# -*- encoding: utf-8 -*-
# stub: rucaptcha 2.5.1 ruby lib
# stub: ext/rucaptcha/extconf.rb

Gem::Specification.new do |s|
  s.name = "rucaptcha".freeze
  s.version = "2.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jason Lee".freeze]
  s.date = "2019-07-01"
  s.email = "huacnlee@gmail.com".freeze
  s.extensions = ["ext/rucaptcha/extconf.rb".freeze]
  s.files = ["ext/rucaptcha/extconf.rb".freeze]
  s.homepage = "https://github.com/huacnlee/rucaptcha".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "3.0.6".freeze
  s.summary = "This is a Captcha gem for Rails Applications. It drawing captcha image with C code so it no dependencies.".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, [">= 3.2"])
      s.add_development_dependency(%q<rake-compiler>.freeze, ["~> 1"])
    else
      s.add_dependency(%q<railties>.freeze, [">= 3.2"])
      s.add_dependency(%q<rake-compiler>.freeze, ["~> 1"])
    end
  else
    s.add_dependency(%q<railties>.freeze, [">= 3.2"])
    s.add_dependency(%q<rake-compiler>.freeze, ["~> 1"])
  end
end
