# -*- encoding: utf-8 -*-
# stub: fcm 1.0.8 ruby lib

Gem::Specification.new do |s|
  s.name = "fcm".freeze
  s.version = "1.0.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Kashif Rasul".freeze, "Shoaib Burq".freeze]
  s.date = "2022-04-16"
  s.description = "fcm provides ruby bindings to Firebase Cloud Messaging (FCM) a cross-platform messaging solution that lets you reliably deliver messages and notifications at no cost to Android, iOS or Web browsers.".freeze
  s.email = ["kashif@decision-labs.com".freeze, "shoaib@decision-labs.com".freeze]
  s.homepage = "https://github.com/decision-labs/fcm".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.3.22".freeze
  s.summary = "Reliably deliver messages and notifications via FCM".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<faraday>.freeze, [">= 1.0.0", "< 3.0"])
    s.add_runtime_dependency(%q<googleauth>.freeze, ["~> 1"])
  else
    s.add_dependency(%q<faraday>.freeze, [">= 1.0.0", "< 3.0"])
    s.add_dependency(%q<googleauth>.freeze, ["~> 1"])
  end
end
