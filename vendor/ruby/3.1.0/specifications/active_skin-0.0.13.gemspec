# -*- encoding: utf-8 -*-
# stub: active_skin 0.0.13 ruby lib

Gem::Specification.new do |s|
  s.name = "active_skin".freeze
  s.version = "0.0.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Wojtek Krysiak".freeze, "Patryk Zabielski".freeze]
  s.date = "2020-02-12"
  s.description = "active_admin skin".freeze
  s.email = ["wojciech.g.krysiak@gmail.com".freeze, "patryk.zabielski@rst-it.com".freeze]
  s.homepage = "https://github.com/SoftwareBrothers/active_skin".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.22".freeze
  s.summary = "active_admin skin".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.5"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.5"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
