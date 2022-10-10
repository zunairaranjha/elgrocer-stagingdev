# -*- encoding: utf-8 -*-
# stub: rdkafka 0.11.0 ruby lib
# stub: ext/Rakefile

Gem::Specification.new do |s|
  s.name = "rdkafka".freeze
  s.version = "0.11.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Thijs Cadier".freeze]
  s.date = "2021-11-17"
  s.description = "Modern Kafka client library for Ruby based on librdkafka".freeze
  s.email = ["thijs@appsignal.com".freeze]
  s.executables = ["console".freeze]
  s.extensions = ["ext/Rakefile".freeze]
  s.files = ["bin/console".freeze, "ext/Rakefile".freeze]
  s.homepage = "https://github.com/thijsc/rdkafka-ruby".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6".freeze)
  s.rubygems_version = "3.3.22".freeze
  s.summary = "The rdkafka gem is a modern Kafka client library for Ruby based on librdkafka. It wraps the production-ready C client using the ffi gem and targets Kafka 1.0+ and Ruby 2.4+.".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<ffi>.freeze, ["~> 1.15"])
    s.add_runtime_dependency(%q<mini_portile2>.freeze, ["~> 2.7"])
    s.add_runtime_dependency(%q<rake>.freeze, ["> 12"])
    s.add_development_dependency(%q<pry>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_development_dependency(%q<guard>.freeze, [">= 0"])
    s.add_development_dependency(%q<guard-rspec>.freeze, [">= 0"])
  else
    s.add_dependency(%q<ffi>.freeze, ["~> 1.15"])
    s.add_dependency(%q<mini_portile2>.freeze, ["~> 2.7"])
    s.add_dependency(%q<rake>.freeze, ["> 12"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<guard>.freeze, [">= 0"])
    s.add_dependency(%q<guard-rspec>.freeze, [">= 0"])
  end
end
