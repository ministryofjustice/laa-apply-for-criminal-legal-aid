class LogContext
  include Enumerable

  attr_reader :current_provider, :ip_address, :options

  delegate :each, :map, :inject, :inspect, to: :to_h

  def initialize(current_provider: nil, ip_address: nil, **options)
    @current_provider = current_provider
    @ip_address = ip_address
    @options = options || {}
  end

  def to_h
    {
      provider_id: current_provider&.id,
      provider_ip: ip_address
    }.merge(options)
  end

  def <<(hash)
    raise ArgumentError, 'value must be hash' unless hash.is_a? Hash

    @options.merge!(hash)
  end
end
