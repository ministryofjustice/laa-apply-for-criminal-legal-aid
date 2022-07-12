# frozen_string_literal: true

if Gem.loaded_specs.key?('rspec-rails')
  # Clear the original definition as we are going to redefine it
  Rake::Task['spec'].clear

  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
end
