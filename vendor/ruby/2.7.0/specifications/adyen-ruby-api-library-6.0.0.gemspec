# -*- encoding: utf-8 -*-
# stub: adyen-ruby-api-library 6.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "adyen-ruby-api-library".freeze
  s.version = "6.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "documentation_uri" => "https://docs.adyen.com/developers/development-resources/libraries", "homepage_uri" => "https://www.adyen.com", "source_code_uri" => "https://github.com/Adyen/adyen-ruby-api-library" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Adyen".freeze]
  s.date = "2021-10-21"
  s.description = "Official Adyen API Library for Ruby. Simplifies integrating with the Adyen API, including Checkout, Marketpay, payments, recurring, and payouts.  For support please reach out to support@adyen.com.  If you would like to contribute please submit a comment or pull request at https://github.com/Adyen/adyen-ruby-api-library.".freeze
  s.email = ["support@adyen.com".freeze]
  s.homepage = "https://www.adyen.com".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1.0".freeze)
  s.rubygems_version = "3.3.22".freeze
  s.summary = "Official Adyen  Ruby API Library".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<faraday>.freeze, [">= 0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<webmock>.freeze, [">= 0"])
    s.add_development_dependency(%q<activesupport>.freeze, [">= 0"])
  else
    s.add_dependency(%q<faraday>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<webmock>.freeze, [">= 0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
  end
end
