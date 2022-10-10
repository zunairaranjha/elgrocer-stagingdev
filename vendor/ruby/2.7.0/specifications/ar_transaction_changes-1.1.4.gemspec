# -*- encoding: utf-8 -*-
# stub: ar_transaction_changes 1.1.4 ruby lib

Gem::Specification.new do |s|
  s.name = "ar_transaction_changes".freeze
  s.version = "1.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Dylan Thacker-Smith".freeze]
  s.date = "2019-03-05"
  s.description = "Solves the problem of trying to get all the changes to an object during a transaction in an after_commit callbacks.".freeze
  s.email = ["Dylan.Smith@shopify.com".freeze]
  s.homepage = "https://github.com/dylanahsmith/ar_transaction_changes".freeze
  s.rubygems_version = "3.3.22".freeze
  s.summary = "Store transaction changes for active record objects".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activerecord>.freeze, [">= 4.2.4"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<mysql2>.freeze, [">= 0"])
  else
    s.add_dependency(%q<activerecord>.freeze, [">= 4.2.4"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<mysql2>.freeze, [">= 0"])
  end
end
