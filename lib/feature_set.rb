# Determine whether or not a feature is enabled in this environment.
#
# usage (for e.g. feature :test_enable):
#
#   FeatureFlags.sars.enabled?
#   FeatureFlags.sars.disable!
#   FeatureFlags.sars.enable!
#
#

class FeatureFlags
  include Singleton

  class EnabledFeature
    def initialize(config)
      @env_config = config
      @host_env = HostEnv.host_env
    end

    def enabled?
      @env_config[@host_env] || false
    end

    def disabled?
      !enabled?
    end

    def enable!
      @env_config[@host_env] = true
    end

    def disable!
      @env_config[@host_env] = false
    end
  end

  def initialize
    @config = Settings.feature_flags
  end

  # so that we can write FeatureFlags.test_enable, etc.
  def self.method_missing(meth)
    efs = instance
    efs.send(meth)
  end

  def method_missing(meth)
    if meth.in?(@config.keys)
      EnabledFeature.new(@config.__send__(meth))
    else
      super
    end
  end

  def self.respond_to_missing?(meth, _include_private = false)
    efs = instance
    efs.respond_to?(meth)
  end

  def respond_to_missing?(meth, _include_private = false)
    meth.in?(@config.keys) ? true : super
  end
end
