# -*- encoding: utf-8 -*-
# stub: actionmailbox 6.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "actionmailbox".freeze
  s.version = "6.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/rails/rails/blob/v6.0.0/actionmailbox/CHANGELOG.md", "source_code_uri" => "https://github.com/rails/rails/tree/v6.0.0/actionmailbox" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze, "George Claghorn".freeze]
  s.date = "2019-08-16"
  s.description = "Receive and process incoming emails in Rails applications.".freeze
  s.email = ["david@loudthinking.com".freeze, "george@basecamp.com".freeze]
  s.homepage = "https://rubyonrails.org".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.3.22".freeze
  s.summary = "Inbound email handling framework.".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, ["= 6.0.0"])
    s.add_runtime_dependency(%q<activerecord>.freeze, ["= 6.0.0"])
    s.add_runtime_dependency(%q<activestorage>.freeze, ["= 6.0.0"])
    s.add_runtime_dependency(%q<activejob>.freeze, ["= 6.0.0"])
    s.add_runtime_dependency(%q<actionpack>.freeze, ["= 6.0.0"])
    s.add_runtime_dependency(%q<mail>.freeze, [">= 2.7.1"])
  else
    s.add_dependency(%q<activesupport>.freeze, ["= 6.0.0"])
    s.add_dependency(%q<activerecord>.freeze, ["= 6.0.0"])
    s.add_dependency(%q<activestorage>.freeze, ["= 6.0.0"])
    s.add_dependency(%q<activejob>.freeze, ["= 6.0.0"])
    s.add_dependency(%q<actionpack>.freeze, ["= 6.0.0"])
    s.add_dependency(%q<mail>.freeze, [">= 2.7.1"])
  end
end
