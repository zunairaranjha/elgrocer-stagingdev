# -*- encoding: utf-8 -*-
# stub: i18n_structure 0.0.5 ruby lib

Gem::Specification.new do |s|
  s.name = "i18n_structure".freeze
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Wojciech Krysiak".freeze]
  s.date = "2014-08-22"
  s.description = "Create structure for I18n locale files".freeze
  s.email = ["wojciech.g.krysiak@gmail.com".freeze]
  s.homepage = "https://github.com/KMPgroup/i18n-structure".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.22".freeze
  s.summary = "Create structure for I18n locale files".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rails>.freeze, [">= 3.0.0"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<draper>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  else
    s.add_dependency(%q<rails>.freeze, [">= 3.0.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<draper>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
  end
end
