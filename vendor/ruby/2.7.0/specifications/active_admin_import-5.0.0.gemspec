# -*- encoding: utf-8 -*-
# stub: active_admin_import 5.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "active_admin_import".freeze
  s.version = "5.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Igor Fedoronchuk".freeze]
  s.date = "2021-11-17"
  s.description = "The most efficient way to import for Active Admin".freeze
  s.email = ["fedoronchuk@gmail.com".freeze]
  s.homepage = "http://github.com/Fivell/active_admin_import".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.22".freeze
  s.summary = "ActiveAdmin import based on activerecord-import gem.".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activerecord-import>.freeze, [">= 0.27"])
    s.add_runtime_dependency(%q<rchardet>.freeze, [">= 1.6"])
    s.add_runtime_dependency(%q<rubyzip>.freeze, [">= 1.2"])
    s.add_runtime_dependency(%q<activeadmin>.freeze, [">= 1.0.0"])
  else
    s.add_dependency(%q<activerecord-import>.freeze, [">= 0.27"])
    s.add_dependency(%q<rchardet>.freeze, [">= 1.6"])
    s.add_dependency(%q<rubyzip>.freeze, [">= 1.2"])
    s.add_dependency(%q<activeadmin>.freeze, [">= 1.0.0"])
  end
end
