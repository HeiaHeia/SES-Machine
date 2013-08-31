require 'rake/testtask'
require 'rdoc/task'
require 'bundler'
Bundler::GemHelper.install_tasks

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
RDoc::Task.new do |rdoc|
  rdoc.main = 'README.rdoc'
  rdoc.title = 'SES Machine'
  rdoc.rdoc_dir = 'rdoc'
  rdoc.rdoc_files.include('README.rdoc', 'lib/**/*.rb')
end
