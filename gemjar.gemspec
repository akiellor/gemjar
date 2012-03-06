# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gemjar/version"

Gem::Specification.new do |s|
  s.name        = "gemjar"
  s.version     = Gemjar::VERSION
  s.authors     = ["Andrew Kiellor"]
  s.email       = ["akiellor@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "gemjar"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('sinatra')
  s.add_dependency('builder')
end
