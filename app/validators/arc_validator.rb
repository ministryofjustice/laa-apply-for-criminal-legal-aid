class ArcValidator < ActiveModel::Validator
  attr_reader :record

  ARC_REGEXP = %r([A-Z]{3}\d{2}/\d{6}/[A-Z])

  def validate(record)
    blank_arc(record)
    invalid_arc(record)
  end

  def blank_arc(record)
    return if record.arc.present?

    record.errors.add(:arc, :blank)
  end

  def invalid_arc(record)
    return if record.arc.blank?
    return if ARC_REGEXP.match?(record.arc)

    record.errors.add(:arc, :invalid)
  end
end
