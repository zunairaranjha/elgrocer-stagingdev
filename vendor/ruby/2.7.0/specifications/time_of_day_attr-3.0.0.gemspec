# -*- encoding: utf-8 -*-
# stub: time_of_day_attr 3.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "time_of_day_attr".freeze
  s.version = "3.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Clemens Teichmann".freeze]
  s.date = "2018-07-21"
  s.description = "This ruby gem converts time of day to seconds (since midnight) and back. The value in seconds can be used for calculations and validations.".freeze
  s.email = ["clemens_t@web.de".freeze]
  s.homepage = "https://github.com/clemenst/time_of_day_attr".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.22".freeze
  s.summary = "Time of day attributes for your Rails model".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<i18n>.freeze, [">= 0.7"])
    s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
  else
    s.add_dependency(%q<i18n>.freeze, [">= 0.7"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
  end
end
