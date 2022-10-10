# -*- encoding: utf-8 -*-
# stub: searchjoy 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "searchjoy".freeze
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Andrew Kane".freeze]
  s.date = "2022-05-10"
  s.email = "andrew@ankane.org".freeze
  s.homepage = "https://github.com/ankane/searchjoy".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6".freeze)
  s.rubygems_version = "3.3.22".freeze
  s.summary = "Search analytics made easy".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<chartkick>.freeze, [">= 3.2"])
    s.add_runtime_dependency(%q<groupdate>.freeze, [">= 3"])
    s.add_runtime_dependency(%q<activerecord>.freeze, [">= 5.2"])
  else
    s.add_dependency(%q<chartkick>.freeze, [">= 3.2"])
    s.add_dependency(%q<groupdate>.freeze, [">= 3"])
    s.add_dependency(%q<activerecord>.freeze, [">= 5.2"])
  end
end
