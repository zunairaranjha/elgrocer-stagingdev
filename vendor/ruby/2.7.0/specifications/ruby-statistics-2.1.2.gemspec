# -*- encoding: utf-8 -*-
# stub: ruby-statistics 2.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "ruby-statistics".freeze
  s.version = "2.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["esteban zapata".freeze]
  s.bindir = "exe".freeze
  s.date = "2020-03-01"
  s.description = "This gem is intended to accomplish the same purpose as jStat js library:\n                          to provide ruby with statistical capabilities without the need\n                          of a statistical programming language like R or Octave. Some functions\n                          and capabilities are an implementation from other authors and are\n                          referenced properly in the class/method.".freeze
  s.email = ["estebanz01@outlook.com".freeze]
  s.homepage = "https://github.com/estebanz01/ruby-statistics".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.22".freeze
  s.summary = "A ruby gem for som specific statistics. Inspired by the jStat js library.".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<rake>.freeze, [">= 12.0.0", "~> 12.0"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 3.6.0"])
    s.add_development_dependency(%q<grb>.freeze, [">= 0.4.1", "~> 0.4.1"])
    s.add_development_dependency(%q<byebug>.freeze, [">= 9.1.0"])
  else
    s.add_dependency(%q<rake>.freeze, [">= 12.0.0", "~> 12.0"])
    s.add_dependency(%q<rspec>.freeze, [">= 3.6.0"])
    s.add_dependency(%q<grb>.freeze, [">= 0.4.1", "~> 0.4.1"])
    s.add_dependency(%q<byebug>.freeze, [">= 9.1.0"])
  end
end
