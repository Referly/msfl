require "rake"
require 'rspec/core/rake_task'

task default: [:spec] do
  ENV['RACK_ENV'] = 'test'
end

task :spec do
  RSpec::Core::RakeTask.new(:spec)
end