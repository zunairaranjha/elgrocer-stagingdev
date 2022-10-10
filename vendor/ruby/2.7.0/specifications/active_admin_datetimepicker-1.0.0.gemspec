# -*- encoding: utf-8 -*-
# stub: active_admin_datetimepicker 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "active_admin_datetimepicker".freeze
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Igor Fedoronchuk".freeze]
  s.date = "2022-04-15"
  s.description = "Integrate jQuery xdan datetimepicker plugin to ActiveAdmin".freeze
  s.email = ["fedoronchuk@gmail.com".freeze]
  s.homepage = "https://github.com/activeadmin-plugins/activeadmin_datetimepicker".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.22".freeze
  s.summary = "datetimepicker extension for ActiveAdmin".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activeadmin>.freeze, [">= 2.0", "< 3.a"])
  else
    s.add_dependency(%q<activeadmin>.freeze, [">= 2.0", "< 3.a"])
  end
end
