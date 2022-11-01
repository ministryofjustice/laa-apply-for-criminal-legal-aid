# Retrieve global settings and configuration.
#
# usage (for e.g. `session_timeout_minutes`):
#
#   Settings.session_timeout_minutes
#
class Settings
  include Singleton

  attr_reader :config

  def initialize
    @config = YAML.load_file(
      Rails.root.join('config/settings.yml')
    ).fetch('settings', {}).with_indifferent_access.freeze
  end

  class << self
    delegate :method_missing, :respond_to?, to: :instance
  end

  def method_missing(name, *args)
    if config.key?(name)
      config.fetch(name)
    else
      super
    end
  end

  def respond_to_missing?(name, _include_private = false)
    config.key?(name) || super
  end
end
