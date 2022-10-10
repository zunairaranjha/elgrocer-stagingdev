# -*- encoding: utf-8 -*-
# stub: identity_cache 0.5.1 ruby lib

Gem::Specification.new do |s|
  s.name = "identity_cache".freeze
  s.version = "0.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Camilo Lopez".freeze, "Tom Burns".freeze, "Harry Brundage".freeze, "Dylan Thacker-Smith".freeze, "Tobias Lutke".freeze, "Arthur Neves".freeze, "Francis Bogsanyi".freeze]
  s.date = "2017-02-09"
  s.description = "Opt in read through ActiveRecord caching.".freeze
  s.email = ["gems@shopify.com".freeze]
  s.homepage = "https://github.com/Shopify/identity_cache".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.0".freeze)
  s.rubygems_version = "3.3.22".freeze
  s.summary = "IdentityCache lets you specify how you want to cache your model objects, at the model level, and adds a number of convenience methods for accessing those objects through the cache. Memcached is used as the backend cache store, and the database is only hit when a copy of the object cannot be found in Memcached.".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<ar_transaction_changes>.freeze, ["~> 1.0"])
    s.add_runtime_dependency(%q<activerecord>.freeze, [">= 4.2.0"])
    s.add_development_dependency(%q<memcached>.freeze, ["~> 1.8.0"])
    s.add_development_dependency(%q<memcached_store>.freeze, ["~> 1.0.0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<mocha>.freeze, ["= 0.14.0"])
    s.add_development_dependency(%q<spy>.freeze, [">= 0"])
    s.add_development_dependency(%q<minitest>.freeze, [">= 2.11.0"])
    s.add_development_dependency(%q<cityhash>.freeze, ["= 0.6.0"])
    s.add_development_dependency(%q<mysql2>.freeze, [">= 0"])
    s.add_development_dependency(%q<pg>.freeze, [">= 0"])
    s.add_development_dependency(%q<stackprof>.freeze, [">= 0"])
  else
    s.add_dependency(%q<ar_transaction_changes>.freeze, ["~> 1.0"])
    s.add_dependency(%q<activerecord>.freeze, [">= 4.2.0"])
    s.add_dependency(%q<memcached>.freeze, ["~> 1.8.0"])
    s.add_dependency(%q<memcached_store>.freeze, ["~> 1.0.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<mocha>.freeze, ["= 0.14.0"])
    s.add_dependency(%q<spy>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, [">= 2.11.0"])
    s.add_dependency(%q<cityhash>.freeze, ["= 0.6.0"])
    s.add_dependency(%q<mysql2>.freeze, [">= 0"])
    s.add_dependency(%q<pg>.freeze, [">= 0"])
    s.add_dependency(%q<stackprof>.freeze, [">= 0"])
  end
end
