# -*- encoding: utf-8 -*-
# stub: launchy 2.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "launchy".freeze
  s.version = "2.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/copiousfreetime/launchy/issues", "changelog_uri" => "https://github.com/copiousfreetime/launchy/blob/master/README.md", "homepage_uri" => "https://github.com/copiousfreetime/launchy", "source_code_uri" => "https://github.com/copiousfreetime/launchy" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jeremy Hinegardner".freeze]
  s.date = "2020-02-28"
  s.description = "Launchy is helper class for launching cross-platform applications in a fire and forget manner. There are application concepts (browser, email client, etc) that are common across all platforms, and they may be launched differently on each platform. Launchy is here to make a common approach to launching external applications from within ruby programs.".freeze
  s.email = "jeremy@copiousfreetime.org".freeze
  s.executables = ["launchy".freeze]
  s.extra_rdoc_files = ["CONTRIBUTING.md".freeze, "HISTORY.md".freeze, "Manifest.txt".freeze, "README.md".freeze]
  s.files = ["CONTRIBUTING.md".freeze, "HISTORY.md".freeze, "Manifest.txt".freeze, "README.md".freeze, "bin/launchy".freeze]
  s.homepage = "http://github.com/copiousfreetime/launchy".freeze
  s.licenses = ["ISC".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze, "--markup".freeze, "tomdoc".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.3.22".freeze
  s.summary = "Launchy is helper class for launching cross-platform applications in a fire and forget manner.".freeze

  s.installed_by_version = "3.3.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<addressable>.freeze, ["~> 2.7"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.14"])
    s.add_development_dependency(%q<rdoc>.freeze, ["~> 6.2"])
    s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.18"])
  else
    s.add_dependency(%q<addressable>.freeze, ["~> 2.7"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.14"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 6.2"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.18"])
  end
end
