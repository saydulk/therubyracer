# -*- encoding: utf-8 -*-
# stub: liability-proof 0.0.9 ruby lib

Gem::Specification.new do |s|
  s.name = "liability-proof".freeze
  s.version = "0.0.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Peatio Opensource".freeze]
  s.date = "2014-04-18"
  s.description = "Check https://iwilcox.me.uk/2014/proving-bitcoin-reserves for more details.".freeze
  s.email = ["community@peatio.com".freeze]
  s.executables = ["lproof".freeze]
  s.files = ["bin/lproof".freeze]
  s.homepage = "https://github.com/peatio/liability-proof".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "An implementation of Greg Maxwell's Merkle approach to prove Bitcoin liabilities.".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<awesome_print>.freeze, [">= 0"])
    else
      s.add_dependency(%q<awesome_print>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<awesome_print>.freeze, [">= 0"])
  end
end
