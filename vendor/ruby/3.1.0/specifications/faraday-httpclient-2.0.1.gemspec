# -*- encoding: utf-8 -*-
# stub: faraday-httpclient 2.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "faraday-httpclient".freeze
  s.version = "2.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/lostisland/faraday-httpclient", "homepage_uri" => "https://github.com/lostisland/faraday-httpclient", "source_code_uri" => "https://github.com/lostisland/faraday-httpclient" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["@iMacTia".freeze]
  s.date = "2022-01-06"
  s.description = "Faraday adapter for HTTPClient".freeze
  s.email = ["giuffrida.mattia@gmail.com".freeze]
  s.homepage = "https://github.com/lostisland/faraday-httpclient".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.3.22".freeze
  s.summary = "Faraday adapter for HTTPClient".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<httpclient>.freeze, [">= 2.2"])
  else
    s.add_dependency(%q<httpclient>.freeze, [">= 2.2"])
  end
end
