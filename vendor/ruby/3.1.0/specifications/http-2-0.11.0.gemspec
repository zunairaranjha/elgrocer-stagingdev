# -*- encoding: utf-8 -*-
# stub: http-2 0.11.0 ruby lib

Gem::Specification.new do |s|
  s.name = "http-2".freeze
  s.version = "0.11.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ilya Grigorik".freeze, "Kaoru Maeda".freeze]
  s.date = "2021-01-06"
  s.description = "Pure-ruby HTTP 2.0 protocol implementation".freeze
  s.email = ["ilya@igvita.com".freeze]
  s.homepage = "https://github.com/igrigorik/http-2".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1.0".freeze)
  s.rubygems_version = "3.3.22".freeze
  s.summary = "Pure-ruby HTTP 2.0 protocol implementation".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
  else
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
  end
end
