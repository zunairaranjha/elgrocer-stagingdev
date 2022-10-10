# -*- encoding: utf-8 -*-
# stub: activerecord-postgis-adapter 5.2.3 ruby lib

Gem::Specification.new do |s|
  s.name = "activerecord-postgis-adapter".freeze
  s.version = "5.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Daniel Azuma, Tee Parham".freeze]
  s.date = "2021-03-28"
  s.description = "ActiveRecord connection adapter for PostGIS. It is based on the stock PostgreSQL adapter, and adds built-in support for the spatial extensions provided by PostGIS. It uses the RGeo library to represent spatial data in Ruby.".freeze
  s.email = "dazuma@gmail.com, parhameter@gmail.com".freeze
  s.homepage = "http://github.com/rgeo/activerecord-postgis-adapter".freeze
  s.licenses = ["BSD".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.2".freeze)
  s.rubygems_version = "3.3.22".freeze
  s.summary = "ActiveRecord adapter for PostGIS, based on RGeo.".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activerecord>.freeze, ["~> 5.1"])
    s.add_runtime_dependency(%q<rgeo-activerecord>.freeze, ["~> 6.0"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.4"])
    s.add_development_dependency(%q<mocha>.freeze, ["~> 1.1"])
    s.add_development_dependency(%q<appraisal>.freeze, ["~> 2.0"])
  else
    s.add_dependency(%q<activerecord>.freeze, ["~> 5.1"])
    s.add_dependency(%q<rgeo-activerecord>.freeze, ["~> 6.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.4"])
    s.add_dependency(%q<mocha>.freeze, ["~> 1.1"])
    s.add_dependency(%q<appraisal>.freeze, ["~> 2.0"])
  end
end
