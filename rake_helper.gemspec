Gem::Specification.new do |s|
  s.name        = 'rake_helper'
  s.version     = '1.0.1'
  s.license     = 'MIT'
  s.summary     = 'A set of common helper methods to DRY up Rails rake tasks'
  s.author      = 'Daniel Chopson'
  s.email       = 'daniel.chopson@sage.com'
  s.homepage    = 'https://github.com/dchopson/rake_helper'
  s.files       = Dir['lib/**/*']
  s.require_path = 'lib'

  s.required_ruby_version = '>= 2.1'
  s.add_dependency 'rails', '>= 3'

  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'fudge'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'cane'
  s.add_development_dependency 'flay'
  s.add_development_dependency 'flog'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'renogen'
end
