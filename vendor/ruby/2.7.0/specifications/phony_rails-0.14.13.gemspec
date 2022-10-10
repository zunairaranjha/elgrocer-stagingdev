# -*- encoding: utf-8 -*-
# stub: phony_rails 0.14.13 ruby lib

Gem::Specification.new do |s|
  s.name = "phony_rails".freeze
  s.version = "0.14.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Joost Hietbrink".freeze]
  s.date = "2019-07-03"
  s.description = "This Gem adds useful methods to your Rails app to validate, display and save phone numbers.".freeze
  s.email = ["joost@joopp.com".freeze]
  s.homepage = "https://github.com/joost/phony_rails".freeze
  s.licenses = ["MIT".freeze]
  s.post_install_message = "PhonyRails v0.10.0 changes the way numbers are stored!\nIt now adds a ' + ' to the normalized number when it starts with a country number!".freeze
  s.rubygems_version = "3.3.22".freeze
  s.summary = "This Gem adds useful methods to your Rails app to validate, display and save phone numbers.".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 3.0"])
    s.add_runtime_dependency(%q<phony>.freeze, ["> 2.15"])
    s.add_development_dependency(%q<activerecord>.freeze, [">= 3.0"])
    s.add_development_dependency(%q<mongoid>.freeze, [">= 3.0"])
    s.add_development_dependency(%q<sqlite3>.freeze, ["~> 1.3.6"])
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 3.0"])
    s.add_dependency(%q<phony>.freeze, ["> 2.15"])
    s.add_dependency(%q<activerecord>.freeze, [">= 3.0"])
    s.add_dependency(%q<mongoid>.freeze, [">= 3.0"])
    s.add_dependency(%q<sqlite3>.freeze, ["~> 1.3.6"])
  end
end
