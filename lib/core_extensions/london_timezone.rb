class Object
  def to_london_time
    raise ArgumentError, 'argument must be a time' unless respond_to?(:to_time)

    to_time.in_time_zone('London')
  end
end
