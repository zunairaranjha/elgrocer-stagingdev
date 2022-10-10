# -*- encoding: utf-8 -*-
# stub: grape-swagger-ui 2.2.8 ruby lib

Gem::Specification.new do |s|
  s.name = "grape-swagger-ui".freeze
  s.version = "2.2.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Klaas Endrikat".freeze]
  s.date = "2017-03-15"
  s.description = "swagger ui js integration for grape and grape-swagger".freeze
  s.email = ["klaas.endrikat@googlemail.com".freeze]
  s.homepage = "https://github.com/kendrikat/grape-swagger-ui".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.22".freeze
  s.summary = "swagger ui js integration for grape and grape-swagger".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<railties>.freeze, [">= 3.1"])
  else
    s.add_dependency(%q<railties>.freeze, [">= 3.1"])
  end
end
