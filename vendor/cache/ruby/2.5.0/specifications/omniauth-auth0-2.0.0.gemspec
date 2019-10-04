# -*- encoding: utf-8 -*-
# stub: omniauth-auth0 2.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "omniauth-auth0".freeze
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Auth0".freeze]
  s.date = "2017-01-25"
  s.description = "Auth0 is an authentication broker that supports social identity providers as well as enterprise identity providers such as Active Directory, LDAP, Google Apps, Salesforce.\n\nOmniAuth is a library that standardizes multi-provider authentication for web applications. It was created to be powerful, flexible, and do as little as possible.\n\nomniauth-auth0 is the omniauth strategy for Auth0.\n".freeze
  s.email = ["info@auth0.com".freeze]
  s.homepage = "https://github.com/auth0/omniauth-auth0".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "Omniauth OAuth2 strategy for the Auth0 platform.".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<omniauth-oauth2>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.9"])
    else
      s.add_dependency(%q<omniauth-oauth2>.freeze, ["~> 1.4"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.9"])
    end
  else
    s.add_dependency(%q<omniauth-oauth2>.freeze, ["~> 1.4"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.9"])
  end
end
