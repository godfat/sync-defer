# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "sync-defer"
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Lin Jen-Shin (godfat)"]
  s.date = "2012-02-24"
  s.description = "Synchronous deferred operations with fibers (coroutines)"
  s.email = ["godfat (XD) godfat.org"]
  s.files = [
  ".gitignore",
  ".gitmodules",
  ".travis.yml",
  "Gemfile",
  "LICENSE",
  "README.md",
  "Rakefile",
  "lib/cool.io/sync-defer.rb",
  "lib/eventmachine/sync-defer.rb",
  "sync-defer.gemspec",
  "task/.gitignore",
  "task/gemgem.rb",
  "test/test_sync-defer.rb"]
  s.homepage = "https://github.com/godfat/sync-defer"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.17"
  s.summary = "Synchronous deferred operations with fibers (coroutines)"
  s.test_files = ["test/test_sync-defer.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
