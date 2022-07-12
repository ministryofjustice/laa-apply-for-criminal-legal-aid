# frozen_string_literal: true

if Gem.loaded_specs.key?('rubocop')
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new do
    # Rubocop spawns multiple processes and the debugger is quite verbose
    # in the default `warn` level, so raising to `error` here.
    DEBUGGER__::CONFIG[:log_level] = :ERROR
  end
end
