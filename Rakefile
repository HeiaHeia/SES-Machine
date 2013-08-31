require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'ses_machine/version'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the ses_machine plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the ses_machine plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Ses Machine'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

spec = Gem::Specification.new do |s|
  s.name        = 'ses_machine'
  s.version     = SesMachine::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.author      = 'Kirill Nikitin'
  s.email       = 'locke23rus@gmail.com'
  s.homepage    = 'https://heiaheia.com/'
  s.summary     = 'Ses Machine'
  s.description = 'Ses Machine description'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- test/*`.split("\n")
  s.require_path = ['lib']

  s.add_dependency('mail', '~> 2.2.15')
  s.add_dependency('aws-ses', '~> 0.4.2')
  s.add_dependency('rubydkim', '~> 0.3.1')
  s.add_dependency('mongo', '~> 1.3.0')
  s.add_dependency('will_paginate', '~> 2.3.15')
end

desc 'Turn this plugin into a gem.'
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end
