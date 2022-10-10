# -*- encoding: utf-8 -*-
# stub: active_interaction 4.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "active_interaction".freeze
  s.version = "4.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/AaronLasseigne/active_interaction/blob/master/CHANGELOG.md", "homepage_uri" => "https://github.com/AaronLasseigne/active_interaction", "source_code_uri" => "https://github.com/AaronLasseigne/active_interaction" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Aaron Lasseigne".freeze, "Taylor Fausak".freeze]
  s.date = "2021-01-10"
  s.description = "    ActiveInteraction manages application-specific business logic. It is an\n    implementation of the command pattern in Ruby.\n".freeze
  s.email = ["aaron.lasseigne@gmail.com".freeze, "taylor@fausak.me".freeze]
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5".freeze)
  s.rubygems_version = "3.3.22".freeze
  s.summary = "Manage application specific business logic.".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activemodel>.freeze, [">= 5", "< 7"])
    s.add_development_dependency(%q<actionpack>.freeze, [">= 0"])
    s.add_development_dependency(%q<activerecord>.freeze, [">= 0"])
    s.add_development_dependency(%q<benchmark-ips>.freeze, ["~> 2.7"])
    s.add_development_dependency(%q<coveralls>.freeze, ["~> 0.8"])
    s.add_development_dependency(%q<kramdown>.freeze, ["~> 2.1"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5"])
    s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.8"])
    s.add_development_dependency(%q<rubocop-rake>.freeze, ["~> 0.5.1"])
    s.add_development_dependency(%q<rubocop-rspec>.freeze, ["~> 2.1"])
    s.add_development_dependency(%q<yard>.freeze, ["~> 0.9"])
    s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
  else
    s.add_dependency(%q<activemodel>.freeze, [">= 5", "< 7"])
    s.add_dependency(%q<actionpack>.freeze, [">= 0"])
    s.add_dependency(%q<activerecord>.freeze, [">= 0"])
    s.add_dependency(%q<benchmark-ips>.freeze, ["~> 2.7"])
    s.add_dependency(%q<coveralls>.freeze, ["~> 0.8"])
    s.add_dependency(%q<kramdown>.freeze, ["~> 2.1"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 1.8"])
    s.add_dependency(%q<rubocop-rake>.freeze, ["~> 0.5.1"])
    s.add_dependency(%q<rubocop-rspec>.freeze, ["~> 2.1"])
    s.add_dependency(%q<yard>.freeze, ["~> 0.9"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
  end
end
