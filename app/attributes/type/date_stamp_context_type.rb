class DateStampContextType < ActiveModel::Type::Value
  def type
    :jsonb
  end

  # rubocop:disable Style/RescueModifier
  def cast_value(value)
    case value
    when String
      decoded = ActiveSupport::JSON.decode(value) rescue nil
      DateStampContext.new(decoded) unless decoded.nil?
    when DateStampContext
      value
    end
  end
  # rubocop:enable Style/RescueModifier

  def serialize(value)
    case value
    when Hash, DateStampContext
      ActiveSupport::JSON.encode(value)
    else
      super
    end
  end

  # DateStampContext once created cannot be changed, only deleted
  def changed_in_place?(_raw_old_value, _new_value)
    false
  end
end
