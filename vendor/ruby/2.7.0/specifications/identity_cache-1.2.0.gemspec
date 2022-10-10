# -*- encoding: utf-8 -*-
# stub: identity_cache 1.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "identity_cache".freeze
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Camilo Lopez".freeze, "Tom Burns".freeze, "Harry Brundage".freeze, "Dylan Thacker-Smith".freeze, "Tobias Lutke".freeze, "Arthur Neves".freeze, "Francis Bogsanyi".freeze]
  s.date = "2022-08-15"
  s.description = "Opt-in read through Active Record caching.".freeze
  s.email = ["gems@shopify.com".freeze]
  s.homepage = "https://github.com/Shopify/identity_cache".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.3.22".freeze
  s.summary = "IdentityCache lets you specify how you want to cache your model objects, at the model level, and adds a number of convenience methods for accessing those objects through the cache. Memcached is used as the backend cache store, and the database is only hit when a copy of the object cannot be found in Memcached.".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activerecord>.freeze, [">= 5.2"])
    s.add_runtime_dependency(%q<ar_transaction_changes>.freeze, ["~> 1.1"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.14"])
    s.add_development_dependency(%q<mocha>.freeze, ["~> 1.12"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_development_dependency(%q<spy>.freeze, ["~> 1.0"])
  else
    s.add_dependency(%q<activerecord>.freeze, [">= 5.2"])
    s.add_dependency(%q<ar_transaction_changes>.freeze, ["~> 1.1"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.14"])
    s.add_dependency(%q<mocha>.freeze, ["~> 1.12"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_dependency(%q<spy>.freeze, ["~> 1.0"])
  end
end
