# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

task(:default).prerequisites.clear

# The following tasks will run, in order, when running `rake` command.
# Run them individually with `rake rubocop`, `rake spec` ...
#
task default: %i[brakeman rubocop spec]
