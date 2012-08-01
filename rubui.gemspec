# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rubui/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Calvin Grunewald"]
  gem.email         = ["calvin.grunewald@gmail.com"]
  gem.description   = %q{DSL for HTML/CSS/JS markup}
  gem.summary       = %q{Adds a DSL for embedding HTML/CSS/JS}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rubui"
  gem.require_paths = ["lib"]
  gem.version       = Rubui::VERSION
end
