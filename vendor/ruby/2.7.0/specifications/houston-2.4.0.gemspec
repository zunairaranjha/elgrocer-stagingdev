# -*- encoding: utf-8 -*-
# stub: houston 2.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "houston".freeze
  s.version = "2.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mattt Thompson".freeze]
  s.date = "2018-11-21"
  s.description = "Houston is a simple gem for sending Apple Push Notifications. Pass your credentials, construct your message, and send it.".freeze
  s.email = "m@mattt.me".freeze
  s.executables = ["apn".freeze]
  s.files = ["bin/apn".freeze]
  s.homepage = "http://nomad-cli.com".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.22".freeze
  s.summary = "Send Apple Push Notifications".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<commander>.freeze, ["~> 4.4"])
    s.add_runtime_dependency(%q<json>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
  else
    s.add_dependency(%q<commander>.freeze, ["~> 4.4"])
    s.add_dependency(%q<json>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
  end
end
