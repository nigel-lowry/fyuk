# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "fyuk"
  gem.homepage = "http://github.com/nigel-lowry/fyuk"
  gem.license = "MIT"
  gem.summary = %Q{Small Ruby gem for dealing with dates in the UK financial year}
  gem.description = %Q{Small library with methods for finding the financial or fiscal year for a particular date and suchlike. Used by Hubo https://hubo.herokuapp.com/}
  gem.email = "nigel-lowry@ultra.eclipse.co.uk"
  gem.authors = ["Nigel Lowry"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
