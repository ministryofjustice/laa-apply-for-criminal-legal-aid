class HostEnv
  # Update as more K8s environments are added
  def self.staging?
    ENV['ENV'] == 'staging'
  end

  def self.production?
    ENV['ENV'] == 'prod'
  end

  def self.test?
    Rails.env.test?
  end

  def self.local?
    host_env == 'Local'
  end

  def self.host_env
    if ENV['ENV'].nil? && (Rails.env.development? || Rails.env.test?)
      'Local'
    else
      "Host-#{ENV.fetch('ENV', nil)}"
    end
  end
end
