# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rails-and-solid/version"

Gem::Specification.new do |s|
  s.name        = "rails-and-solid"
  s.version     = RailsAndSolid::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Guilherme Silveira"]
  s.email       = ["guilherme.silveira@caelum.com.br"]
  s.homepage    = ""
  s.summary     = "S.o.l.i.d.ifying 300 methods. An OO approach for a procedural one. Let's see what happens."
  s.description = s.summary

  s.rubyforge_project = "rails-and-solid"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency("rspec")
end
