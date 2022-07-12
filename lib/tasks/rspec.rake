# frozen_string_literal: true

# Clear the original definition as we are going to redefine it
Rake::Task['spec'].clear

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
